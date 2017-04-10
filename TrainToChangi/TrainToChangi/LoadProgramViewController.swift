//
//  LoadProgramViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 10/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class LoadProgramViewController: UIViewController {

    @IBOutlet weak var programCollectionView: UICollectionView!

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }

    //TODO - on tap on collection cell, send notification to add commands
}
