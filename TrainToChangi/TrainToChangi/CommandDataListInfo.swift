//
//  CommandDataListInfo.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 30/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

// Wrapper class for storing purposes.
class CommandDataListInfo: NSObject, NSCoding {
    let commandDataArrayKey = "commandDataArray"
    let jumpMappingsKey = "jumpMappings"

    let commandDataArray: [CommandData]
    let jumpMappings: [Int: Int]

    init(array: [CommandData], jumpMappings: [Int: Int]) {
        self.commandDataArray = array
        self.jumpMappings = jumpMappings
    }

    func encode(with aCoder: NSCoder) {
        var commandDataStringArr: [String] = []
        for commandData in commandDataArray {
            commandDataStringArr.append(commandData.toString())
        }
        aCoder.encode(commandDataStringArr, forKey: commandDataArrayKey)
        aCoder.encode(jumpMappings, forKey: jumpMappingsKey)
    }

    required init?(coder aDecoder: NSCoder) {
        guard let commandDataStringArr = aDecoder.decodeObject(forKey: commandDataArrayKey) as? [String],
              let jumpMappings = aDecoder.decodeObject(forKey: jumpMappingsKey) as? [Int: Int] else {
            assertionFailure("Failed to load")
            return nil
        }
        var array: [CommandData] = []
        for commandDataString in commandDataStringArr {
            let commandData = CommandData(commandString: commandDataString)
            array.append(commandData)
        }
        self.commandDataArray = array
        self.jumpMappings = jumpMappings
    }
}
