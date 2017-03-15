//
//  ModelManager.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class ModelManager: Model {

    private var stationName: String
    private var undoStack: Stack<StationState>
    private var redoStack: Stack<StationState>
    private var currentCommands: [Command]
    private var runState: RunState
    private var outputIndex: Int

    init(stationName: String) {
        self.stationName = stationName
        currentCommands = [Command]()
        undoStack = Stack<StationState>()
        redoStack = Stack<StationState>()
        runState = RunState.stopped
        outputIndex = 0

        let initialStationState = getInitialState()
        undoStack.push(initialStationState)
    }

    func undo() -> Bool {
        guard let oldState = undoStack.pop() else {
            return false
        }
        redoStack.push(oldState)
        return true
    }

    func redo() -> Bool {
        guard let newState = redoStack.pop() else {
            return false
        }
        undoStack.push(newState)
        return true
    }

    func getRunState() -> RunState {
        return runState
    }

    func updateRunState(to newState: RunState) {
        runState = newState
    }

    func getCurrentCommands() -> [Command] {
        return currentCommands
    }

    func insertCommand(atIndex: Int, command: Command) {
        currentCommands.insert(command, at: atIndex)
    }

    func removeCommand(fromIndex: Int) {
        currentCommands.remove(at: fromIndex)
    }

    func dequeueValueFromInbox() -> Int? {
        guard let topStation = undoStack.top else {
            return nil
        }

        var newStation = StationState(station: topStation)
        let valueToReturn = newStation.input.dequeue()
        undoStack.push(newStation)
        return valueToReturn
    }

    func putValueIntoOutbox(_ value: Int) -> Bool {
        guard let topStation = undoStack.top else {
            return false
        }

        var newStation = StationState(station: topStation)
        if newStation.expectedOutput[outputIndex] == value {
            newStation.output.append(value)
            undoStack.push(newStation)
            outputIndex += 1
            return true
        }
        return false
    }

    func getValueOnPerson() -> Int? {
        return undoStack.top?.person.getHoldingValue()
    }

    func updateValueOnPerson(to newValue: Int?) {
        guard let topStation = undoStack.top else {
            return
        }

        let newStation = StationState(station: topStation)
        newStation.person.setHoldingValue(to: newValue)
        undoStack.push(newStation)
    }

    func putValueIntoMemory(_ value: Int, at index: Int) {
        guard let topStation = undoStack.top else {
            return
        }

        var newStation = StationState(station: topStation)
        newStation.memoryValues[index] = value
        undoStack.push(newStation)
    }

    func getValueFromMemory(at index: Int) -> Int? {
        guard let topStation = undoStack.top else {
            return nil
        }

        var newStation = StationState(station: topStation)
        return newStation.memoryValues[index]
    }

    // TODO - integrate this with StorageManager
    private func getInitialState() -> StationState {
        return StationState(input: Queue<Int>(), output: [Int](), expectedOutput: [Int](), memoryValues: [Int?]())
    }
}
