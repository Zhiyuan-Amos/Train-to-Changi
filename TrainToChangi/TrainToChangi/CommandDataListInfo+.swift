//
//  CommandDataListInfo+.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 4/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation
import FirebaseDatabase

// For Firebase storage
// To enable CommandDataListInfo to be saved to Firebase, we represent it as a Dictionary of
// [Int: String], where int is the index of the commandData in commandDataArray,
// and String is the toString() representation for a commandData.
// We also squeeze in the jumpMappings information:
// for a jump-related command, we append its jumpTargetIndex to the end of its toString after "_".
// e.g. "jump_2" implies that its jumpTarget is at index 2.
extension CommandDataListInfo {

    static func fromSnapshot(snapshot: FIRDataSnapshot) -> CommandDataListInfo? {
        guard let snapDict = snapshot.value as? [Int: String] else {
            assertionFailure("Loading failed.")
            return nil
        }
        return commandDataListInfoFromDict(dict: snapDict)
    }

    func toAnyObject() -> AnyObject {
        return dictWithJumpMappingsInfo() as AnyObject
    }

    private func dictWithJumpMappingsInfo() -> [Int: String] {
        var dict = commandDataArrayAsDict()
        for (jumpParentIndex, jumpTargetIndex) in jumpMappings {
            guard let jumpStr = dict[jumpParentIndex] else {
                fatalError("Jump indexes not stored properly!")
            }
            let appendedJumpStr = jumpStr + "_" + String(jumpTargetIndex)
            dict[jumpParentIndex] = appendedJumpStr
        }
        return dict
    }

    private func commandDataArrayAsDict() -> [Int: String] {
        var dict: [Int: String] = [:]
        for (index, commandData) in commandDataArray.enumerated() {
            dict[index] = commandData.toString()
        }
        return dict
    }

    // I have no idea if this works
    private static func commandDataListInfoFromDict(dict: [Int: String]) -> CommandDataListInfo {
        var stringArr: [String] = []
        var commandData: [CommandData] = []
        var jumpMappings: [Int: Int] = [:]

        let sortedKeysArray = dict.sorted(by: { $0.0 < $1.0 })
        for (_, value) in sortedKeysArray {
            stringArr.append(value)
        }

        for (index, commandString) in stringArr.enumerated() {
            let commandArr = commandString.characters.split{$0 == "_"}.map(String.init)
            switch commandArr[0] {
            case "inbox":
                commandData.append(CommandData.inbox)
            case "outbox":
                commandData.append(CommandData.outbox)
            case "copyFrom":
                commandData.append(CommandData.copyFrom(memoryIndex: Int(commandArr[1])))
            case "copyTo":
                commandData.append(CommandData.copyTo(memoryIndex: Int(commandArr[1])))
            case "add":
                commandData.append(CommandData.add(memoryIndex: Int(commandArr[1])))
            case "jump":
                commandData.append(CommandData.jump)
                jumpMappings[index] = Int(commandArr[1])
            case "jumpTarget":
                commandData.append(CommandData.jumpTarget)
            default:
                fatalError("Should never happen, undefined enum.")
            }
        }
        return CommandDataListInfo(array: commandData, jumpMappings: jumpMappings)
    }

}
