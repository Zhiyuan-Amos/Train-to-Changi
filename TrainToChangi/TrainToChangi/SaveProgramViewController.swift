//
//  SaveProgramViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 10/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

/**
 * View controller responsible for the save program view
 */
class SaveProgramViewController: UIViewController {

    weak var saveProgramDelegate: SaveProgramDelegate?

    @IBOutlet private var textInput: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!

    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        guard let saveProgramDelegate = saveProgramDelegate else {
            fatalError(Constants.Errors.delegateNotSet)
        }

        guard let saveName = textInput.text,
            isUserInputSaveNameValid(userInput: saveName) else {
                errorMessageLabel.isHidden = false
                return
        }

        saveProgramDelegate.saveProgram(saveName: saveName)
        dismiss(animated: true)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        errorMessageLabel.isHidden = true
    }

    override var prefersStatusBarHidden: Bool {
        return true
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
