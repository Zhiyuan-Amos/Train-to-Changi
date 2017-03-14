//
//  Station.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

class StationState {

    private let stationName: String

    private var inputConveyorBelt: Queue<Int>?
    private var outputConveyorBelt: [Int]?

    private var memoryValues: [Int?]?
    private var person: Person?

    init?(stationName: String) {
        self.stationName = stationName
        let loadSuccess = initFromStorage(stationName)
        if !loadSuccess {
            return nil
        }
    }

    init(station: StationState) {
        stationName = station.stationName
        inputConveyorBelt = station.inputConveyorBelt
        outputConveyorBelt = station.outputConveyorBelt
        memoryValues = station.memoryValues

        person = Person()
        person?.setHoldingValue(to: station.person?.getHoldingValue())
    }

    func getValueOnPerson() -> Int? {
        return person?.getHoldingValue()
    }

    func setValueOnPerson(to newValue: Int?) {
        person?.setHoldingValue(to: newValue)
    }

    func dequeueFromInput() -> Int? {
        return inputConveyorBelt?.dequeue()
    }

    // Adds to the end
    func addValueToOutput(value: Int) {
        outputConveyorBelt?.append(value)
    }


    // TODO: Currently a stub method, to integrate with storageManager
    private func initFromStorage(_ stationName: String) -> Bool {
        inputConveyorBelt = Queue<Int>()
        outputConveyorBelt = [Int]()
        memoryValues = [Int?]()
        person = Person()
        return true
    }
}
