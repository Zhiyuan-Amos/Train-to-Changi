//
//  StorageManager.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 16/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

class StorageManager {
    func loadLevel(stationName: String) -> Level {
        for level in PreloadedLevels.allLevels {
            if level.stationName == stationName {
                return level
            }
        }
        fatalError("Level unable to be found")
    }
}
