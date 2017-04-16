//
//  DataService.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 4/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import FirebaseDatabase

protocol DataServiceLoadProgramDelegate: class {
    func load(commandDataListInfo: CommandDataListInfo)
}

protocol DataServiceLoadSavedProgramNamesDelegate: class {
    func load(savedProgramNames: [[String]])
}

protocol DataServiceLoadUnlockedAchievementsDelegate: class {
    func load(unlockedAchievements: [String])
}

class DataService {

    private static let _instance = DataService()
    private let usersKey = "users"
    private let profileKey = "profile"
    private let firstNameKey = "firstName"
    private let lastNameKey = "lastName"
    private let commandDataListInfoKey = "commandDataListInfo"
    private let autoSavedCommandDataListInfoKey = "autoSavedCommandDataListInfo"
    private let autoSavedKey = "autoSaved"
    private let achievementsKey = "achievements"

    static var instance: DataService {
        return _instance
    }

    var mainRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }

    var usersRef: FIRDatabaseReference {
        return mainRef.child(usersKey)
    }

    func saveUser(userId: String) {
        let profile: [String: AnyObject] = [firstNameKey: "" as AnyObject,
                                            lastNameKey: "" as AnyObject]
        usersRef.child(userId)
                .child(profileKey)
                .setValue(profile)
    }

    // Called by AutomaticFirebaseSaver only, eliminates the need to have a saveName
    // that the user will never enter.
    // Also ensures that there is only one automatically saved program for each level.
    func autoSaveUserProgram(userId: String,
                             levelIndex: Int,
                             commandDataListInfo: CommandDataListInfo) {
        let commandDataListInfo = commandDataListInfo.toAnyObject()
        let data: [String: AnyObject] = [autoSavedKey: commandDataListInfo]
        let ref = usersRef.child(userId)
                          .child(autoSavedCommandDataListInfoKey)
                          .child(String(levelIndex))
        ref.setValue(data)
    }

    // Called by SaveProgramViewController when the user saves a program.
    func saveUserProgram(userId: String,
                         levelIndex: Int,
                         saveName: String,
                         commandDataListInfo: CommandDataListInfo) {
        let commandDataListInfo = commandDataListInfo.toAnyObject()
        let path = "\(userId)/\(commandDataListInfoKey)/\(levelIndex)/\(saveName)"
        usersRef.child(path).setValue(commandDataListInfo)
    }

    // Eliminates the delay in loading user added commands by obtaining a reference
    // to the Firebase database prior.
    func preloadUserPrograms(userId: String) {
        let ref = DataService.instance.usersRef.child(userId)
        ref.observeSingleEvent(of: .value, with: { _ in }) { _ in }
    }

    // Loads user added commands saved by AutomaticFirebaseSaver.
    // Called at the start of every level view.
    func loadAutoSavedUserProgram(userId: String,
                                  levelIndex: Int,
                                  loadProgramDelegate: DataServiceLoadProgramDelegate) {
        let ref = usersRef.child(userId)
            .child(autoSavedCommandDataListInfoKey)
            .child(String(levelIndex))
            .child(autoSavedKey)

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let commandDataListInfo = CommandDataListInfo.fromSnapshot(snapshot: snapshot) {
                loadProgramDelegate.load(commandDataListInfo: commandDataListInfo)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // Loads user added commands saved by user through SaveProgramViewController.
    func loadSavedUserProgram(userId: String,
                              levelIndex: Int,
                              saveName: String,
                              loadProgramDelegate: DataServiceLoadProgramDelegate) {
        let ref = usersRef.child(userId)
                          .child(commandDataListInfoKey)
                          .child(String(levelIndex))
                          .child(saveName)

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let commandDataListInfo = CommandDataListInfo.fromSnapshot(snapshot: snapshot) {
                loadProgramDelegate.load(commandDataListInfo: commandDataListInfo)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // Loads a String array of saveName for each levelIndex.
    func loadSavedProgramNames(userId: String,
                               loadSavedProgramNamesDelegate: DataServiceLoadSavedProgramNamesDelegate) {
        let ref = usersRef.child(userId)
                          .child(commandDataListInfoKey)
        var userAddedCommandsArray: [[String]] = []
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let arr = snapshot.value as? NSArray {
                for element in arr {
                    // levelIndex layer
                    // saveName to CommandDataListInfo mapping here.
                    if let dict = element as? [String: AnyObject] {
                        let saveNameArray = Array(dict.keys)
                        userAddedCommandsArray.append(saveNameArray)
                    }
                }
                loadSavedProgramNamesDelegate.load(savedProgramNames: userAddedCommandsArray)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // Saves unlocked achievement to database
    func unlockAchievement(userId: String,
                           achievementString: String) {
        // Convert achievementString to anyObject
        let data = [achievementString: true as AnyObject]
        usersRef.child(userId).child(achievementsKey).updateChildValues(data)
    }

    func loadUnlockedAchievements(userId: String,
                                  loadUnlockedAchievementsDelegate: DataServiceLoadUnlockedAchievementsDelegate) {
        let ref = usersRef.child(userId)
                          .child(achievementsKey)

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let unlockedAchievementsDict = snapshot.value as? [String: AnyObject] {
                loadUnlockedAchievementsDelegate.load(unlockedAchievements: Array(unlockedAchievementsDict.keys))
            } else {
                loadUnlockedAchievementsDelegate.load(unlockedAchievements: [])
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
