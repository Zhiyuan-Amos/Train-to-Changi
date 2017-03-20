//
//  Level.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 15/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

class Level {
    let stationName: String
    let initialState: StationState
    let expectedOutput: [Int]
    let commandEnum: [CommandEnum]
    let levelDescriptor: String

    init(stationName: String, initialState: StationState, commandEnum: [CommandEnum],
         levelDescriptor: String, algorithm: @escaping ([Int]) -> [Int]) {
        self.stationName = stationName
        self.initialState = initialState
        self.commandEnum = commandEnum
        self.levelDescriptor = levelDescriptor
        self.expectedOutput = InputConverter().generateOutput(
            input: initialState.input.toArray, algorithm)
    }
}
