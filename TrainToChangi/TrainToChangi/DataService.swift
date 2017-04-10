//
//  DataService.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 4/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import FirebaseDatabase

protocol DataServiceLoadLevelDelegate: class {
    func load(commandDataListInfo: CommandDataListInfo)
}

class DataService {

    private static let _instance = DataService()
    private let usersKey = "users"
    private let profileKey = "profile"
    private let commandDataListInfoKey = "commandDataListInfo"
    private let autoSavedCommandDataListInfoKey = "autoSavedCommandDataListInfo"
    private let autoSavedKey = "autoSaved"

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
        let profile: [String: AnyObject] = ["firstName": "" as AnyObject, "lastName": "" as AnyObject]
        usersRef.child(userId)
                .child(profileKey)
                .setValue(profile)
    }

    // Called by AutomaticFirebaseSaver only, eliminates the need to have a saveName
    // that the user will never enter.
    // Also ensures that there is only one automatically saved program for each level.
    func autoSaveUserAddedCommands(userId: String,
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
    func saveUserAddedCommands(userId: String,
                               levelIndex: Int,
                               saveName: String,
                               commandDataListInfo: CommandDataListInfo) {
        let commandDataListInfo = commandDataListInfo.toAnyObject()
        let path = "\(userId)/\(commandDataListInfoKey)/\(levelIndex)/\(saveName)"
        usersRef.child(path).setValue(commandDataListInfo)
    }

    // Eliminates the delay in loading user added commands by obtaining a reference
    // to the Firebase database prior.
    func preloadUserAddedCommands(userId: String) {
        let ref = DataService.instance.usersRef.child(userId)
        ref.observeSingleEvent(of: .value, with: { _ in }) { _ in }
    }

    // Loads user added commands saved by AutomaticFirebaseSaver.
    // Called at the start of every level view.
    func loadAutoSavedUserAddedCommands(userId: String,
                                       levelIndex: Int,
                                       loadLevelDelegate: DataServiceLoadLevelDelegate) {
        let ref = usersRef.child(userId)
            .child(autoSavedCommandDataListInfoKey)
            .child(String(levelIndex))
            .child(autoSavedKey)

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let commandDataListInfo = CommandDataListInfo.fromSnapshot(snapshot: snapshot) {
                loadLevelDelegate.load(commandDataListInfo: commandDataListInfo)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // Loads user added commands saved by user through SaveProgramViewController.
    func loadUserAddedCommands(userId: String,
                               levelIndex: Int,
                               saveName: String,
                               loadLevelDelegate: DataServiceLoadLevelDelegate) {
        let ref = usersRef.child(userId)
                          .child(commandDataListInfoKey)
                          .child(String(levelIndex))
                          .child(saveName)

        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let commandDataListInfo = CommandDataListInfo.fromSnapshot(snapshot: snapshot) {
                loadLevelDelegate.load(commandDataListInfo: commandDataListInfo)
            }
        }) { (error) in
            print(error.localizedDescription)
        }

    }
}
