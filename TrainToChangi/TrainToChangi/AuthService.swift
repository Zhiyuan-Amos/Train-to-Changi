//
//  AuthService.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 4/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import FirebaseAuth

class AuthService {
    private static let _instance = AuthService()

    static var instance: AuthService {
        return _instance
    }

    var currentUserId: String? {
        return FIRAuth.auth()?.currentUser?.uid
    }

    func login(credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // User signed into firebase
            // Add user into database
            guard let user = user else {
                assertionFailure("No error, user must be signed in!")
                return
            }
            DataService.instance.saveUser(userId: user.uid)
        })
    }

}