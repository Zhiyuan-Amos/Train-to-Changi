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

    // Updates whether the buttons are enabled.
    private func updateButtons(stopButtonIsEnabled: Bool, stepBackButtonIsEnabled: Bool,
                               playButtonIsEnabled: Bool, stepForwardButtonIsEnabled: Bool) {
        stopButton.isEnabled = stopButtonIsEnabled
        stepBackButton.isEnabled = stepBackButtonIsEnabled
        playButton.isEnabled = playButtonIsEnabled
        stepForwardButton.isEnabled = stepForwardButtonIsEnabled
    }

    // Updates whether the buttons are enabled depending on the `model.runState`.
    @objc fileprivate func handleRunStateUpdate(notification: Notification) {
        switch model.runState {
        case .running:
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: true,
                          playButtonIsEnabled: false, stepForwardButtonIsEnabled: true)
        case .paused:
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: true,
                          playButtonIsEnabled: true, stepForwardButtonIsEnabled: true)
        case .lost:
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: true,
                          playButtonIsEnabled: false, stepForwardButtonIsEnabled: false)
        case .won:
            updateButtons(stopButtonIsEnabled: false, stepBackButtonIsEnabled: false,
                          playButtonIsEnabled: false, stepForwardButtonIsEnabled: false)
        case .stepping:
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: false,
                          playButtonIsEnabled: false, stepForwardButtonIsEnabled: false)
        }
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

    // Undo the previous command. If game is already playing, sets `model.runState`
    // to `.paused` and stops after current command execution.
    @IBAction func stepBackButtonPressed(_ sender: UIButton) {
        if model.runState != .running(isAnimating: false) && model.runState != .running(isAnimating: true) {
            logic.stepBack()
        }
        model.runState = .paused
    }

    // Executes the next command. If game is already playing, sets `model.runState`
    // to `.paused` and stops after current command execution.
    @IBAction func stepForwardButtonPressed(_ sender: UIButton) {
        let currentRunState = model.runState
        model.runState = .stepping

        if currentRunState != .running(isAnimating: false) && currentRunState != .running(isAnimating: true) {
            logic.stepForward()
        }
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        model.runState = .running(isAnimating: false)
        logic.run()
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRunStateUpdate(notification:)),
            name: Constants.NotificationNames.runStateUpdated, object: nil)
    }
}
