//
//  Level.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 15/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

struct Level {
    // Missing a way to indicate how many memory locations there are.
    let levelName: String
    let initialState: LevelState
    let availableCommands: [CommandEnum]
    let levelDescriptor: String
    let expectedOutputs: [Int]

    init(levelName: String, initialState: LevelState, availableCommands: [CommandEnum],
         levelDescriptor: String, algorithm: @escaping ([Int]) -> [Int]) {
        self.levelName = levelName
        self.initialState = initialState
        self.availableCommands = availableCommands
        self.levelDescriptor = levelDescriptor
        self.expectedOutputs = InputConverter().generateOutput(
                input: initialState.inputs, algorithm)
    }
}
