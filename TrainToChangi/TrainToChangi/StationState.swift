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

    init(inputValues: [Int], output: [Int], memoryValues: [Int?]) {
        var queue = Queue<Int>()
        for value in inputValues {
            queue.enqueue(value)
        }
        self.input = queue
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
