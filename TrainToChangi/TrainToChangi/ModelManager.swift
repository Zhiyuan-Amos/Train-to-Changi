//
//  ModelManager.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class ModelManager: Model {

    private var undoStack: Stack<StationState>
    private var redoStack: Stack<StationState>
    private(set) var commandEnums: [CommandEnum]
    private var outputIndex: Int
    private var level: Level

    private var _runState: RunState
    var runState: RunState {
        get {
            return _runState
        }
        set {
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "runStateUpdated"), object: runState, userInfo: nil)
            _runState = newValue
        }
    }

    // _commandIndex is nil initially i.e there's no arrow pointing at the commands
    private var _programCounter: Int?
    var programCounter: Int? {
        get {
            return _programCounter
        }

        set {
            _programCounter = newValue
        }
    }

    private var _numSteps: Int
    var numSteps: Int {
        get {
            return _numSteps
        }

        set {
            _numSteps = newValue
        }
    }

    var currentInputs: [Int] {
        return undoStack.top!.input.toArray
    }
    var currentOutputs: [Int] {
        return undoStack.top!.output
    }
    var expectedOutputs: [Int] {
        return level.expectedOutput
    }

    init(stationName: String) {
        commandEnums = [CommandEnum]()
        undoStack = Stack<StationState>()
        redoStack = Stack<StationState>()
        _runState = RunState.stopped
        outputIndex = 0
        _numSteps = 0
        level = StorageManager().loadLevel(stationName: "test")

        let initialStationState = level.initialState
        undoStack.push(initialStationState)
    }

    func insertCommand(atIndex: Int, commandEnum: CommandEnum) {
        commandEnums.insert(commandEnum, at: atIndex)
    }

    func removeCommand(fromIndex: Int) {
        commandEnums.remove(at: fromIndex)
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

    func prependValueIntoInbox(_ value: Int) {
    }

    func popValueFromOutbox() {
    }

    func appendValueIntoOutbox(_ value: Int) {
        guard let topStation = undoStack.top else {
            return
        }

        var newStation = StationState(station: topStation)
        newStation.output.append(value)
        undoStack.push(newStation)
        outputIndex += 1
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

    func putValueIntoMemory(_ value: Int?, at index: Int) {
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
}
