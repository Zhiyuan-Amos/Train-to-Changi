//
//  LevelDescriptionViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 9/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class LevelDescriptionViewController: UIViewController {

    var model: Model!
    
    @IBOutlet weak var levelDescriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        setUpLevelDescription()
    }

    private func setBackgroundColor() {
        levelDescriptionTextView.backgroundColor =
            Constants.Background.levelDescriptionBackgroundColor
    }
    // Initialise the height for level description
    private func setUpLevelDescription() {
        levelDescriptionTextView.text = model.currentLevel.levelDescriptor
        levelDescriptionTextView.isScrollEnabled = true
        levelDescriptionTextView.font = Constants.UI.LevelDescription.font
        levelDescriptionTextView.textColor = Constants.UI.LevelDescription.textColor
        levelDescriptionTextView.textContainerInset = Constants.UI.LevelDescription.insets
    }
}
