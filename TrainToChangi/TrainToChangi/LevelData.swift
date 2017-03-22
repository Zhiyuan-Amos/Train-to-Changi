//
// Created by Yong Lin Han on 22/3/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

// Not sure if this is the legit way to do this.
// Maybe we can cocoapods this.
// Maybe the only thing that needs to be in code is the algorithm.
protocol LevelData {

    var levelName: String { get }

    var levelDescription: String { get }

    var availableCommands: [CommandEnum] { get }

    var memoryValues: [Int?] { get }

    // Define random inputs for each level because we can have levels
    // that specifically do not have negative values, etc.
    var randomInputs: [Int] { get }

    // TODO: Add hints, speech bubble to hand hold user a little

    // The algorithm to run on level inputs to get expected outputs.
    func algorithm(inputs: [Int]) -> [Int]
}

struct LevelOneData: LevelData {

    let levelName = "The Beginning"

    let levelDescription = "The MRT needs your help to power up!"
                           + LevelDataHelper.newLine
                           + "Drag and drop commands to move all boxes to Outbox."

    let availableCommands: [CommandEnum] = [LevelDataHelper.inboxCommand,
                                            LevelDataHelper.outboxCommand]

    let memoryValues: [Int?] = []

    private let start = 0
    private let end = 10
    private let count = 3

    var randomInputs: [Int] {
        return LevelDataHelper.randomizeInputs(start: start, end: end, count: count)
    }

    func algorithm(inputs: [Int]) -> [Int] {
        return moveInputsOver(inputs: inputs)
    }

    // Algorithm for level one: move all boxes from inbox to outbox
    private func moveInputsOver(inputs: [Int]) -> [Int] {
        return inputs
    }

}

struct LevelTwoData: LevelData {

    let levelName = "What is going on?"

    let levelDescription = "Wow, that's a whole lot of boxes!"
                           + LevelDataHelper.newLine
                           + "Can you power up the MRT, "
                           + "using only one inbox and outbox command?."

    let availableCommands: [CommandEnum] = [LevelDataHelper.inboxCommand,
                                            LevelDataHelper.outboxCommand,
                                            LevelDataHelper.jumpCommand]

    let memoryValues: [Int?] = []

    private let start = 0
    private let end = 20
    private let count = 20

    var randomInputs: [Int] {
        return LevelDataHelper.randomizeInputs(start: start, end: end, count: count)
    }

    func algorithm(inputs: [Int]) -> [Int] {
        return moveInputsOver(inputs: inputs)
    }

    // Algorithm for level one: move all boxes from inbox to outbox
    private func moveInputsOver(inputs: [Int]) -> [Int] {
        return inputs
    }

}

struct LevelThreeData: LevelData {

    let levelName = "You know how to add, right?"

    let levelDescription = "The boxes do not provide enough power by themselves."
                           + LevelDataHelper.newLine
                           + "Notice that you are provided with locations "
                           + "to place boxes down on the floor, "
                           + "and the COPYTO, ADD functionality. "
                           + "Sum up each pair of boxes, before moving them to outbox."

    let availableCommands: [CommandEnum] = [LevelDataHelper.inboxCommand,
                                            LevelDataHelper.outboxCommand,
                                            LevelDataHelper.jumpCommand,
                                            LevelDataHelper.addCommand,
                                            LevelDataHelper.copyToCommand]

    let memoryValues: [Int?] = [nil, nil]

    private let start = 1
    private let end = 4
    private let count = 8

    var randomInputs: [Int] {
        return LevelDataHelper.randomizeInputs(start: start, end: end, count: count)
    }

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
