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

    func saveUserAddedCommands(userId: String,
                               levelIndex: Int,
                               saveName: String,
                               commandDataListInfo: AnyObject) {
        let data: [String: AnyObject] = [saveName: commandDataListInfo]
        let ref = usersRef.child(userId)
                          .child(commandDataListInfoKey)
                          .child(String(levelIndex))
        ref.setValue(data)
    }

    func preloadUserAddedCommands(userId: String) {
        let ref = DataService.instance.usersRef.child(userId).child(commandDataListInfoKey)
        ref.observeSingleEvent(of: .value, with: { _ in }) { _ in }
    }

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
