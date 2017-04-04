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

    static var instance: DataService {
        return _instance
    }

    var mainRef: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }

//    var currentUserRef: FIRDatabaseReference {
//        let userID = UserDefaults.standard.value(forKey: "uid") as! String
//
//        let currentUser = mainRef.child(FIR_CHILD_USERS).child(userID)
//        return currentUser
//    }

    func saveUser(uid: String) {
        let profile: Dictionary<String, AnyObject> = ["firstName": "" as AnyObject, "lastName": "" as AnyObject]
        mainRef.child(usersKey).child(uid).child(profileKey).setValue(profile)
    }
}
