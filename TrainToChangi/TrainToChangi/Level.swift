//
//  Level.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 15/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

struct Level {
    let levelName: String
    let completedBefore: Bool
    let input: [Int]
    let expectedOutput: [Int]
    let commandEnum: [CommandEnum]
    let levelDescriptor: String

    init(levelName: String, commandEnum: [CommandEnum], input: [Int],
         levelDescriptor: String, expectedOutput: [Int], completedBefore: Bool) {

        self.levelName = levelName
        self.completedBefore = completedBefore
        self.commandEnum = commandEnum
        self.input = input
        self.levelDescriptor = levelDescriptor
        self.expectedOutput = expectedOutput
    }
}
