//
//  EndGameViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 6/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class EndGameViewController: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func returnButtonPressed(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
        presentingViewController!.dismiss(animated: true, completion: nil)
    }
}
