//
//  LevelDataHelper.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 22/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

struct LevelDataHelper {
    static let newLine = "\n"
    static let inboxCommand = CommandData.inbox
    static let outboxCommand = CommandData.outbox
    static let jumpCommand = CommandData.jump(targetIndex: nil)
    static let addCommand = CommandData.add(memoryIndex: nil)
    static let copyToCommand = CommandData.copyTo(memoryIndex: nil)

    static func levelData(levelIndex: Int) -> LevelData {
        return preloadedLevelsData[levelIndex]
    }

    // Randomizes `count` number of inputs in the range
    // of `start` to `end`, inclusive of `end`.
    // Count must be >= 0
    static func randomizeInputs(start: Int, end: Int, count: Int) -> [Int] {
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

    private static let preloadedLevelsData: [LevelData] = [LevelOneData(),
                                                           LevelTwoData(),
                                                           LevelThreeData()]

    // Returns a random number between the range, inclusive of to.
    private static func randomizeNumber(from start: Int, to end: Int) -> Int {
        return Int(arc4random_uniform(UInt32(end-start+1))) + start
    }
}
