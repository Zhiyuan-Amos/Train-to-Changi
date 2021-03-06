//
//  EndGameViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 6/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

/**
 * View controller responsible for the end game view
 */
class EndGameViewController: UIViewController {

    var model: Model!

    private(set) var achievements = AchievementsManager.sharedInstance

    @IBOutlet weak var achievementsTableView: UITableView!

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        achievements.updateAchievements(model: model)
        achievementsTableView.isHidden = achievements.currentLevelUnlockedAchievements.isEmpty
        achievementsTableView.layoutIfNeeded()
        achievementsTableView.frame.size.height = achievementsTableView.contentSize.height
    }

    @IBAction func returnButtonPressed(_ sender: UIButton) {
        achievements.updateOnLevelEnded()
        dismiss(animated: false, completion: nil)
        presentingViewController!.dismiss(animated: true, completion: nil)
    }
}
