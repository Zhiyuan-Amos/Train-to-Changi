//
//  LandingViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 9/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import FirebaseAuth

class LandingViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        // Makes sure that user is logged in.
        guard FIRAuth.auth()?.currentUser != nil else {
            // show login viewcontroller
            performSegue(withIdentifier: "login", sender: nil)
            return
        }
        preloadCommandDataList()
    }

    // Speed up connection when loading in EditorVC.
    private func preloadCommandDataList() {
        guard let userId = AuthService.instance.currentUserId else {
            return
        }
        DataService.instance.preloadUserPrograms(userId: userId)
    }

    @IBAction func cancelFromLevelSelection(segue: UIStoryboardSegue) {
    }
}
