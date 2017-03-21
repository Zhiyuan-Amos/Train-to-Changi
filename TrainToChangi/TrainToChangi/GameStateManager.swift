//
//  GameStateManager.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 21/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

class GameStateManager {

    private var undoStack: Stack<StationState>
    private var redoStack: Stack<StationState>
    private var currentState: StationState

    init(initialState: StationState) {
        undoStack = Stack<StationState>()
        redoStack = Stack<StationState>()
        currentState = initialState
    }

    func getCurrentState() -> StationState {
        return currentState
    }

    func undo() -> Bool {
        guard let prevState = undoStack.pop() else {
            return false
        }
        redoStack.push(currentState)
        currentState = prevState
        return true
    }

    func redo() -> Bool {
        guard let nextState = redoStack.pop() else {
            return false
        }
        undoStack.push(currentState)
        currentState = nextState
        return true
    }

    func update(newStationState: StationState) {
        undoStack.push(currentState)
        currentState = newStationState
    }

}
