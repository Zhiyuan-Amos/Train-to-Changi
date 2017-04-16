//
//  CommandDataListTests.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 23/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import XCTest
@testable import TrainToChangi

// swiftlint:disable type_body_length
class CommandDataListTests: XCTestCase {
// swiftlint:enable type_body_length

    typealias CD = CommandData
    private var list: CommandDataList!

    override func setUp() {
        super.setUp()
        list = CommandDataLinkedList()
    }

    // MARK - Append, Iterative Command
    // List length [{0,1}, {>1}]
    // Command Type [Iterative, Jump]

    func testAppend_emptyListAndIterativeCommand() {
        list.append(commandData: .inbox)
        XCTAssertEqual(list.toArray(), [CD.inbox], "Not appended correctly.")
    }

    func testAppend_oneItemListAndIterativeCommand() {
        list.append(commandData: .inbox)

        list.append(commandData: .outbox)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.outbox], "Not appended correctly.")
    }

    func testAppend_manyItemsListAndIterativeCommand() {
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .outbox)

        list.append(commandData: .outbox)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.inbox, CD.outbox,
                                        CD.outbox, CD.outbox], "Not appended correctly.")
    }

    // MARK - Append, Jump Command

    func testAppend_emptyListAndJumpCommand_jumpAndTargetAppended() {
        list.append(commandData: .jump)
        XCTAssertEqual(list.toArray(), [CD.jumpTarget, CD.jump], "Not appended correctly.")
    }

    func testAppend_oneItemListAndJumpCommand() {
        list.append(commandData: .inbox)

        list.append(commandData: .jump)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.jumpTarget, CD.jump], "Not appended correctly.")
    }

    func testAppend_manyItemsListAndJumpCommand() {
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .outbox)

        list.append(commandData: .jump)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.inbox, CD.outbox,
                                        CD.outbox, CD.jumpTarget, CD.jump], "Not appended correctly.")
    }

    // MARK - Insert, Iterative Command
    // List length [{0,1}, {>1}]
    // Insert location [start, middle, count]
    // Command Type [Iterative, Jump]

    func testInsert_emptyListIndexZero_insertedAtIndexZero() {
        list.insert(commandData: .inbox, atIndex: 0)
        XCTAssertEqual(list.toArray(), [CD.inbox], "Not inserted correctly.")
    }

    func testInsert_oneItemListIndexZero_insertedAtIndexZero() {
        list.append(commandData: .inbox)
        list.insert(commandData: .outbox, atIndex: 0)
        XCTAssertEqual(list.toArray(), [CD.outbox, CD.inbox], "Not inserted correctly.")
    }

    func testInsert_oneItemListIndexOne_insertedAtIndexOne() {
        list.append(commandData: .inbox)
        list.insert(commandData: .outbox, atIndex: 1)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.outbox], "Not inserted correctly.")
    }

    func testInsert_manyItemsListIndexZero() {
        list.append(commandData: .inbox) // Insert here, index 0
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)

        list.insert(commandData: .outbox, atIndex: 0)
        XCTAssertEqual(list.toArray(), [CD.outbox, CD.inbox, CD.inbox,
                                        CD.inbox, CD.inbox, CD.inbox], "Not inserted correctly.")
    }

    func testInsert_manyItemsListIndexMiddle() {
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        list.append(commandData: .inbox) // Insert here, index 2
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)

        list.insert(commandData: .outbox, atIndex: 2)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.inbox, CD.outbox,
                                        CD.inbox, CD.inbox, CD.inbox], "Not inserted correctly.")
    }

    func testInsert_manyItemsListIndexCount() {
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        // Insert here, index 5

        list.insert(commandData: .outbox, atIndex: 5)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.inbox, CD.inbox,
                                        CD.inbox, CD.inbox, CD.outbox], "Not inserted correctly.")
    }

    // Mark - Insert, Jump Command

    func testInsert_emptyListIndexZeroAndJumpCommand_insertedAtIndexZero() {
        list.insert(commandData: .jump, atIndex: 0)
        XCTAssertEqual(list.toArray(), [CD.jumpTarget, CD.jump], "Not inserted correctly.")
    }

    func testInsert_oneItemListIndexZeroAndJumpCommand_insertedAtIndexZero() {
        list.append(commandData: .inbox)

        list.insert(commandData: .jump, atIndex: 0)
        XCTAssertEqual(list.toArray(), [CD.jumpTarget, CD.jump, CD.inbox], "Not inserted correctly.")
    }

    func testInsert_oneItemListIndexOneAndJumpCommand_insertedAtIndexOne() {
        list.append(commandData: .inbox)

        list.insert(commandData: .jump, atIndex: 1)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.jumpTarget, CD.jump], "Not inserted correctly.")
    }

    func testInsert_manyItemsListIndexZeroAndJumpCommand_insertedAtIndexZero() {
        list.append(commandData: .outbox) // insert here, index 0
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        list.insert(commandData: .jump, atIndex: 0)
        XCTAssertEqual(list.toArray(),
                       [CD.jumpTarget, CD.jump, CD.outbox,
                        CD.inbox, CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.jumpTarget,
                        CD.jump, CD.inbox],
                       "Not inserted correctly.")
    }

    func testInsert_manyItemsListIndexMiddleAndJumpCommand_insertedAtIndexMiddle() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox) // insert here, index 3
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        list.insert(commandData: .jump, atIndex: 3)
        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.inbox, CD.outbox,
                        CD.jumpTarget, CD.jump, CD.inbox,
                        CD.outbox, CD.inbox, CD.jumpTarget,
                        CD.jump, CD.inbox],
                       "Not inserted correctly.")
    }

    func testInsert_manyItemsListIndexCountAndJumpCommand_insertedAtIndexCount() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)
         // insert here, index 9

        list.insert(commandData: .jump, atIndex: 9)
        XCTAssertEqual(list.toArray(),
                       [CD.outbox,
                        CD.inbox, CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.jumpTarget,
                        CD.jump, CD.inbox, CD.jumpTarget, CD.jump],
                       "Not inserted correctly.")

    }

    // MARK -  Remove, Iterative Command
    // List length [{1}, {>1}]
    // Remove location [start, middle, end]
    // Command Type [Iterative, Jump, JumpTarget]

    func testRemove_oneItemListIndexZero() {
        list.append(commandData: .inbox)
        let removedItem = list.remove(atIndex: 0)
        XCTAssertEqual(list.toArray(), [], "Not removed correctly.")
        XCTAssertEqual(removedItem, CD.inbox, "Removed item is not correct.")
    }

    func testRemove_manyItemsListIndexZero() {
        list.append(commandData: .inbox) // Remove here, index 0
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)

        let removedItem = list.remove(atIndex: 0)
        XCTAssertEqual(list.toArray(), [CD.outbox, CD.inbox, CD.outbox,
                                        CD.inbox], "Not removed correctly.")
        XCTAssertEqual(removedItem, CD.inbox, "Removed item is not correct.")
    }

    func testRemove_manyItemsListIndexMiddle() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox) // Remove index 1
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        let removedItem = list.remove(atIndex: 1)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox,
                        CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.jumpTarget,
                        CD.jump, CD.inbox],
                       "Not removed correctly.")
        XCTAssertEqual(removedItem, CD.inbox, "Removed item is not correct.")
    }

    func testRemove_manyItemsListIndexEnd() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox) // Remove index 8

        let removedItem = list.remove(atIndex: 8)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.jumpTarget,
                        CD.jump],
                       "Not removed correctly.")
        XCTAssertEqual(removedItem, CD.inbox, "Removed item is not correct.")
    }

    // MARK - Remove, Jump and JumpTarget Commands

    func testRemove_oneItemListIndexOneAndJumpCommand() {
        list.append(commandData: .jump)
        let removedItem = list.remove(atIndex: 1)
        XCTAssertEqual(list.toArray(), [], "Not removed correctly.")
        XCTAssertEqual(removedItem, CD.jump, "Removed item is not correct.")
    }

    func testRemove_oneItemListIndexZeroAndJumpTargetCommand() {
        list.append(commandData: .jump)
        let removedItem = list.remove(atIndex: 0)
        XCTAssertEqual(list.toArray(), [], "Not removed correctly.")
        XCTAssertEqual(removedItem, CD.jumpTarget, "Removed item is not correct.")
    }

    func testRemove_manyItemsListIndexOneAndJumpCommand() {
        // JumpTarget here
        list.append(commandData: .jump) // Remove here, index 1
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)

        let removedItem = list.remove(atIndex: 1)
        XCTAssertEqual(list.toArray(), [CD.outbox, CD.inbox, CD.outbox,
                                        CD.inbox], "Not removed correctly.")
        XCTAssertEqual(removedItem, CD.jump, "Removed item is not correct.")
    }

    func testRemove_manyItemsListIndexZeroAndJumpTargetCommand() {
        // JumpTarget here                // Remove here, index 0
        list.append(commandData: .jump)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)

        let removedItem = list.remove(atIndex: 0)
        XCTAssertEqual(list.toArray(), [CD.outbox, CD.inbox, CD.outbox,
                                        CD.inbox], "Not removed correctly.")
        XCTAssertEqual(removedItem, CD.jumpTarget, "Removed item is not correct.")
    }

    func testRemove_manyItemsListIndexMiddleAndJumpCommand() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump) // remove index 7
        list.append(commandData: .inbox)

        let removed = list.remove(atIndex: 7)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.inbox],
                       "Not removed correctly.")
        XCTAssertEqual(removed, CD.jump, "Removed item is not correct.")
    }

    func testRemove_manyItemsListIndexMiddleAndJumpTargetCommand() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here              // remove index 6
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        let removed = list.remove(atIndex: 6)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.inbox],
                       "Not removed correctly.")
        XCTAssertEqual(removed, CD.jumpTarget, "Removed item is not correct.")
    }

    func testRemove_manyItemsListIndexEndAndJumpCommand() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump) // Remove index 7

        let removedItem = list.remove(atIndex: 7)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox],
                       "Not removed correctly.")
        XCTAssertEqual(removedItem, CD.jump, "Removed item is not correct.")
    }

    // MARK - Move
    // List length [{1}, {>1}]
    // Move from [start, middle, end]
    // Move to [start, middle, end, special case: same location]

    func testMove_oneItemListMoveSameIndex() {
        list.append(commandData: .inbox)
        list.move(sourceIndex: 0, destIndex: 0)
        XCTAssertEqual(list.toArray(),
                       [CD.inbox],
                       "List should remain the same.")
    }

    func testMove_ManyItemListMoveStartToMiddle() {
        list.append(commandData: .outbox) // move index 0
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox) // to index 4
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        list.move(sourceIndex: 0, destIndex: 4)

        XCTAssertEqual(list.toArray(),
                       [CD.inbox, CD.outbox,
                        CD.inbox, CD.outbox, CD.outbox, CD.inbox,
                        CD.jumpTarget, CD.jump, CD.inbox],
                       "Not moved correctly.")
    }

    func testMove_ManyItemListMoveStartToEnd() {
        list.append(commandData: .outbox) // move index 0
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox) // to index 8

        list.move(sourceIndex: 0, destIndex: 8)

        XCTAssertEqual(list.toArray(),
                       [CD.inbox, CD.outbox,
                        CD.inbox, CD.outbox, CD.inbox,
                        CD.jumpTarget, CD.jump, CD.inbox, CD.outbox],
                       "Not moved correctly.")
    }

    func testMove_ManyItemListMoveMiddleToStart() {
        list.append(commandData: .outbox) // to index 0
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox) // move index 4
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        list.move(sourceIndex: 4, destIndex: 0)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.outbox, CD.inbox, CD.outbox,
                        CD.inbox, CD.inbox,
                        CD.jumpTarget, CD.jump, CD.inbox],
                       "Not moved correctly.")
    }

    func testMove_ManyItemListMoveMiddleToEnd() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox) // move index 4
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox) // to index 8

        list.move(sourceIndex: 4, destIndex: 8)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox,
                        CD.inbox, CD.jumpTarget,
                        CD.jump, CD.inbox, CD.outbox],
                       "Not moved correctly.")
    }

    func testMove_ManyItemListMoveEndToStart() {
        list.append(commandData: .outbox) // to index 0
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox) // move index 8

        list.move(sourceIndex: 8, destIndex: 0)

        XCTAssertEqual(list.toArray(),
                       [CD.inbox, CD.outbox,
                        CD.inbox, CD.outbox, CD.inbox, CD.outbox, CD.inbox,
                        CD.jumpTarget, CD.jump],
                       "Not moved correctly.")
    }

    func testMove_ManyItemListMoveEndToMiddle() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox) // to index 4
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox) // move index 8

        list.move(sourceIndex: 8, destIndex: 4)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.inbox, CD.outbox,
                        CD.inbox, CD.jumpTarget,
                        CD.jump],
                       "Not moved correctly.")
    }

    // MARK - removeAll

    func testRemoveAll_oneItemList() {
        list.append(commandData: .inbox)
        list.removeAll()
        XCTAssertEqual(list.toArray(),
                       [],
                       "Not removed correctly.")
    }

    func testRemoveAll_manyItemsList() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        list.removeAll()
        XCTAssertEqual(list.toArray(),
                       [],
                       "Not removed correctly.")
    }
}
