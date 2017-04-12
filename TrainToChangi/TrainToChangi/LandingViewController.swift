//
//  LandingViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 9/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LandingViewController: UIViewController {

    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var trainImageView: UIImageView!

    override func viewDidAppear(_ animated: Bool) {
        // Makes sure that user is logged in.
        guard AuthService.instance.currentUserId != nil else {
            // show login viewcontroller
            performSegue(withIdentifier: "login", sender: nil)
            return
        }
        preloadCommandDataList()
        loadUnlockedAchievements()
    }

    override func viewDidLoad() {
        let titleCenterY = titleImageView.center.y
        animateTitleUpMotion(center: titleCenterY)

        let trainCenterX = trainImageView.center.x
        animateTrainMovingMotion(center: trainCenterX)
    }

    private func animateTitleUpMotion(center: CGFloat) {
        UIView.animate(withDuration: 2, animations: {
            self.titleImageView.center.y = center - 15
        }, completion: { _ in self.animateTitleDownMotion(center: center) })
    }

    private func animateTitleDownMotion(center: CGFloat) {
        UIView.animate(withDuration: 2, animations: {
            self.titleImageView.center.y = center + 15
        }, completion: { _ in self.animateTitleUpMotion(center: center) })
    }

    private func animateTrainMovingMotion(center: CGFloat) {
        UIView.animate(withDuration: 5, animations: {
            self.trainImageView.center.x = center + 1500
        }, completion: { _ in
            self.trainImageView.center.x = center
            self.animateTrainMovingMotion(center: center)
        })
    }

    // Speed up connection when loading in EditorVC.
    private func preloadCommandDataList() {
        guard let userId = AuthService.instance.currentUserId else {
            return
        }
        DataService.instance.preloadUserPrograms(userId: userId)
    }

    // Loads user's unlocked achievements from firebase.
    // This function cannot be placed inside AchievementsManager's init because
    // it will be initialised before user has logged in.
    private func loadUnlockedAchievements() {
        guard let userId = AuthService.instance.currentUserId else {
            return
        }
        DataService.instance.loadUnlockedAchievements(userId: userId,
                                                      loadUnlockedAchievementsDelegate: AchievementsManager.sharedInstance)
    }

    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
            GIDSignIn.sharedInstance().signOut()

            performSegue(withIdentifier: "login", sender: nil)
            return
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
    }

    @IBAction func cancelFromLevelSelection(segue: UIStoryboardSegue) {
    }
}
