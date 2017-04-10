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
        // State machine
        set(newState) {
            switch runState {
            case .running, .paused, .start:
                levelState.runState = newState
            case .won:
                // when game is won, user should not be allowed to set the `runState`
                // to `.running`, `.paused` or `.lost`
                break
            case .lost:
                switch newState {
                case .paused, .stepping(isAnimating: false):
                    levelState.runState = newState
                default:
                    break
                }
            case .stepping:
                switch newState {
                case .running:
                    break
                default:
                    levelState.runState = newState
                }
            }

            let notification = Notification(name: Constants.NotificationNames.runStateUpdated,
                                            object: newState, userInfo: nil)
            NotificationCenter.default.post(notification)
        }
    }
    var numSteps: Int {
        get {
            return levelState.numSteps
        }
        set {
            levelState.numSteps = newValue
        }
    }

    private var levelManager: LevelManager
    private var _userEnteredCommands: CommandDataList

    let currentLevelIndex: Int

    init(levelIndex: Int, levelData: LevelData) {
        _userEnteredCommands = CommandDataLinkedList()
        currentLevelIndex = levelIndex
        levelManager = LevelManager(levelData: levelData)
        levelState = levelManager.level.initialState
    }

    func loadCommandDataListInfo(commandDataListInfo: CommandDataListInfo) {
        _userEnteredCommands = CommandDataLinkedList(commandDataListInfo: commandDataListInfo)
        postCommandDataListUpdateNotification()
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

    var userEnteredCommandsAsListInfo: CommandDataListInfo {
        return _userEnteredCommands.asListInfo()
    }

    // MARK - API for GameViewController.

    func addCommand(commandEnum: CommandData) {
        _userEnteredCommands.append(commandData: commandEnum)
        postCommandDataListUpdateNotification()
    }

    func insertCommand(commandEnum: CommandData, atIndex index: Int) {
        _userEnteredCommands.insert(commandData: commandEnum, atIndex: index)
        postCommandDataListUpdateNotification()
    }

    // Removes the command at specified Index from userEnteredCommands.
    func removeCommand(fromIndex index: Int) -> CommandData {
        let commandData = _userEnteredCommands.remove(atIndex: index)
        postCommandDataListUpdateNotification()
        return commandData
    }

    func moveCommand(fromIndex: Int, toIndex: Int) {
        _userEnteredCommands.move(sourceIndex: fromIndex, destIndex: toIndex)
        postCommandDataListUpdateNotification()
    }

    func clearAllCommands() {
        _userEnteredCommands.removeAll()
        postCommandDataListUpdateNotification()
    }

    func resetPlayState() {
        let numLost = levelState.numLost
        levelState = levelManager.level.initialState
        levelState.numLost = numLost
    }

    func getCommandDataListInfo() -> CommandDataListInfo {
        return _userEnteredCommands.asListInfo()
    }

    // MARK - API for Logic.

    func makeCommandDataListIterator() -> CommandDataListIterator {
        return _userEnteredCommands.makeIterator()
    }

    func dequeueValueFromInbox() -> Int? {
        guard !levelState.inputs.isEmpty else {
            return nil
        }

        let dequeuedValue = levelState.inputs.removeFirst()
        return dequeuedValue
    }

    func prependValueIntoInbox(_ value: Int) {
        levelState.inputs.insert(value, at: 0)
    }

    func appendValueIntoOutbox(_ value: Int) {
        levelState.outputs.append(value)
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

    func incrementNumLost() {
        levelState.numLost += 1
    }

    // API for Achievement
    func getTimeElapsed() -> Double {
        return levelState.timeElapsed
    }

    func getNumLost() -> Int {
        return levelState.numLost
    }

    // MARK - Private helpers

    private func postCommandDataListUpdateNotification() {
        let notification = Notification(name: Constants.NotificationNames.commandDataListUpdate,
                                        object: nil,
                                        userInfo: ["levelIndex": currentLevelIndex,
                                                   "commandDataListInfo": userEnteredCommandsAsListInfo])
        NotificationCenter.default.post(notification)
    }

}
