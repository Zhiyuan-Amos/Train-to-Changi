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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /* Control Panel Logic */
    @IBAction func stopButtonPressed(_ sender: Any) {
        model.runState = .stopped
    }

    @IBAction func stepBackButtonPressed(_ sender: Any) {
        _ = logic.undo()
    }

    @IBAction func stepForwardButtonPressed(_ sender: Any) {
        logic.executeNextCommand()
    }

    @IBAction func playButtonPressed(_ sender: Any) {
        model.runState = .running
        logic.executeCommands()
    }
}
