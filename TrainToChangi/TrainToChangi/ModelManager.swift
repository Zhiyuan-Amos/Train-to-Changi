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
    private(set) var userEnteredCommands: [CommandEnum]

    init(levelData: LevelData) {
        userEnteredCommands = []
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

    // MARK - API for GameViewController.

    func addCommand(commandEnum: CommandEnum) {
        userEnteredCommands.append(commandEnum)
    }

    func insertCommand(commandEnum: CommandEnum, atIndex index: Int) {
        userEnteredCommands.insert(commandEnum, at: index)
    }

    // Removes the command at specified Index from userEnteredCommands.
    func removeCommand(fromIndex index: Int) -> CommandEnum {
        return userEnteredCommands.remove(at: index)
    }

    func clearAllCommands() {
        userEnteredCommands.removeAll()
    }

    func loadLevel(levelData: LevelData) {
        levelManager.loadLevel(levelData: levelData)
        userEnteredCommands = []
        levelState = levelManager.level.initialState
    }

    func resetPlayState() {
        levelState = levelManager.level.initialState
    }

    // MARK - API for Logic. Notifies Scene upon execution.

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
