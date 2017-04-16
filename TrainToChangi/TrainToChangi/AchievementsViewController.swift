//
//  AchievementsViewController.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 16/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class AchievementsViewController: UIViewController {

    @IBOutlet var achievementsTableView: UITableView!
    fileprivate(set) var achievements: [Achievement] = []

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        achievementsTableView.dataSource = self
        achievementsTableView.delegate = self
        achievementsTableView.layoutIfNeeded()

        guard let userId = AuthService.instance.currentUserId else {
            fatalError(Constants.Errors.userNotLoggedIn)
        }
        DataService.instance.loadUnlockedAchievements(userId: userId,
                                                      loadUnlockedAchievementsDelegate: self)
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AchievementsViewController: DataServiceLoadUnlockedAchievementsDelegate {
    func load(unlockedAchievements: [String]) {
        for unlockedAchievementStr in unlockedAchievements {
            guard let achievementsEnum = AchievementsEnum(rawValue: unlockedAchievementStr) else {
                fatalError("Cannot be initalised, wrong string value.")
            }
            achievements.append(Achievement(name: achievementsEnum, isUnlocked: true))
        }
        achievementsTableView.reloadData()
    }
}
