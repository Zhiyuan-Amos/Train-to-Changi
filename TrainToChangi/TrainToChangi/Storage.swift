//
//  Storage.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 2/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

protocol Storage {

    // Returns true if the level represented by `levelIndex` was previously
    // completed by the user.
    func hasCompletedLevel(levelIndex: Int) -> Bool

    // Returns a representation of the commands user has added into the editor
    // previously, for the level represented by `levelIndex`.
    func getUserAddedCommandsAsListInfo(levelIndex: Int) -> CommandDataListInfo?

    // Saves all storage-managed details to file.
    func save()

}
