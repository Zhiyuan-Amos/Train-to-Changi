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
    @IBOutlet weak var expectedOutputTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        setUpLevelDescription()
        setUpExpectedOutput()
    }

    private func setBackgroundColor() {
        view.backgroundColor =
            Constants.Background.levelDescriptionBackgroundColor
    }

    private func setUpLevelDescription() {
        levelDescriptionTextView.text = model.currentLevel.levelDescriptor
        levelDescriptionTextView.isScrollEnabled = true
        levelDescriptionTextView.font = Constants.UI.LevelDescription.font
    }

    private func setUpExpectedOutput() {
        var outputString = ""
        for output in model.expectedOutputs {
            outputString += "\(output) "
        }

        expectedOutputTextView.text = outputString
        expectedOutputTextView.isScrollEnabled = true
        expectedOutputTextView.font = Constants.UI.LevelDescription.font
    }


}
