//
//  CommandDataList.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 23/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

// MARK - CommandDataListNode

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
    var jumpTarget: IterativeListNode?

    init(commandData: CommandData) {
        self.commandData = commandData
    }
}

// MARK - CommandDataList

protocol CommandDataList {

    // Appends `commandData` to the end of the list.
    // If `commandData` is a jump-related command, also appends
    // its associated `jumpTarget` in front of it.
    func append(commandData: CommandData)

    // Inserts `commandData` into the list at `index`.
    // If `commandData` is a jump-related command, also inserts
    // its associated `jumpTarget` in front of it.
    // If `atIndex` is == length of list, appends the commandData to the list.
    // - Precondition: atIndex >= 0 and <= length of list
    func insert(commandData: CommandData, atIndex: Int)

    // Removes `commandData` at `index` from the list.
    // If `commandData` at index is a jump-related command, also removes
    // its associated `jumpTarget`.
    // - Precondition: atIndex must be valid: >= 0 and < length of list
    func remove(atIndex: Int) -> CommandData

    // Moves `commandData` from `sourceIndex` to `destIndex`.
    // - Precondition: sourceIndex and destIndex must be valid: >= 0 and < length of list
    func move(sourceIndex: Int, destIndex: Int)

    // Empties the list.
    func removeAll()

    // Returns the `CommandDataList` as an array.
    func toArray() -> [CommandData]

    // Returns an iterator for the CommandDataList.
    func makeIterator() -> CommandDataListIterator

    // Returns a representation of the `CommandDataList` used for storage.
    func asListInfo() -> CommandDataListInfo

}

// TODO: Refactor and define boundary conditions properly
class CommandDataLinkedList: CommandDataList {

    fileprivate typealias Node = CommandDataListNode

    private var head: Node?

    init() {
        _checkRep()
    }

    // MARK - API implementations

    func append(commandData: CommandData) {
        _checkRep()
        let newNode = initNode(commandData: commandData)
        if let jumpNode = newNode as? JumpListNode {
            guard let jumpTargetNode = jumpNode.jumpTarget else {
                fatalError("All jump nodes should have a jump target!")
            }
            // jumpTargetNode's next is set to jumpNode in initNode().
            append(node: jumpTargetNode)
        } else {
            append(node: newNode)
        }
        _checkRep()
    }

    func insert(commandData: CommandData, atIndex index: Int) {
        _checkRep()
        let newNode = initNode(commandData: commandData)
        insert(node: newNode, atIndex: index)
        if let jumpNode = newNode as? JumpListNode {
            guard let jumpTargetNode = jumpNode.jumpTarget else {
                fatalError("All jump nodes should have a jump target!")
            }
            insert(node: jumpTargetNode, atIndex: index)
        }
        _checkRep()
    }

    func move(sourceIndex: Int, destIndex: Int) {
        _checkRep()
        guard let node = node(atIndex: sourceIndex) else {
            preconditionFailure("Index is not valid")
        }
        move(node: node, toIndex: destIndex)
        _checkRep()
    }

    func remove(atIndex index: Int) -> CommandData {
        _checkRep()
        guard let node = node(atIndex: index) else {
            preconditionFailure("Index is not valid.")
        }

        // Remove corresponding pair.
        if let jumpNode = node as? JumpListNode {
            guard let jumpTargetNode = jumpNode.jumpTarget else {
                fatalError("All jump nodes should have a jump target!")
            }
            _ = remove(node: jumpTargetNode)
        } else if let jumpParentNode = jumpParentOf(node: node) as? JumpListNode {
            _ = remove(node: jumpParentNode)
        }
        let removedNode = remove(node: node)
        _checkRep()
        return removedNode
    }

    func removeAll() {
        _checkRep()
        // To prevent circular reference and memory leaks, remove in naive way.
        // This ensures that both previous and next links are broken upon removal.
        // This is a workaround because setting properties to weak
        // prevents them from being initialised.
        while let head = head {
            _ = remove(node: head)
        }
        _checkRep()
    }

    func toArray() -> [CommandData] {
        _checkRep()
        guard var node = head else {
            return []
        }

        var array: [CommandData] = []
        array.append(node.commandData)

        while case let next? = node.next {
            node = next
            array.append(node.commandData)
        }
        _checkRep()
        return array
    }

    func asListInfo() -> CommandDataListInfo {
        _checkRep()

        let listInfo =  CommandDataListInfo(commandDataArray: toArray(), jumpMappings: getJumpMappings())
        _checkRep()
        return listInfo
    }

    // MARK - Private helpers

    private var isEmpty: Bool {
        return head == nil
    }

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

    private func initNode(commandData: CommandData) -> CommandDataListNode {
        if commandData.isJumpCommand {
            // Init target node as well.
            let jumpListNode = JumpListNode(commandData: commandData)
            let jumpTargetNode = IterativeListNode(commandData: .jumpTarget)

            // Init links.
            jumpListNode.jumpTarget = jumpTargetNode
            jumpListNode.previous = jumpTargetNode
            jumpTargetNode.next = jumpListNode

            return jumpListNode
        }

        return IterativeListNode(commandData: commandData)
    }

    fileprivate func append(node: Node) {
        guard let lastNode = last else {
            // Empty list.
            head = node
            return
        }
        node.previous = lastNode
        lastNode.next = node
    }

    fileprivate func node(atIndex index: Int) -> Node? {
        guard index >= 0 else {
            return nil
        }
        var node = head
        var currIndex = 0
        while node != nil {
            if currIndex == index {
                return node
            }
            currIndex += 1
            node = node?.next
        }

        return nil
    }

    private func nodesBeforeAndAfter(index: Int) -> (Node?, Node?) {
        guard index >= 0 else {
            preconditionFailure("Invalid index!")
        }

        var currIndex = 0
        var next = head
        var prev: Node?

        while next != nil && currIndex != index {
            currIndex += 1
            prev = next
            next = next?.next
        }

        guard currIndex == index else {
            preconditionFailure("Specified index was too large")
        }

        return (prev, next)
    }

    private func insert(node: Node, atIndex index: Int) {
        let (prev, next) = nodesBeforeAndAfter(index: index)

        node.previous = prev
        node.next = next
        prev?.next = node
        next?.previous = node

        // Inserted at front of list.
        if prev == nil {
            head = node
        }
    }

    private func remove(node: Node) -> CommandData {
        let prev = node.previous
        let next = node.next

        if let prev = prev {
            prev.next = next
        } else {
            // Removed first item in list.
            head = next
        }
        next?.previous = prev

        node.previous = nil
        node.next = nil

        return node.commandData
    }

    private func move(node: Node, toIndex: Int) {
        _ = remove(node: node)
        insert(node: node, atIndex: toIndex)
    }

    private func jumpParentOf(node: Node) -> Node? {
        var curr = head
        while curr != nil {
            if let jumpNode = curr as? JumpListNode, jumpNode.jumpTarget === node {
                return jumpNode
            }
            curr = curr?.next
        }
        return nil
    }

    fileprivate func indexOf(node: Node) -> Int {
        var curr = head
        var currIndex = 0
        while curr != nil {
            if curr === node {
                return currIndex
            }
            curr = curr?.next
            currIndex += 1
        }
        preconditionFailure("Node must exist!")
    }

    private func getJumpMappings() -> [Int: Int] {
        var map: [Int: Int] = [:]

        var curr = head
        while curr != nil {
            if let jumpNode = curr as? JumpListNode {
                let jumpParentIndex = indexOf(node: jumpNode)
                guard let jumpTargetNode = jumpNode.jumpTarget else {
                    fatalError("All jump nodes should have a jump target!")
                }
                let jumpTargetIndex = indexOf(node: jumpTargetNode)
                map[jumpParentIndex] = jumpTargetIndex
            }
            curr = curr?.next
        }
        return map
    }

    fileprivate func _checkRep() {
        _checkRepForNextAndPrevConnectivity()
        _checkRepForJumpAndTargetConnectivity()
    }

    private func _checkRepForNextAndPrevConnectivity() {
        var curr = head
        while curr != nil {
            let next = curr?.next
            if next == nil {
                break
            }
            assert(next?.previous != nil && next?.previous === curr,
                   "All nodes must be connected on their next and previous links!")

            curr = next
        }
    }

    private func _checkRepForJumpAndTargetConnectivity() {
        var curr = head
        while curr != nil {
            if let jumpNode = curr as? JumpListNode {
                assert(jumpNode.jumpTarget != nil,
                       "All jump nodes must have a connected jump target!")
            }
            curr = curr?.next
        }
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
        _checkRep()
        setUpListNodes(commandDataArray: commandDataListInfo.commandDataArray)
        setUpJumpReferences(jumpMappings: commandDataListInfo.jumpMappings)
        _checkRep()
    }

    private func setUpListNodes(commandDataArray: [CommandData]) {
        for commandData in commandDataArray {
            let newNode: CommandDataListNode = commandData.isJumpCommand
                    ? JumpListNode(commandData: commandData)
                    : IterativeListNode(commandData: commandData)
            append(node: newNode)
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

//TODO: Rename
class CommandDataListIterator {
    private unowned var commandDataLinkedList: CommandDataLinkedList

    private var currentNode: CommandDataListNode? {
        didSet {
            NotificationCenter.default.post(name: Constants.NotificationNames.moveProgramCounter,
                                            object: nil, userInfo: ["index": index])
        }
    }

    var current: CommandData? {
        return currentNode?.commandData
    }

    var index: Int? {
        guard let current = currentNode else {
            return nil
        }
        return commandDataLinkedList.indexOf(node: current)
    }

    init(_ commandDataLinkedList: CommandDataLinkedList) {
        self.commandDataLinkedList = commandDataLinkedList
        self.currentNode = commandDataLinkedList.first
    }

    func makeIterator() -> CommandDataListIterator {
        return self
    }

    func next() {
        currentNode = currentNode?.next
    }

    func jump() {
        guard let current = currentNode as? JumpListNode else {
            preconditionFailure("Cannot jump on a non-jump command")
        }

        self.currentNode = current.jumpTarget
    }

    // This function is only called by jump-related commands during `undo`.
    func moveIterator(to index: Int) {
        currentNode = commandDataLinkedList.node(atIndex: index)
    }
}
