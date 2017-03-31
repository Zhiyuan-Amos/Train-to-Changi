//
//  ControlPanelViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 27/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class ControlPanelViewController: UIViewController {

    var model: Model!
    var logic: Logic!

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var stepBackButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stepForwardButton: UIButton!

    override func viewDidLoad() {
        registerObservers()
    }

    @objc fileprivate func runStateUpdated(notification: Notification) {
        updateButtonsState()
    }

    //TODO: GameScene need to support
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        //TODO: Temporary method to load levels.
        // Comment out first since no reference to storage here
//        model = ModelManager(leveIndex: 0,
//                             levelData: LevelDataHelper.levelData(levelIndex: 0))
//        logic = LogicManager(model: model)
        model.runState = .paused
    }

    @IBAction func stepBackButtonPressed(_ sender: UIButton) {
        model.runState = .paused
        _ = logic.undo()
    }

    @IBAction func stepForwardButtonPressed(_ sender: UIButton) {
        model.runState = .paused
        logic.executeNextCommand()
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        model.runState = .running(isAnimating: false)
        logic.executeCommands()
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(runStateUpdated(notification:)),
            name: Constants.NotificationNames.runStateUpdated, object: nil)
    }

    // Helper function that updates whether the buttons are enabled depending
    // on the `model.runState`.
    private func updateButtonsState() {
        switch model.runState {
        case .running:
            stopButton.isEnabled = true
            stepBackButton.isEnabled = true
            playButton.isEnabled = false
            stepForwardButton.isEnabled = true
        case .paused:
            stopButton.isEnabled = true
            stepBackButton.isEnabled = true
            playButton.isEnabled = true
            stepForwardButton.isEnabled = true
        case .lost:
            stopButton.isEnabled = true
            stepBackButton.isEnabled = true
            playButton.isEnabled = false
            stepForwardButton.isEnabled = false
        case .won:
            stopButton.isEnabled = false
            stepBackButton.isEnabled = false
            playButton.isEnabled = false
            stepForwardButton.isEnabled = false
        }
    }
}
