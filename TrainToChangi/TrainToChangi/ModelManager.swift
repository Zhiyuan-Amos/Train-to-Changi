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

    init(stationName: String) throws {
        self.stationName = stationName
        currentCommands = [Command]()
        undoStack = Stack<StationState>()
        redoStack = Stack<StationState>()
        runState = RunState.stopped

        let initialStationState = getInitialState()
        undoStack.push(initialStationState)
    }

    func undo() throws {
        guard let oldState = undoStack.pop() else {
            throw ModelError.emptyStack
        }
        redoStack.push(oldState)
    }

    func redo() throws {
        guard let newState = redoStack.pop() else {
            throw ModelError.emptyStack
        }
        undoStack.push(newState)
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

    func insertCommand(atIndex: Int, command: Command) throws {
        guard atIndex >= 0 && atIndex <= currentCommands.count else {
            throw ModelError.invalidIndex
        }
        currentCommands.insert(command, at: atIndex)
    }

    func removeCommand(fromIndex: Int) throws {
        guard fromIndex >= 0 && fromIndex < currentCommands.count else {
            throw ModelError.invalidIndex
        }

        currentCommands.remove(at: fromIndex)
    }

    func dequeueValueFromInbox() throws {
        guard let topStation = undoStack.top else {
            throw ModelError.emptyStack
        }

        if topStation.person.getHoldingValue() != nil {
            throw ModelError.personValueNotEmpty
        }

        var newStation = StationState(station: topStation)
        guard let newValue = newStation.input.dequeue() else {
            throw ModelError.emptyQueue
        }

        newStation.person.setHoldingValue(to: newValue)
        undoStack.push(newStation)
    }

    func putValueIntoOutbox() throws {
        guard let topStation = undoStack.top else {
            throw ModelError.emptyStack
        }

        guard let personValue = topStation.person.getHoldingValue() else {
            throw ModelError.emptyPersonValue
        }

        var newStation = StationState(station: topStation)
        newStation.output.append(personValue)
        newStation.person.setHoldingValue(to: nil)
        undoStack.push(newStation)
    }

    func getValueOnPerson() -> Int? {
        return undoStack.top?.person.getHoldingValue()
    }

    func updateValueOnPerson(to newValue: Int?) throws {
        guard let topStation = undoStack.top else {
            throw ModelError.emptyStack
        }

        let newStation = StationState(station: topStation)
        newStation.person.setHoldingValue(to: newValue)
        undoStack.push(newStation)
    }

    func putValueIntoMemory(location: Int) throws {
        guard let topStation = undoStack.top else {
            throw ModelError.emptyStack
        }

        guard location >= 0 && location < topStation.memoryValues.count else {
            throw ModelError.invalidIndex
        }

        if topStation.memoryValues[location] != nil {
            throw ModelError.memoryLocationNotEmpty
        }

        guard let personValue = topStation.person.getHoldingValue() else {
            throw ModelError.emptyPersonValue
        }

        var newStation = StationState(station: topStation)
        newStation.memoryValues[location] = personValue
        newStation.person.setHoldingValue(to: nil)
        undoStack.push(newStation)
    }

    func getValueFromMemory(location: Int) throws {
        guard let topStation = undoStack.top else {
            throw ModelError.emptyStack
        }

        if topStation.person.getHoldingValue() != nil {
            throw ModelError.personValueNotEmpty
        }

        guard location >= 0 && location < topStation.memoryValues.count else {
            throw ModelError.invalidIndex
        }

        if topStation.memoryValues[location] == nil {
            throw ModelError.emptyMemoryLocation
        }

        var newStation = StationState(station: topStation)
        newStation.person.setHoldingValue(to: newStation.memoryValues[location])
        newStation.memoryValues[location] = nil
        undoStack.push(newStation)
    }

    // TODO @Desmond
    func getValueFromMemoryWithoutTransfer(location: Int) -> Int? {
        guard location >= 0 && location < undoStack.top!.memoryValues.count else {
            fatalError("Array out of bounds")
        }

        return undoStack.top?.memoryValues[location]
    }

    // TODO - integrate this with StorageManager
    private func getInitialState() -> StationState {
        return StationState(input: Queue<Int>(), output: [Int](), memoryValues: [Int?]())
    }

}

/**
 An enum of errors that can be thrown from ModelManager
 */
enum ModelError: Error {
    /// Thrown when unable to initialise model from station name
    case invalidStationName

    /// Thrown when accessing an invalid index
    case invalidIndex

    /// Thrown when redoing or undoing from an empty stack
    case emptyStack

    /// Thrown when dequeuing from empty queue
    case emptyQueue

    /// Thrown when want to put value of person when person has no value
    case emptyPersonValue

    /// Thrown when want to put value on person when person has a value
    case personValueNotEmpty

    case emptyMemoryLocation
    case memoryLocationNotEmpty

}
