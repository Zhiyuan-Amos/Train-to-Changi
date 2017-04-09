//
//  DataService.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 4/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import FirebaseDatabase

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

    func getUserAddedCommandsSavedRef(userId: String,
                                      levelIndex: Int,
                                      saveName: String) -> FIRDatabaseReference {
        return usersRef.child(userId)
                       .child(commandDataListInfoKey)
                       .child(String(levelIndex))
                       .child(saveName)
    }

}
