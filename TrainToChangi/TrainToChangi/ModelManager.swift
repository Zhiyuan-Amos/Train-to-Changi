//
//  ModelManager.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class ModelManager: Model {

    var levelState: LevelState

    var runState: RunState {
        get {
            return levelState.runState
        }
        set(newState) {
            levelState.runState = newState
        }
    }
    var numSteps: Int {
        get {
            return levelState.numSteps
        }
        set(newValue) {
            levelState.numSteps = newValue
        }
    }

    // TO remove after integration with Logic!!
    var programCounter: Int? {
        get {
            return levelState.programCounter
        }
        set(newValue) {
            //notify UI
            levelState.programCounter = newValue
        }
    }

    private var levelManager: LevelManager
    private var _userEnteredCommands: CommandDataList

    init(levelData: LevelData) {
        _userEnteredCommands = CommandDataLinkedList()
        levelManager = LevelManager(levelData: levelData)
        levelState = levelManager.level.initialState
    }

    var currentInputs: [Int] {
        return levelState.inputs
    }

    var currentOutputs: [Int] {
        return levelState.outputs
    }

    var expectedOutputs: [Int] {
        return levelManager.level.expectedOutputs
    }

    var currentLevel: Level {
        return levelManager.level
    }

    var userEnteredCommands: [CommandData] {
        return _userEnteredCommands.toArray()
    }

    // MARK - API for GameViewController.

    func addCommand(commandEnum: CommandData) {
        _userEnteredCommands.append(commandData: commandEnum)
    }

    func insertCommand(commandEnum: CommandData, atIndex index: Int) {
        _userEnteredCommands.insert(commandData: commandEnum, atIndex: index)
    }

    // Removes the command at specified Index from userEnteredCommands.
    func removeCommand(fromIndex index: Int) -> CommandData {
        return _userEnteredCommands.remove(atIndex: index)
    }

    func clearAllCommands() {
        _userEnteredCommands.removeAll()
    }

    func resetPlayState() {
        levelState = levelManager.level.initialState
    }

    // MARK - API for Logic.

    func makeCommandDataListIterator() -> CommandDataListIterator {
        return _userEnteredCommands.makeIterator()
    }

    func dequeueValueFromInbox() -> Int? {
        let dequeuedValue = levelState.inputs.removeFirst()
        postMoveNotification(destination: .inbox)
        return dequeuedValue
    }

    func prependValueIntoInbox(_ value: Int) {
        levelState.inputs.insert(value, at: 0)
    }

    func appendValueIntoOutbox(_ value: Int) {
        levelState.outputs.append(value)
        postMoveNotification(destination: .outbox)
    }

    func popValueFromOutbox() {
        levelState.outputs.removeLast()
    }

    func getValueOnPerson() -> Int? {
        return levelState.personValue
    }

    func updateValueOnPerson(to newValue: Int?) {
        levelState.personValue = newValue
    }

    func putValueIntoMemory(_ value: Int?, at index: Int) {
        levelState.memoryValues[index] = value
    }

    func getValueFromMemory(at index: Int) -> Int? {
        return levelState.memoryValues[index]
    }

    // MARK - Private helpers

    private func postMoveNotification(destination: WalkDestination) {
        let notification = Notification(name: Constants.NotificationNames.movePersonInScene,
                                        object: nil,
                                        userInfo: ["destination": destination])
        NotificationCenter.default.post(notification)
    }

}
