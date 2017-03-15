//
//  Station.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

struct StationState {

    var input: Queue<Int>
    var expectedOutput: [Int]
    var output: [Int]
    var memoryValues: [Int?]

    let person: Person

    init(input: Queue<Int>, output: [Int], expectedOutput: [Int],memoryValues: [Int?]) {
        self.input = input
        self.output = output
        self.expectedOutput = expectedOutput
        self.memoryValues = memoryValues
        self.person = Person()
    }

    init(station: StationState) {
        input = station.input
        output = station.output
        expectedOutput = station.expectedOutput
        memoryValues = station.memoryValues

        person = Person()
        person.setHoldingValue(to: station.person.getHoldingValue())
    }

}
