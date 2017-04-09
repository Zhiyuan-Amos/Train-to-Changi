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

    func saveUser(uid: String) {
        let profile: [String: AnyObject] = ["firstName": "" as AnyObject, "lastName": "" as AnyObject]
        usersRef.child(uid).child(profileKey).setValue(profile)
    }

    func saveUserAddedCommands(uid: String,
                               levelIndex: Int,
                               saveName: String,
                               commandDataListInfo: AnyObject) {
        let data: [String: AnyObject] = [saveName: commandDataListInfo]
        let ref = usersRef.child(uid).child(commandDataListInfoKey).child(String(levelIndex))
        ref.setValue(data)
    }

}
