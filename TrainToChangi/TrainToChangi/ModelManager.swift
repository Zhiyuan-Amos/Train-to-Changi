//
//  ModelManager.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class ModelManager {

    private var undoStack: Stack<StationState>
    private var redoStack: Stack<StationState>
    private var currentCommands: [Command]

    init?(stationName: String) {
        currentCommands = [Command]()
        undoStack = Stack<StationState>()
        redoStack = Stack<StationState>()

        guard let initialState = StationState(stationName: stationName) else {
            return nil
        }

        undoStack.push(initialState)
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

    func insertCommand(atIndex: Int, command: Command) -> Bool {
        guard atIndex >= 0 && atIndex <= currentCommands.count else {
            return false
        }
        currentCommands.insert(command, at: atIndex)
        return true
    }

    func removeCommand(fromIndex: Int) -> Bool {
        guard fromIndex >= 0 && fromIndex < currentCommands.count else {
            return false
        }

        currentCommands.remove(at: fromIndex)
        return true
    }

    func dequeueValueFromInbox() -> CommandResult {
        guard let topStation = undoStack.top else {
            // not sure what this does
            return CommandResult(errorMessage: .noInboxValue)
        }

        if topStation.getValueOnPerson() != nil {
            return CommandResult(errorMessage: .noInboxValue)
        }

        let newStation = StationState(station: topStation)
        newStation.setValueOnPerson(to: newStation.dequeueFromInput())
        undoStack.push(newStation)

        return CommandResult(errorMessage: nil)
    }

    func putValueIntoOutbox() -> CommandResult {
        guard let topStation = undoStack.top else {
            // not sure what this does
            return CommandResult(errorMessage: .noPersonValue)
        }

        guard let personValue = topStation.getValueOnPerson() else {
            return CommandResult(errorMessage: .noPersonValue)
        }

        let newStation = StationState(station: topStation)

        newStation.addValueToOutput(value: personValue)
        newStation.setValueOnPerson(to: nil)
        undoStack.push(newStation)

        return CommandResult(errorMessage: nil)
    }

    func getValueOnPerson() -> Int? {
        return undoStack.top?.getValueOnPerson()
    }

    func updateValueOnPerson(to newValue: Int?) {
        guard let topStation = undoStack.top else {
            return
        }
        let newStation = StationState(station: topStation)
        newStation.setValueOnPerson(to: newValue)
        undoStack.push(newStation)
    }
}
