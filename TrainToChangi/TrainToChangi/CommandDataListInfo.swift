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
    let commandDataArrayKeyString = "commandDataArray"
    let jumpMappingsKeyString = "jumpMappings"

    let commandDataArray: [CommandData]
    let jumpMappings: [Int: Int]

    init(array: [CommandData], jumpMappings: [Int: Int]) {
        self.commandDataArray = array
        self.jumpMappings = jumpMappings
    }

    func encode(with aCoder: NSCoder) {
        var stringArr: [String] = []
        for commandData in commandDataArray {
            stringArr.append(commandData.toString())
        }
        aCoder.encode(stringArr, forKey: commandDataArrayKeyString)
        aCoder.encode(jumpMappings, forKey: jumpMappingsKeyString)
    }

    required init?(coder aDecoder: NSCoder) {
        guard let stringArr = aDecoder.decodeObject(forKey: commandDataArrayKeyString) as? [String],
              let jumpMappings = aDecoder.decodeObject(forKey: jumpMappingsKeyString) as? [Int: Int] else {
            assertionFailure("Failed to load")
            return nil
        }
        var array: [CommandData] = []
        for commandDataString in stringArr {
            let commandData = CommandData(commandString: commandDataString)
            array.append(commandData)
        }
        self.commandDataArray = array
        self.jumpMappings = jumpMappings
    }
}
