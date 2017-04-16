//
//  ControlPanelViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 27/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

/**
 * View Controller responsible for the control panel
 */
class ControlPanelViewController: UIViewController {

    var model: Model!
    var logic: Logic!
    weak var resetGameDelegate: ResetGameDelegate!

    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var stepBackButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var stepForwardButton: UIButton!

    @IBAction func sliderShifted(_ sender: UISlider) {
        NotificationCenter.default.post(Notification(
            name: Constants.NotificationNames.sliderShifted,
            object: nil, userInfo: ["sliderValue": sender.value]))
    }

    @IBAction func stopButtonPressed(_ sender: UIButton) {
        if model.runState == .running(isAnimating: true)
            || model.runState == .stepping(isAnimating: true) {
            NotificationCenter.default.post(Notification(
                name: Constants.NotificationNames.animationEnded,
                object: nil, userInfo: nil))

            resetGameDelegate.resetGame(isAnimating: true)
        } else {
            resetGameDelegate.resetGame(isAnimating: false)
        }
    }

    // Undo the previous command. If game is already playing, sets `model.runState`
    // to `.stepping` and stops after current command execution.
    @IBAction func stepBackButtonPressed(_ sender: UIButton) {
        if model.runState == .running(isAnimating: false) {
            model.runState = .stepping(isAnimating: false)
        } else if model.runState == .running(isAnimating: true) {
            model.runState = .stepping(isAnimating: true)
        } else {
            logic.stepBack()
            model.runState = .paused
        }
    }

    // Executes the next command. If game is already playing, sets `model.runState`
    // to `.stepping` and stops after current command execution.
    @IBAction func stepForwardButtonPressed(_ sender: UIButton) {
        if model.runState == .running(isAnimating: false) {
            model.runState = .stepping(isAnimating: false)
        } else if model.runState == .running(isAnimating: true) {
            model.runState = .stepping(isAnimating: true)
        } else {
            model.runState = .stepping(isAnimating: false)
            logic.stepForward()
        }
    }
    // if .running then make it pausebutton. as long as not running, make it play button.
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        if playPauseButton.currentImage == Constants.UI.ControlPanel.playButtonImage {
            model.runState = .running(isAnimating: false)
            logic.run()
        } else if playPauseButton.currentImage == Constants.UI.ControlPanel.pauseButtonImage {
            if model.runState == .running(isAnimating: false) {
                model.runState = .stepping(isAnimating: false)
            } else if model.runState == .running(isAnimating: true) {
                model.runState = .stepping(isAnimating: true)
            }
        }
    }

    override func viewDidLoad() {
        registerObservers()
        speedSlider.value = 0.0
    }

}

// MARK -- Event Handling
extension ControlPanelViewController {

    fileprivate func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRunStateUpdate(notification:)),
            name: Constants.NotificationNames.runStateUpdated, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleUpdateCommandIndex(notification:)),
            name: Constants.NotificationNames.updateCommandIndexEvent, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleCancelUpdateCommandIndex(notification:)),
            name: Constants.NotificationNames.cancelUpdateCommandIndexEvent, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleCancelUpdateCommandIndex(notification:)),
            name: Constants.NotificationNames.userSelectedIndexEvent, object: nil)
    }

    @objc fileprivate func handleUpdateCommandIndex(notification: Notification) {
        updateButtons(stopButtonIsEnabled: false, stepBackButtonIsEnabled: false,
                      playPauseButtonIsEnabled: false, stepForwardButtonIsEnabled: false)
    }

    @objc fileprivate func handleCancelUpdateCommandIndex(notification: Notification) {
        updateButtonsBasedOnRunState()
    }

    @objc fileprivate func handleRunStateUpdate(notification: Notification) {
        updateButtonsBasedOnRunState()
    }

    // Updates whether the buttons are enabled.
    private func updateButtons(stopButtonIsEnabled: Bool, stepBackButtonIsEnabled: Bool,
                               playPauseButtonIsEnabled: Bool, stepForwardButtonIsEnabled: Bool) {

        stopButton.isEnabled = stopButtonIsEnabled
        stepBackButton.isEnabled = stepBackButtonIsEnabled
        playPauseButton.isEnabled = playPauseButtonIsEnabled
        stepForwardButton.isEnabled = stepForwardButtonIsEnabled
    }

    // Updates whether the buttons are enabled depending on the `model.runState`.
    private func updateButtonsBasedOnRunState() {
        switch model.runState {
        case .running:
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: true,
                          playPauseButtonIsEnabled: true, stepForwardButtonIsEnabled: true)
            playPauseButton.setImage(Constants.UI.ControlPanel.pauseButtonImage, for: .normal)
        case .paused:
            let stepBackButtonIsEnabled = !logic.canUndo
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: stepBackButtonIsEnabled,
                          playPauseButtonIsEnabled: true, stepForwardButtonIsEnabled: true)
            playPauseButton.setImage(Constants.UI.ControlPanel.playButtonImage, for: .normal)
        case .lost:
            let stepBackButtonIsEnabled = !logic.canUndo
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: stepBackButtonIsEnabled,
                          playPauseButtonIsEnabled: false, stepForwardButtonIsEnabled: false)
            playPauseButton.setImage(Constants.UI.ControlPanel.playButtonImage, for: .normal)
        case .won:
            updateButtons(stopButtonIsEnabled: false, stepBackButtonIsEnabled: false,
                          playPauseButtonIsEnabled: false, stepForwardButtonIsEnabled: false)
            playPauseButton.setImage(Constants.UI.ControlPanel.playButtonImage, for: .normal)
        case .stepping:
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: false,
                          playPauseButtonIsEnabled: false, stepForwardButtonIsEnabled: false)
            playPauseButton.setImage(Constants.UI.ControlPanel.playButtonImage, for: .normal)
        case .start:
            updateButtons(stopButtonIsEnabled: false, stepBackButtonIsEnabled: false,
                          playPauseButtonIsEnabled: true, stepForwardButtonIsEnabled: true)
            playPauseButton.setImage(Constants.UI.ControlPanel.playButtonImage, for: .normal)
        }
    }
}
