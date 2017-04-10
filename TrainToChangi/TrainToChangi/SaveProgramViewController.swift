//
//  SaveProgramViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 10/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

protocol SaveProgramDelegate {
    func saveProgram(saveName: String)
}

class SaveProgramViewController: UIViewController {

    @IBOutlet private var textInput: UITextField!
    var saveProgramDelegate: SaveProgramDelegate?

    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        guard let saveProgramDelegate = saveProgramDelegate else {
            return
        }

        // TODO: validate entry
        guard let saveName = textInput.text else {
            return
        }

        print(saveName)
        saveProgramDelegate.saveProgram(saveName: saveName)

        dismiss(animated: true)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
