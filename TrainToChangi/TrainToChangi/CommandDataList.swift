//
//  CommandDataList.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 23/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

// MARK - List Node

fileprivate protocol CommandDataListNode: class {
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
    var jumpTarget: JumpTargetListNode! // Use ! to silence xcode
    var next: CommandDataListNode?
    var previous: CommandDataListNode?

    init(commandData: CommandData) {
        self.commandData = commandData
        self.jumpTarget = JumpTargetListNode(jumpParent: self)
        self.previous = jumpTarget
    }
}

fileprivate class JumpTargetListNode: CommandDataListNode {
    let commandData: CommandData
    unowned var jumpParent: JumpListNode
    var next: CommandDataListNode?
    var previous: CommandDataListNode?

    init(jumpParent: JumpListNode) {
        self.commandData = .placeholder
        self.jumpParent = jumpParent
        self.next = jumpParent
    }
}

// MARK - List

protocol CommandDataList {

    // Appends `commandData` to the end of the list.
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
    // TODO: ADT _checkrep, make sure both sides are connected, jump and target connected.
}

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
        assert(commandData != .placeholder)
        let newNode = initNode(commandData: commandData)
        if let jumpNode = newNode as? JumpListNode {
            append(jumpNode.jumpTarget)
            return
        }
        append(newNode)
    }

    func insert(commandData: CommandData, atIndex index: Int) {
        assert(commandData != .placeholder)
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
        } else if let node = node as? JumpTargetListNode {
            _ = remove(node.jumpParent)
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

    private func initNode(commandData: CommandData) -> CommandDataListNode {
        return commandData.isJumpCommand
            ? JumpListNode(commandData: commandData)
            : IterativeListNode(commandData: commandData)
    }

    private func append(_ newNode: Node) {
        guard let lastNode = last else {
            head = newNode
            return
        }
        newNode.previous = lastNode
        lastNode.next = newNode
    }

    private func node(atIndex index: Int) -> Node? {
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
}

extension CommandDataLinkedList {
    func makeIterator() -> CommandDataListIterator {
        return CommandDataListIterator(self)
    }
}

class CommandDataListIterator: Sequence, IteratorProtocol {
    private var commandDataList: CommandDataList
    private var current: CommandDataListNode?

    init(_ commandDataList: CommandDataList) {
        self.commandDataList = commandDataList
        self.current = (commandDataList as? CommandDataLinkedList)?.first
    }

    func makeIterator() -> CommandDataListIterator {
        return self
    }

    func next() -> CommandData? {
        guard let currentValue = current?.commandData else {
            return nil
        }
        current = current?.next
        return currentValue
    }

    func previous() {
        current = current?.previous
    }

    func jump() {
        // After calling next(), pointer has been moved to the next node
        // that has not been returned yet.
        // So when jump() is called, we need to go back to previous node
        // to jump on that node.
        // Destination will always land on a .placeholder
        guard let previousNode = current?.previous as? JumpListNode else {
            preconditionFailure("Cannot jump on a non-jump command")
        }
        current = previousNode.jumpTarget
    }

    func reset() {
        self.current = (commandDataList as? CommandDataLinkedList)?.first
    }
}
