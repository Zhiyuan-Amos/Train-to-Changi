//
//  EndGameViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 6/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class EndGameViewController: UIViewController {
    @IBOutlet weak var achievementsTableView: UITableView!
    private var isHidden = true
    private(set) var achievements = [(String, String)]()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func returnButtonPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAchievementUnlocked(notification:)),
            name: Constants.NotificationNames.achievementUnlocked, object: nil)
    }

    override func viewDidLoad() {
        achievementsTableView.isHidden = isHidden
    }

    @objc fileprivate func handleAchievementUnlocked(notification: Notification) {
        guard let name = notification.userInfo?["name"] as? AchievementsEnum else {
            fatalError("Misconfiguration of notification")
        }

        isHidden = false
        let achievementName = name.toAchivementName()
        let achievementImagePath = name.toImagePath()
        achievements.append(achievementName, achievementImagePath)
    }
}
