//
//  UserData.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 22/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

// Stores user specific data.
// Done this way to easily support multiple save slots in the app.
class UserData: NSObject, NSCoding {
    let completedLevelIndexesKey = "completedLevelIndexes"
    let addedCommandsInfoKey = "addedCommands"

    // Not done in a cumulative way in case we implement branching paths
    private(set) var completedLevelIndexes: [Int] = []

    // Maps a level's index to its `CommandDataListInfo` representing
    // the `commandData` added by the user in the editor.
    private(set) var levelIndexToAddedCommandsInfo: [Int: CommandDataListInfo] = [:]

    override init() {
        super.init()
    }

    func completeLevel(levelIndex: Int) {
        if completedLevelIndexes.contains(levelIndex) {
            return
        }
        completedLevelIndexes.append(levelIndex)
    }

    func updateAddedCommandsInfo(levelIndex: Int, commandDataListInfo: CommandDataListInfo) {
        levelIndexToAddedCommandsInfo[levelIndex] = commandDataListInfo
    }

    func getAddedCommands(levelIndex: Int) -> CommandDataListInfo? {
        return levelIndexToAddedCommandsInfo[levelIndex]
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(completedLevelIndexes, forKey: completedLevelIndexesKey)
        aCoder.encode(levelIndexToAddedCommandsInfo, forKey: addedCommandsInfoKey)
    }

    required init?(coder aDecoder: NSCoder) {
        guard let completedLevelIndexes =
            aDecoder.decodeObject(forKey: completedLevelIndexesKey) as? [Int],
            let levelIndexToAddedCommandsInfo =
        aDecoder.decodeObject(forKey: addedCommandsInfoKey) as? [Int: CommandDataListInfo] else {
                assertionFailure("Failed to load.")
                return nil
        }

        self.completedLevelIndexes = completedLevelIndexes
        self.levelIndexToAddedCommandsInfo = levelIndexToAddedCommandsInfo
    }
}
