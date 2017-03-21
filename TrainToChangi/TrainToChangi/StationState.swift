//
//  Station.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

struct StationState {

    var input: [Int]
    var output: [Int]
    var memoryValues: [Int?]
    var personValue: Int?

    init(input: [Int]) {
        self.input = input
        self.output = [Int]()
        self.memoryValues = [Int?]()
    }

    init(station: StationState) {
        input = station.input
        output = station.output
        memoryValues = station.memoryValues
        personValue = station.personValue
    }

}
