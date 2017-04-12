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
    var inputs: [Int] { get }

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
    var inputs: [Int] {
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

    let levelName = "Kent Ridge"

    let levelDescription = "The MRT needs your help to power up!"
                           + Helper.newLine
                           + "You are given some commands. Tap on them to add them to the editor, then drag and drop to move them around. Get all boxes to Outbox!"

    let availableCommands: [CommandData] = [Cmd.inbox,
                                            Cmd.outbox,
                                            Cmd.jump]

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

    let levelName = "City Hall"

    let levelDescription = "The boxes do not provide enough power on their own."
                           + Helper.newLine
                           + "Can you sum the boxes up before moving them to outbox?"
                           + "The combined power of four boxes will do, so sum up four of them and then move this sum to outbox. Repeat this until all the inbox has no more boxes!"

    let availableCommands: [CommandData] = [Cmd.inbox,
                                            Cmd.outbox,
                                            Cmd.copyTo,
                                            Cmd.add,
                                            Cmd.jump]

    let memoryValues: [Int?] = [nil, nil]

    let start = 0
    let end = 20
    let count = 8

    func algorithm(inputs: [Int]) -> [Int] {
        return sumUpFours(inputs: inputs)
    }

    // Algorithm for level three: sum up pairs of boxes
    // Inputs must be divisible by 4
    private func sumUpFours(inputs: [Int]) -> [Int] {
        guard inputs.count % 4 == 0 else {
            preconditionFailure("Inputs must be divisible by 4!")
        }
        var outputs: [Int] = []
        for index in stride(from: 0, to: inputs.count, by: 4) {
            let first = inputs[index]
            let second = inputs[index + 1]
            let third = inputs[index + 2]
            let fourth = inputs[index + 3]
            outputs.append(first + second + third + fourth)
        }
        return outputs
    }

}

struct LevelThreeData: LevelData, RandomizedInputsLevel {

    let levelName = "Changi"

    let levelDescription = "We want the boxes with higher power."
                           + Helper.newLine
                           + "For each two boxes in inbox, "
                           + "place only the bigger of the two in outbox. "
                           + "If they are equal, either one will do! "

    let availableCommands: [CommandData] = [Cmd.inbox,
                                            Cmd.outbox,
                                            Cmd.copyFrom,
                                            Cmd.copyTo,
                                            Cmd.add,
                                            Cmd.sub,
                                            Cmd.jump,
                                            Cmd.jumpIfZero,
                                            Cmd.jumpIfNegative]

    let memoryValues: [Int?] = [nil, nil]

    let start = 1
    let end = 20
    let count = 8

    func algorithm(inputs: [Int]) -> [Int] {
        return outputLargerOfEachPair(inputs: inputs)
    }

    // Algorithm for level three: output the larger number of each pair
    // Inputs must have an even count
    private func outputLargerOfEachPair(inputs: [Int]) -> [Int] {
        guard inputs.count % 2 == 0 else {
            preconditionFailure("Inputs must have even count!")
        }
        var outputs: [Int] = []
        for index in stride(from: 0, to: inputs.count, by: 2) {
            let first = inputs[index]
            let second = inputs[index + 1]
            let larger = first > second ? first : second
            outputs.append(larger)
        }
        return outputs
    }

}
