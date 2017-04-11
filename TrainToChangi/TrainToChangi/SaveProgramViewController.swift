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
            fatalError("Delegate not set up!")
            return
        }

        guard let saveName = textInput.text,
            isUserInputSaveNameValid(userInput: saveName) else {
            // UI show feedback to user that saving is not successful.
            return
        }

        saveProgramDelegate.saveProgram(saveName: saveName)
        dismiss(animated: true)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // Checks if `userInput` for a level name is valid.
    // A valid input is one that contains more than one
    // non-whitespace character, and is within characterCountLimit.
    private func isUserInputSaveNameValid(userInput: String) -> Bool {
        let hasAtLeastOneNonWhitespaceCharacter =
            userInput.trimmingCharacters(in: .whitespaces) != ""
        let isWithinCharacterCountLimit =
            userInput.characters.count <= 30
        return hasAtLeastOneNonWhitespaceCharacter && isWithinCharacterCountLimit
    }
}
