//
//  LevelHelper.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 15/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

struct LevelHelper {
    func generateOutput(input: [Int], _ algorithm: ([Int]) -> [Int]) -> [Int] {
        return algorithm(input)
    }

    //TODO: randomInputGenerator
}
