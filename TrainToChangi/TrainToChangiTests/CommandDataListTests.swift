//
//  CommandDataListTests.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 23/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import XCTest
@testable import TrainToChangi

class CommandDataListTests: XCTestCase {
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
        XCTAssertEqual(list.toArray(), [CD.jumpTargetPlaceholder, CD.jump], "Not appended correctly.")
    }

    func testAppend_oneItemListAndJumpCommand() {
        list.append(commandData: .inbox)

        list.append(commandData: .jump)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.jumpTargetPlaceholder, CD.jump], "Not appended correctly.")
    }

    func testAppend_manyItemsListAndJumpCommand() {
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .outbox)

        list.append(commandData: .jump)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.inbox, CD.outbox,
                                        CD.outbox, CD.jumpTargetPlaceholder, CD.jump], "Not appended correctly.")
    }

    // MARK - Insert, Iterative Command
    // List length [{0,1}, {>1}]
    // Insert location [negative, start, middle, end, afterEnd]
    // Command Type [Iterative, Jump]

    func testInsert_emptyListNegativeIndex_notInserted() {

    }

    func testInsert_nonEmptyListNegativeIndex_notInserted() {

    }

    func testInsert_emptyListIndexZero_insertedAtIndexZero() {

    }

    func testInsert_emptyListIndexOne_insertedAtIndexZero() {

    }

    func testInsert_emptyListIndexTen_insertedAtIndexZero() {

    }

    func testInsert_oneItemListIndexZero_insertedAtIndexZero() {
        list.append(commandData: .inbox)

    }

    func testInsert_oneItemListIndexOne_insertedAtIndexOne() {

    }

    func testInsert_oneItemListIndexTwo_insertedAtIndexOne() {

    }

    func testInsert_oneItemListIndexTen_insertedAtIndexOne() {

    }

    func testInsert_manyItemsListIndexZero() {

    }

    func testInsert_manyItemsListIndexCountMinusOne() {

    }

    func testInsert_manyItemsListIndexEnd() {

    }

    func testInsert_manyItemsListIndexEndPlusOne() {

    }

    func testInsert_manyItemsListIndexGreaterThanEnd() {

    }


    // Mark - Insert, Jump Command

    func testInsert_emptyListNegativeIndexAndJumpCommand_notInserted() {

    }

    func testInsert_nonEmptyListNegativeIndexAndJumpCommand_notInserted() {

    }

    func testInsert_emptyListIndexZeroAndJumpCommand_insertedAtIndexZero() {

    }

    func testInsert_emptyListIndexOneAndJumpCommand_insertedAtIndexZero() {

    }

    func testInsert_emptyListIndexTenAndJumpCommand_insertedAtIndexZero() {

    }

    func testInsert_oneItemListIndexZeroAndJumpCommand_insertedAtIndexZero() {
        list.append(commandData: .inbox)

        list.insert(commandData: .jump, atIndex: 0)
        XCTAssertEqual(list.toArray(), [CD.jumpTargetPlaceholder, CD.jump, CD.inbox], "Not inserted correctly.")
    }

    func testInsert_oneItemListIndexOneAndJumpCommand_insertedAtIndexOne() {

    }

    func testInsert_oneItemListIndexTwoAndJumpCommand_insertedAtIndexOne() {

    }

    func testInsert_oneItemIndexTenAndJumpCommand_insertedAtIndexOne() {

    }

    func testInsert_manyItemsListIndexStartAndJumpCommand_insertedAtIndexStart() {
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
                       [CD.jumpTargetPlaceholder, CD.jump, CD.outbox,
                        CD.inbox, CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.jumpTargetPlaceholder,
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
                        CD.jumpTargetPlaceholder, CD.jump, CD.inbox,
                        CD.outbox, CD.inbox, CD.jumpTargetPlaceholder,
                        CD.jump, CD.inbox],
                       "Not inserted correctly.")
    }

    func testInsert_manyItemsListIndexEndAndJumpCommand_insertedAtIndexEnd() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox) // insert here, index 8

        list.insert(commandData: .jump, atIndex: 8)
        XCTAssertEqual(list.toArray(),
                       [CD.outbox,
                        CD.inbox, CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.jumpTargetPlaceholder,
                        CD.jump, CD.jumpTargetPlaceholder, CD.jump, CD.inbox],
                       "Not inserted correctly.")
    }

    func testInsert_manyItemsListIndexEndPlusOneAndJumpCommand_insertedAtIndexEnd() {

    }

    // MARK -  Remove, Iterative Command
    // List length [{0,1}, {>1}]
    // Remove location [negative, start, middle, end, afterEnd]
    // Command Type [Iterative, Jump, JumpTarget]
    // Integration test: Remove after moving.

    func testRemove_iterativeCommand() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox) // Remove index 1
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        let removed = list.remove(atIndex: 1)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox,
                        CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.jumpTargetPlaceholder,
                        CD.jump, CD.inbox],
                       "Not removed correctly.")
        XCTAssertEqual(removed, CD.inbox, "Removed item is not correct.")
    }

    // MARK - Remove, Jump Command

    func testRemove_jumpCommand() {
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

    func testRemove_jumpCommandAfterJumpMoved() {

    }


    func testRemove_jumpCommandAfterTargetMoved() {

    }

    // MARK - Remove, JumpTarget Command

    func testRemove_jumpTargetCommand() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        // jumpTarget here               // remove index 6
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        let removed = list.remove(atIndex: 6)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.inbox],
                       "Not removed correctly.")
        XCTAssertEqual(removed, CD.jumpTargetPlaceholder, "Removed item is not correct.")

        // move and retest
    }

    // MARK - Move, Iterative Command
    // List length [{0,1}, {>1}]
    // Move from [negative, start, middle, end, afterEnd]
    // Move to [negative, start, middle, end, afterEnd, special case: same location]
    // Command Type [Iterative, Jump, JumpTarget]

    func testMove_iterativeCommandMoveDown() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox) // move index 1
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox) // to index 4
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        list.move(sourceIndex: 1, destIndex: 4)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.outbox,
                        CD.inbox, CD.outbox, CD.inbox,
                        CD.inbox, CD.jumpTargetPlaceholder, CD.jump, CD.inbox],
                       "Not removed correctly.")

        // move same location, move to lower index..
    }

    func testMove_iterativeCommandMoveUp() {
        list.append(commandData: .outbox)
        list.append(commandData: .inbox) // to index 1
        list.append(commandData: .outbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox) // move index 4
        list.append(commandData: .inbox)
        // jumpTarget here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        list.move(sourceIndex: 4, destIndex: 1)

        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.outbox, CD.inbox, CD.outbox,
                        CD.inbox, CD.inbox,
                        CD.jumpTargetPlaceholder, CD.jump, CD.inbox],
                       "Not removed correctly.")

        // move same location, move to lower index..
    }


    // MARK - Move, Jump Command

    func testMove_jumpCommand() {

    }

    // MARK - Move, JumpTarget Command

    func testMove_jumpTargetCommand() {

    }

    // MARK - removeAll
    // List length [{0,1}, {>1}]
    // List contains mixture of Command Types [Iterative, Jump, JumpTarget]

    func testRemoveAll_emptyList() {

    }

    // MARK - toArray
    // List length [{0,1}, {>1}]
    // List contains mixture of Command Types [Iterative, Jump, JumpTarget]

}
