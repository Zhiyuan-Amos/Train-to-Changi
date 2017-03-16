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
    private(set) var currentCommands: [CommandType]
    private var outputIndex: Int

    private var _runState: RunState
    var runState: RunState {
        get {
            return _runState
        }
        set {
            _runState = newValue
        }
    }

    // _commandIndex is nil initially i.e there's no arrow pointing at the commands
    private var _commandIndex: Int?
    var commandIndex: Int? {
        get {
            return _commandIndex
        }

        set {
            _commandIndex = newValue
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

    var currentOutput: [Int] {
        return undoStack.top!.output
    }
    var expectedOutput: [Int] {
        return undoStack.top!.expectedOutput
    }

    init(stationName: String) {
        self.stationName = stationName
        currentCommands = [CommandType]()
        undoStack = Stack<StationState>()
        redoStack = Stack<StationState>()
        _runState = RunState.stopped
        outputIndex = 0
        _numSteps = 0

        let initialStationState = getInitialState()
        undoStack.push(initialStationState)
    }

    func undo() -> Bool {
        guard let oldState = undoStack.pop() else {
            return false
        }
        if undoStack.isEmpty {
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "nothingToUndo"), object: nil, userInfo: nil)
        }

        if redoStack.isEmpty {
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "nonEmptyRedoStack"), object: nil, userInfo: nil)
        }
        redoStack.push(oldState)

        return true
    }

    func redo() -> Bool {
        guard let newState = redoStack.pop() else {
            return false
        }
        if redoStack.isEmpty {
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "nothingToRedo"), object: nil, userInfo: nil)
        }

        if undoStack.isEmpty {
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "nonEmptyUndoStack"), object: nil, userInfo: nil)
        }
        undoStack.push(newState)
        return true
    }

    func insertCommand(atIndex: Int, commandType: CommandType) {
        currentCommands.insert(commandType, at: atIndex)
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

    func putValueIntoOutbox(_ value: Int) {
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
