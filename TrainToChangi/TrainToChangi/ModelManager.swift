//
//  ModelManager.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class ModelManager {

    internal var level: Level

    internal var gameStateManager: GameStateManager
    internal var runState: RunState

    internal var currentCommands: [CommandEnum]

    // _commandIndex is nil initially i.e there's no arrow pointing at the commands
    internal var commandIndex: Int?
    internal var numSteps: Int

    init(stationName: String) {
        level = StorageManager().loadLevel(stationName: "test")

        gameStateManager = GameStateManager(initialState: StationState(input: level.input))
        runState = RunState.stopped

        currentCommands = [CommandEnum]()
        numSteps = 0
    }

}

extension ModelManager: RunStateDelegate {
    func getRunState() -> RunState {
        return runState
    }

    func setRunState(to newRunState: RunState) {
        runState = newRunState
    }
}

extension ModelManager: Model {

    func getCurrentCommands() -> [CommandEnum] {
        return getCurrentCommands()
    }

    func getCurrentInput() -> [Int] {
        return gameStateManager.getCurrentState().input
    }

    func getCurrentOutput() -> [Int] {
        return gameStateManager.getCurrentState().output
    }

    func getExpectedOutput() -> [Int] {
        return level.expectedOutput
    }

    func getCommandIndex() -> Int? {
        return commandIndex
    }

    func setCommandIndex(to newIndex: Int?) {
        commandIndex = newIndex
    }

    func getNumSteps() -> Int {
        return numSteps
    }

    func insertCommand(atIndex: Int, commandEnum: CommandEnum) {
        currentCommands.insert(commandEnum, at: atIndex)
    }

    func removeCommand(fromIndex: Int) {
        currentCommands.remove(at: fromIndex)
    }

    func dequeueValueFromInbox() -> Int? {
        var newStationState = StationState(station: gameStateManager.getCurrentState())
        let valueToReturn = newStationState.input.removeFirst()
        gameStateManager.update(newStationState: newStationState)
        return valueToReturn
    }

    func insertValueIntoInbox(_ value: Int, at index: Int) {
        var newStationState = StationState(station: gameStateManager.getCurrentState())
        newStationState.input.insert(value, at: 0)
        gameStateManager.update(newStationState: newStationState)
    }

    func putValueIntoOutbox(_ value: Int) {
        var newStationState = StationState(station: gameStateManager.getCurrentState())
        newStationState.output.append(value)
    }

    func takeValueOutOfOutbox() {
        var newStationState = StationState(station: gameStateManager.getCurrentState())
        newStationState.output.removeLast()
        gameStateManager.update(newStationState: newStationState)
    }

    func getValueOnPerson() -> Int? {
        return gameStateManager.getCurrentState().personValue
    }

    func updateValueOnPerson(to newValue: Int?) {
        var newStationState = StationState(station: gameStateManager.getCurrentState())
        newStationState.personValue = newValue
        gameStateManager.update(newStationState: newStationState)
    }

    func putValueIntoMemory(_ value: Int?, at index: Int) {
        var newStationState = StationState(station: gameStateManager.getCurrentState())
        newStationState.memoryValues[index] = value
        gameStateManager.update(newStationState: newStationState)
    }

    func getValueFromMemory(at index: Int) -> Int? {
        return gameStateManager.getCurrentState().memoryValues[index]
    }

}
