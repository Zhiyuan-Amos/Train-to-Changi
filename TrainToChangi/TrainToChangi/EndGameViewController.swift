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
    private(set) var achievements = AchievementsManager.sharedInstance

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        achievementsTableView.isHidden = achievements.currentLevelUnlockedAchievements.isEmpty

        achievementsTableView.layoutIfNeeded()
        achievementsTableView.frame.size.height =
            min(achievementsTableView.contentSize.height, CGFloat(160))
    }

    @IBAction func returnButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Constants.NotificationNames.levelEnded,
                                        object: nil, userInfo: nil)

        dismiss(animated: false, completion: nil)
        presentingViewController!.dismiss(animated: true, completion: nil)
    }
}
