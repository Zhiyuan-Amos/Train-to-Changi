//
//  CommandDataList.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 23/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

protocol CommandDataListNode: class {
    var commandData: CommandData { get }
    var next: CommandDataListNode? { get set }
    var previous: CommandDataListNode? { get set }
}

class IterativeListNode: CommandDataListNode {
    let commandData: CommandData
    var next: CommandDataListNode?
    var previous: CommandDataListNode?

    init(commandData: CommandData) {
        self.commandData = commandData
    }
}

class JumpListNode: CommandDataListNode {
    let commandData: CommandData
    // Use ! to silence xcode
    var jumpTarget: JumpTargetListNode!
    var next: CommandDataListNode?
    var previous: CommandDataListNode?

    init(commandData: CommandData) {
        self.commandData = commandData
        self.jumpTarget = JumpTargetListNode(jumpParent: self)
        self.previous = jumpTarget
    }
}

class JumpTargetListNode: CommandDataListNode {
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

protocol CommandDataList {

    // Appends `commandData` to the end of the list.
    func append(commandData: CommandData)

    // Inserts `commandData` into the list at `index`.
    func insert(commandData: CommandData, atIndex: Int)

    // Moves `commandData` from `sourceIndex` to `destIndex`.
    func move(sourceIndex: Int, destIndex: Int)

    // Removes `commandData` at `index` from the list.
    func remove(atIndex: Int) -> CommandData

    // Empties the list.
    func removeAll()

    // Returns the `CommandDataList` as an array.
    func toArray() -> [CommandData]

}

class CommandDataLinkedList: CommandDataList {

    typealias Node = CommandDataListNode

    private var head: Node?

    init() {}

    // MARK - API implementations

    var isEmpty: Bool {
        return head == nil
    }

    var first: Node? {
        return head
    }

    subscript(index: Int) -> CommandData {
        let node = self.node(atIndex: index)
        guard let commandData = node?.commandData else {
            preconditionFailure("Index is not valid.")
        }
        return commandData
    }

    func append(commandData: CommandData) {
        let newNode = initNode(commandData: commandData)
        if let jumpNode = newNode as? JumpListNode {
            append(jumpNode.jumpTarget)
            return
        }
        append(newNode)
    }

    func insert(commandData: CommandData, atIndex index: Int) {
        let newNode = initNode(commandData: commandData)
        insert(newNode, atIndex: index)
        if let jumpNode = newNode as? JumpListNode {
            insert(jumpNode.jumpTarget, atIndex: index)
        }
    }

    func move(sourceIndex: Int, destIndex: Int) {
        // TODO: make sure index valid..

        let (prev1, next1) = nodesBeforeAndAfter(index: sourceIndex)

        let node = self.node(atIndex: sourceIndex)
        let prev2 = self.node(atIndex: destIndex)
        let next2 = prev2?.next

        prev1?.next = next1
        next1?.previous = prev1

        prev2?.next = node
        node?.previous = prev2

        node?.next = next2
        next2?.previous = node
    }

    func remove(atIndex index: Int) -> CommandData {
        guard let node = self.node(atIndex: index) else {
            preconditionFailure("Index is not valid.")
        }
        if let node = node as? JumpListNode {
            _ = remove(node: node.jumpTarget)
        } else if let node = node as? JumpTargetListNode {
            _ = remove(node: node.jumpParent)
        }

        return remove(node: node)
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

    private func remove(node: Node) -> CommandData {
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

    private func removeLast() -> CommandData {
        assert(!isEmpty)
        return remove(node: last!)
    }
}
