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

    override func viewDidLoad() {
        initSlider()
        registerObservers()
    }

    private func initSlider() {
        speedSlider.value = 0.0
        speedSlider.minimumTrackTintColor = UIColor.init(red: 0.501, green: 0.796,
                                                         blue: 0.768, alpha: 1)
        speedSlider.thumbTintColor = UIColor.init(red: 0, green: 0.588,
                                                  blue: 0.533, alpha: 1)
        speedSlider.maximumTrackTintColor = UIColor.init(red: 0, green: 0.301,
                                                         blue: 0.251, alpha: 1)
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
    @objc fileprivate func handleRunStateUpdate(notification: Notification) {
        switch model.runState {
        case .running:
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: true,
                          playPauseButtonIsEnabled: true, stepForwardButtonIsEnabled: true)
            playPauseButton.setImage(UIImage(named: "pausebutton"), for: .normal)
        case .paused:
            let stepBackButtonIsEnabled = !logic.canUndo
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: stepBackButtonIsEnabled,
                          playPauseButtonIsEnabled: true, stepForwardButtonIsEnabled: true)
            playPauseButton.setImage(UIImage(named: "playbutton"), for: .normal)
        case .lost:
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: true,
                          playPauseButtonIsEnabled: false, stepForwardButtonIsEnabled: false)
            playPauseButton.setImage(UIImage(named: "playbutton"), for: .normal)
        case .won:
            updateButtons(stopButtonIsEnabled: false, stepBackButtonIsEnabled: false,
                          playPauseButtonIsEnabled: false, stepForwardButtonIsEnabled: false)
            playPauseButton.setImage(UIImage(named: "playbutton"), for: .normal)
        case .stepping:
            updateButtons(stopButtonIsEnabled: true, stepBackButtonIsEnabled: false,
                          playPauseButtonIsEnabled: false, stepForwardButtonIsEnabled: false)
            playPauseButton.setImage(UIImage(named: "playbutton"), for: .normal)
        case .start:
            updateButtons(stopButtonIsEnabled: false, stepBackButtonIsEnabled: false,
                          playPauseButtonIsEnabled: true, stepForwardButtonIsEnabled: true)
            playPauseButton.setImage(UIImage(named: "playbutton"), for: .normal)
        }
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
        if playPauseButton.currentImage == UIImage(named: "playbutton") {
            model.runState = .running(isAnimating: false)
            logic.run()
        } else if playPauseButton.currentImage == UIImage(named: "pausebutton") {
            if model.runState == .running(isAnimating: false) {
                model.runState = .stepping(isAnimating: false)
            } else if model.runState == .running(isAnimating: true) {
                model.runState = .stepping(isAnimating: true)
            }
        }
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRunStateUpdate(notification:)),
            name: Constants.NotificationNames.runStateUpdated, object: nil)
    }
}
