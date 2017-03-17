//
//  ModelManager.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class ModelManager: Model {

    var level: Level
    var levelState: LevelState
    var runState: RunState
    var numSteps: Int
    var programCounter: Int? {
        didSet {
            // Notify UI to move arrow in future.
        }
    }

    init() {
        level = PreloadedLevels.levelOne
        levelState = level.initialState
        runState = .stopped
        numSteps = 0
    }

    var userEnteredCommands: [CommandEnum] {
        return levelState.currentCommands
    }

    var currentInputs: [Int] {
        return levelState.inputs
    }


    var currentOutputs: [Int] {
        return levelState.outputs
    }

    var expectedOutputs: [Int] {
        return level.expectedOutputs
    }

    var currentLevel: Level {
        return level
    }

    // MARK - API for GameViewController.

    func addCommand(commandEnum: CommandEnum) {
        levelState.currentCommands.append(commandEnum)
    }

    func insertCommand(commandEnum: CommandEnum, atIndex index: Int) {
        levelState.currentCommands.insert(commandEnum, at: index)
    }

    // Removes the command at specified Index from userEnteredCommands.
    func removeCommand(fromIndex index: Int) -> CommandEnum {
        return levelState.currentCommands.remove(at: index)
    }

    func clearAllCommands() {
        levelState.currentCommands.removeAll()
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

    private func postMoveNotification(destination: WalkDestination) {
        let notification = Notification(name: Constants.NotificationNames.movePersonInScene,
                                        object: nil,
                                        userInfo: ["destination": destination])
        NotificationCenter.default.post(notification)
    }

}
