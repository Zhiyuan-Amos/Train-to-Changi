//
//  UserData.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 22/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

// Stores user specific data.
// Done this way to easily support multiple save slots in the app.
class UserData {
    // Not done in a cumulative way in case we implement branching paths
    var completedLevelIndexes: [Int] = []

    var levelIndexToAddedCommands: [Int: [CommandEnum]] = [:]

    // Called after level is won
    func completeLevel(levelIndex: Int) {
        if completedLevelIndexes.contains(levelIndex) {
            return
        }
        completedLevelIndexes.append(levelIndex)
    }

    // Called by app delegate after app quits, or when user press back/win level.
    func updateAddedCommands(levelIndex: Int, userAddedCommands: [CommandEnum]) {
        levelIndexToAddedCommands[levelIndex] = userAddedCommands
    }
}
