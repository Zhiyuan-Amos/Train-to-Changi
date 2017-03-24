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
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.inbox, CD.outbox, CD.outbox, CD.outbox], "Not appended correctly.")
    }

    // MARK - Append, Jump Command

    func testAppend_emptyListAndJumpCommand_jumpAndTargetAppended() {
        list.append(commandData: .jump)
        XCTAssertEqual(list.toArray(), [CD.placeholder, CD.jump], "Not appended correctly.")
    }

    func testAppend_oneItemListAndJumpCommand() {
        list.append(commandData: .inbox)

        list.append(commandData: .jump)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.placeholder, CD.jump], "Not appended correctly.")
    }

    func testAppend_manyItemsListAndJumpCommand() {
        list.append(commandData: .inbox)
        list.append(commandData: .inbox)
        list.append(commandData: .outbox)
        list.append(commandData: .outbox)

        list.append(commandData: .jump)
        XCTAssertEqual(list.toArray(), [CD.inbox, CD.inbox, CD.outbox, CD.outbox, CD.placeholder, CD.jump], "Not appended correctly.")
    }

    // MARK - Insert, Iterative Command

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

    func testInsert_oneItemIndexTen_insertedAtIndexOne() {

    }

    //cont from here.
    func testInsert_manyItemsList() {

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
        XCTAssertEqual(list.toArray(), [CD.placeholder, CD.jump, CD.inbox], "Not inserted correctly.")
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
        // placeholder here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        list.insert(commandData: .jump, atIndex: 0)
        XCTAssertEqual(list.toArray(),
                       [CD.placeholder, CD.jump, CD.outbox,
                        CD.inbox, CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.placeholder,
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
        // placeholder here
        list.append(commandData: .jump)
        list.append(commandData: .inbox)

        list.insert(commandData: .jump, atIndex: 3)
        XCTAssertEqual(list.toArray(),
                       [CD.outbox, CD.inbox, CD.outbox,
                        CD.placeholder, CD.jump, CD.inbox,
                        CD.outbox, CD.inbox, CD.placeholder,
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
        // placeholder here
        list.append(commandData: .jump)
        list.append(commandData: .inbox) // insert here, index 8

        list.insert(commandData: .jump, atIndex: 8)
        XCTAssertEqual(list.toArray(),
                       [CD.outbox,
                        CD.inbox, CD.outbox, CD.inbox,
                        CD.outbox, CD.inbox, CD.placeholder,
                        CD.jump, CD.placeholder, CD.jump, CD.inbox],
                       "Not inserted correctly.")
    }

    func testInsert_manyItemsListIndexEndPlusOneAndJumpCommand_insertedAtIndexEnd() {

    }
}
