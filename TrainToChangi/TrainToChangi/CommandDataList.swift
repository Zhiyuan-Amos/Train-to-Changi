//
//  CommandDataList.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 23/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

// MARK - List Node

protocol CommandDataListNode: class {
    var commandData: CommandData { get }
    var next: CommandDataListNode? { get set }
    var previous: CommandDataListNode? { get set }
}

fileprivate class IterativeListNode: CommandDataListNode {
    let commandData: CommandData
    var next: CommandDataListNode?
    var previous: CommandDataListNode?

    init(commandData: CommandData) {
        self.commandData = commandData
    }
}

fileprivate class JumpListNode: CommandDataListNode {
    let commandData: CommandData
    var next: CommandDataListNode?
    var previous: CommandDataListNode?
    var jumpTarget: IterativeListNode! // use ! to silence xcode use of self

    init(commandData: CommandData, initJumpTarget: Bool = true) {
        self.commandData = commandData
        if initJumpTarget {
            self.jumpTarget = IterativeListNode(commandData: .jumpTarget)
            self.previous = jumpTarget
            self.jumpTarget.next = self
        }
    }
}

// MARK - List

protocol CommandDataList {

    // Appends `commandData` to the end of the list.
    // I'm trying to think of how to reduce code smell here
    // because these functions handle jump (add jump auto add jumpTarget), while
    // the private helper functions named similarly with different
    // parameters don't. e.g. append(_ node: Node) doesn't care if its jump
    // Wanted to rename to appendNew but sounds weird too..
    func append(commandData: CommandData)

    // Inserts `commandData` into the list at `index`.
    func insert(commandData: CommandData, atIndex: Int)

    // Removes `commandData` at `index` from the list.
    func remove(atIndex: Int) -> CommandData

    // Moves `commandData` from `sourceIndex` to `destIndex`.
    func move(sourceIndex: Int, destIndex: Int)

    // Empties the list.
    func removeAll()

    // Returns the `CommandDataList` as an array.
    func toArray() -> [CommandData]

    // Returns an iterator for the CommandDataList.
    func makeIterator() -> CommandDataListIterator

    // Used for storage.
    func asListInfo() -> CommandDataListInfo

    // TODO: ADT _checkrep, make sure both sides are connected, jump and target connected.
}

// TODO: Refactor and define boundary conditions properly
class CommandDataLinkedList: CommandDataList {

    fileprivate typealias Node = CommandDataListNode

    private var head: Node?

    init() {}

    // MARK - API implementations

    var isEmpty: Bool {
        return head == nil
    }

    subscript(index: Int) -> CommandData {
        let node = self.node(atIndex: index)
        guard let commandData = node?.commandData else {
            preconditionFailure("Index is not valid.")
        }
        return commandData
    }

    func append(commandData: CommandData) {
        assert(commandData != .jumpTarget)
        let newNode = initNode(commandData: commandData)
        if let jumpNode = newNode as? JumpListNode {
            append(jumpNode.jumpTarget)
            return
        }
        append(newNode)
    }

    func insert(commandData: CommandData, atIndex index: Int) {
        assert(commandData != .jumpTarget)
        let newNode = initNode(commandData: commandData)
        insert(newNode, atIndex: index)
        if let jumpNode = newNode as? JumpListNode {
            insert(jumpNode.jumpTarget, atIndex: index)
        }
    }

    func move(sourceIndex: Int, destIndex: Int) {
        // TODO: make sure index valid..

        let node = self.node(atIndex: sourceIndex)
        move(node!, toIndex: destIndex)
    }

    func remove(atIndex index: Int) -> CommandData {
        guard let node = self.node(atIndex: index) else {
            preconditionFailure("Index is not valid.")
        }
        if let node = node as? JumpListNode {
            _ = remove(node.jumpTarget)
        } else if let jumpParent = jumpParentOf(node) as? JumpListNode {
            _ = remove(jumpParent)
        }

        return remove(node)
    }

    func removeAll() {
        head = nil
    }

    func toArray() -> [CommandData] {
        guard var node = head else {
            return []
        }

        var array: [CommandData] = []
        array.append(node.commandData)

        while case let next? = node.next {
            node = next
            array.append(node.commandData)
        }
        return array
    }

    func asListInfo() -> CommandDataListInfo {
        return CommandDataListInfo(array: toArray(), jumpMappings: getJumpMappings())
    }

    // MARK - Private helpers

    fileprivate var first: Node? {
        return head
    }

    private var last: Node? {
        guard var node = head else {
            return nil
        }
        while case let next? = node.next {
            node = next
        }
        return node
    }

    private var count: Int {
        guard var node = head else {
            return 0
        }
        var count = 1
        while case let next? = node.next {
            node = next
            count += 1
        }
        return count
    }

    fileprivate func initNode(commandData: CommandData) -> CommandDataListNode {
        return commandData.isJumpCommand
            ? JumpListNode(commandData: commandData)
            : IterativeListNode(commandData: commandData)
    }

    fileprivate func append(_ newNode: Node) {
        guard let lastNode = last else {
            head = newNode
            return
        }
        newNode.previous = lastNode
        lastNode.next = newNode
    }

    fileprivate func node(atIndex index: Int) -> Node? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 { return node }
                i -= 1
                node = node!.next
            }
        }
        return nil
    }

    private func nodesBeforeAndAfter(index: Int) -> (Node?, Node?) {
        assert(index >= 0)

        var i = index
        var next = head
        var prev: Node?

        while next != nil && i > 0 {
            i -= 1
            prev = next
            next = next!.next
        }
        assert(i == 0)  // if > 0, then specified index was too large

        return (prev, next)
    }

    private func insert(_ newNode: Node, atIndex index: Int) {
        let (prev, next) = nodesBeforeAndAfter(index: index)

        newNode.previous = prev
        newNode.next = next
        prev?.next = newNode
        next?.previous = newNode

        if prev == nil {
            head = newNode
        }
    }

    private func remove(_ node: Node) -> CommandData {
        let prev = node.previous
        let next = node.next

        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev

        node.previous = nil
        node.next = nil

        return node.commandData
    }

    private func move(_ node: Node, toIndex: Int) {
        _ = remove(node)
        insert(node, atIndex: toIndex)
    }

    private func removeLast() -> CommandData {
        assert(!isEmpty)
        return remove(last!)
    }

    private func jumpParentOf(_ node: Node) -> Node? {
        var curr = head
        while curr != nil {
            if let jumpNode = curr as? JumpListNode, jumpNode.jumpTarget === node {
                return jumpNode
            }
            curr = curr?.next
        }
        return nil
    }

    fileprivate func indexOf(_ node: Node) -> Int {
        var curr = head
        var index = 0
        while curr != nil {
            if curr === node {
                return index
            }
            curr = curr?.next
            index += 1
        }
        preconditionFailure("Node must exist!")
    }

    private func getJumpMappings() -> [Int: Int] {
        var map: [Int: Int] = [:]

        var curr = head
        while curr != nil {
            if let jump = curr as? JumpListNode {
                let jumpParentIndex = indexOf(jump)
                let jumpTargetIndex = indexOf(jump.jumpTarget)
                map[jumpParentIndex] = jumpTargetIndex
            }
            curr = curr?.next
        }
        return map
    }

}

extension CommandDataLinkedList {
    func makeIterator() -> CommandDataListIterator {
        return CommandDataListIterator(self)
    }
}

extension CommandDataLinkedList {
    convenience init(commandDataListInfo: CommandDataListInfo) {
        self.init()
        setUpListNodes(commandDataArray: commandDataListInfo.commandDataArray)
        setUpJumpReferences(jumpMappings: commandDataListInfo.jumpMappings)
    }

    private func setUpListNodes(commandDataArray: [CommandData]) {
        for commandData in commandDataArray {
            let newNode: CommandDataListNode = commandData.isJumpCommand
                    ? JumpListNode(commandData: commandData, initJumpTarget: false)
                    : IterativeListNode(commandData: commandData)
            append(newNode)
        }
    }

    private func setUpJumpReferences(jumpMappings: [Int: Int]) {
        for (jumpParentIndex, jumpTargetIndex) in jumpMappings {
            guard let jumpNode = node(atIndex: jumpParentIndex) as? JumpListNode,
                  let jumpTargetNode = node(atIndex: jumpTargetIndex) as? IterativeListNode else {
                fatalError("Jump Mappings not set up properly!")
            }
            jumpNode.jumpTarget = jumpTargetNode
        }
    }
}

class CommandDataListIterator: Sequence, IteratorProtocol {
    private var commandDataLinkedList: CommandDataLinkedList
    private var isFirstCall: Bool

    private var current: CommandDataListNode? {
        willSet(newNode) {
            guard let newNode = newNode else {
                return
            }
            let index = commandDataLinkedList.indexOf(newNode)
            NotificationCenter.default.post(name: Constants.NotificationNames.moveProgramCounter,
                                            object: nil,
                                            userInfo: ["index": index])
        }
    }

    var index: Int? {
        return current == nil ? nil : commandDataLinkedList.indexOf(current!)
    }

    init(_ commandDataLinkedList: CommandDataLinkedList) {
        self.commandDataLinkedList = commandDataLinkedList
        self.current = commandDataLinkedList.first
        self.isFirstCall = true
    }

    func makeIterator() -> CommandDataListIterator {
        return self
    }

    func next() -> CommandData? {
        if isFirstCall {
            isFirstCall = false
            return current?.commandData
        }

        current = current?.next
        return current?.commandData
    }

    func previous() {
        current = current?.previous
    }

    func jump() {
        guard let current = current as? JumpListNode else {
            preconditionFailure("Cannot jump on a non-jump command")
        }

        self.current = current.jumpTarget
    }

    func moveIterator(to index: Int) {
        current = commandDataLinkedList.node(atIndex: index)
        isFirstCall = true
    }

    func reset() {
        current = commandDataLinkedList.first
        isFirstCall = true
    }

}
