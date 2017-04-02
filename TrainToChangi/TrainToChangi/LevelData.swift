//
// Created by Yong Lin Han on 22/3/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

// MARK - Protocol for every game level data.

protocol LevelData {
    var levelName: String { get }
    var levelDescription: String { get }
    var availableCommands: [CommandData] { get }
    var memoryValues: [Int?] { get }

    // Define random inputs for each level because we can have levels
    // that specifically do not have negative values, etc.
    var randomInputs: [Int] { get }

    // TODO: Add hints, speech bubble to hand hold user a little

    // The algorithm to run on level inputs to get expected outputs.
    func algorithm(inputs: [Int]) -> [Int]
}

// MARK - Alias for brevity in Level Data structs.

extension LevelData {
    fileprivate typealias Helper = Constants.LevelDataHelper
    fileprivate typealias Cmd = Constants.LevelDataHelper.Commands
}

// MARK - Protocol for levels with randomized inputs.

protocol RandomizedInputsLevel {
    var start: Int { get }
    var end: Int { get }
    var count: Int { get }
}

// MARK - Default implementation for levels conforming to RandomizedInputsLevel.

extension LevelData where Self: RandomizedInputsLevel {
    var randomInputs: [Int] {
        return randomizeInputs(start: start, end: end, count: count)
    }

    // Randomizes `count` number of inputs in the range
    // of `start` to `end`, inclusive of `end`.
    // Count must be >= 0
    private func randomizeInputs(start: Int, end: Int, count: Int) -> [Int] {
        guard count >= 0 else {
            preconditionFailure("Count must be >= 0")
        }
        var randomizedResults: [Int] = []
        for _ in 0..<count {
            let randomNumber = randomizeNumber(from: start, to: end)
            randomizedResults.append(randomNumber)
        }
        return randomizedResults
    }

    // Returns a random number between the range, inclusive of to.
    private func randomizeNumber(from start: Int, to end: Int) -> Int {
        return Int(arc4random_uniform(UInt32(end-start+1))) + start
    }
}

// MARK - Level Data structs.

struct LevelOneData: LevelData, RandomizedInputsLevel {

    let levelName = "The Beginning"

    let levelDescription = "The MRT needs your help to power up!"
                           + Helper.newLine
                           + "Drag and drop commands to move all boxes to Outbox."

    let availableCommands: [CommandData] = [Cmd.inbox,
                                            Cmd.outbox,
                                            Cmd.add,
                                            Cmd.copyTo,
                                            Cmd.jump,
                                            Cmd.copyFrom]

    let memoryValues: [Int?] = [nil, nil]

    let start = 0
    let end = 10
    let count = 3

    func algorithm(inputs: [Int]) -> [Int] {
        return moveInputsOver(inputs: inputs)
    }

    // Algorithm for level one: move all boxes from inbox to outbox
    private func moveInputsOver(inputs: [Int]) -> [Int] {
        return inputs
    }

}

struct LevelTwoData: LevelData, RandomizedInputsLevel {

    let levelName = "What is going on?"

    let levelDescription = "Wow, that's a whole lot of boxes!"
                           + Helper.newLine
                           + "Can you power up the MRT, "
                           + "using only one inbox and outbox command?."

    let availableCommands: [CommandData] = [Cmd.inbox,
                                            Cmd.outbox,
                                            Cmd.jump]

    let memoryValues: [Int?] = []

    let start = 0
    let end = 20
    let count = 20

    func algorithm(inputs: [Int]) -> [Int] {
        return moveInputsOver(inputs: inputs)
    }

    // Algorithm for level one: move all boxes from inbox to outbox
    private func moveInputsOver(inputs: [Int]) -> [Int] {
        return inputs
    }

}

struct LevelThreeData: LevelData, RandomizedInputsLevel {

    let levelName = "You know how to add, right?"

    let levelDescription = "The boxes do not provide enough power by themselves."
                           + Helper.newLine
                           + "Notice that you are provided with locations "
                           + "to place boxes down on the floor, "
                           + "and the COPYTO, ADD functionality. "
                           + "Sum up each pair of boxes, before moving them to outbox."

    let availableCommands: [CommandData] = [Cmd.inbox,
                                            Cmd.outbox,
                                            Cmd.jump,
                                            Cmd.add,
                                            Cmd.copyTo]

    let memoryValues: [Int?] = [nil, nil]

    let start = 1
    let end = 4
    let count = 8

    func algorithm(inputs: [Int]) -> [Int] {
        return sumUpPairs(inputs: inputs)
    }

    // Algorithm for level three: sum up pairs of boxes
    // Inputs must have an even count
    private func sumUpPairs(inputs: [Int]) -> [Int] {
        guard inputs.count % 2 == 0 else {
            preconditionFailure("Inputs must have even count!")
        }
        var outputs: [Int] = []
        for index in stride(from: 0, to: inputs.count, by: 2) {
            let first = inputs[index]
            let second = inputs[index + 1]
            outputs.append(first + second)
        }
        return outputs
    }

}
