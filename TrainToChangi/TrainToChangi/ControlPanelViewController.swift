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

    @IBAction func stopButtonPressed(_ sender: UIButton) {
        model.runState = .stopped
    }

    @IBAction func stepBackButtonPressed(_ sender: UIButton) {
        _ = logic.undo()
    }

    @IBAction func stepForwardButtonPressed(_ sender: UIButton) {
        logic.executeNextCommand()
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        model.runState = .running
        logic.executeCommands()
    }
}
