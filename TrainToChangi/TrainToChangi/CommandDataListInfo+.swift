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
// [String: String], where key is the index of the commandData in commandDataArray,
// and value is the toString() representation for a commandData.
// We also squeeze in the jumpMappings information:
// for a jump-related command, we append its jumpTargetIndex to the end of its toString after "_".
// e.g. "jump_2" implies that its jumpTarget is at index 2.
extension CommandDataListInfo {

    static func fromSnapshot(snapshot: FIRDataSnapshot) -> CommandDataListInfo? {
        guard let array = snapshot.value as? [String] else {
            return nil
        }
        return commandDataListInfoFromArray(array: array)
    }

    func toAnyObject() -> AnyObject {
        return dictWithJumpMappingsInfo() as AnyObject
    }

    private func dictWithJumpMappingsInfo() -> [String: String] {
        var dict = commandDataArrayAsDict()
        for (jumpParentIndex, jumpTargetIndex) in jumpMappings {
            let jumpParentIndexStr = String(jumpParentIndex)
            guard let jumpStr = dict[jumpParentIndexStr] else {
                fatalError("Jump indexes not stored properly!")
            }
            let appendedJumpStr = jumpStr + "_" + String(jumpTargetIndex)
            dict[jumpParentIndexStr] = appendedJumpStr
        }
        return dict
    }

    private func commandDataArrayAsDict() -> [String: String] {
        var dict: [String: String] = [:]
        for (index, commandData) in commandDataArray.enumerated() {
            dict[String(index)] = commandData.toString()
        }
        return dict
    }

    private static func commandDataListInfoFromArray(array: [String]) -> CommandDataListInfo {
        var commandData: [CommandData] = []
        var jumpMappings: [Int: Int] = [:]

        for (index, commandString) in array.enumerated() {
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
