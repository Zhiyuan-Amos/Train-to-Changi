//
//  LevelAlgorithms.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 21/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//


class LevelAlgorithms {

    static func multiply(by mulitplier: Int, input: [Int]) -> [Int] {
        var output = [Int]()
        for value in input {
            output.append(value * mulitplier)
        }
        return output
    }

    static func addition(by operand: Int, input: [Int]) -> [Int] {
        var output = [Int]()
        for value in input {
            output.append(value + operand)
        }
        return output
    }

}
