//
//  StorageManager.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 16/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

class StorageManager {
    // Stub level, `stationName` is the unique identifier for each level.
    func loadLevel(stationName: String) -> Level {
        return Level(stationName: "test", initialState: StationState(
            inputValues: [1, 2, 3], output: [], memoryValues: [nil, nil]),
                     commandTypes: [.inbox, .outbox, .add(memoryIndex: nil)],
                     levelDescriptor: "sum all the values and output the sum",
                     algorithm: stubAlgo)
    }

    // stubAlgo, refactor into `preloadedLevels` or something.
    func stubAlgo(values: [Int]) -> [Int] {
        var sum = 0
        for value in values {
            sum += value
        }

        return [sum]
    }
}
