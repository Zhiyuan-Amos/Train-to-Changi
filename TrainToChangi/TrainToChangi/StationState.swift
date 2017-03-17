//
//  Station.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

struct StationState {

    var input: Queue<Int>
    var output: [Int]
    var memoryValues: [Int?]

    let person: Person

    init(input: [Int], output: [Int], memoryValues: [Int?]) {
        self.input = Queue<Int>(array: input)
        self.output = output
        self.memoryValues = memoryValues
        self.person = Person()
    }

    init(station: StationState) {
        input = station.input
        output = station.output
        memoryValues = station.memoryValues

        person = Person()
        person.setHoldingValue(to: station.person.getHoldingValue())
    }

}
