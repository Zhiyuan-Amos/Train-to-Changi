//
//  EditorViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 27/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import Foundation

class EditorViewController: UIViewController {

    fileprivate typealias Drawer = UIEntityDrawer
    weak var resetGameDelegate: ResetGameDelegate!
    var model: Model!

    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var editorButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    @IBOutlet weak var availableCommandsView: UIView!
    @IBOutlet weak var lineNumberView: UIView!
    @IBOutlet weak var dragDropView: UIView!
    @IBOutlet weak var descriptionView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvailableCommandsView()
        registerObservers()
        descriptionButton.backgroundColor = Constants.Background.levelDescriptionBackgroundColor
    }

    @IBAction func resetButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Constants.NotificationNames.userResetCommandEvent,
                                        object: nil,
                                        userInfo: nil)
        resetGameDelegate.tryResetGame()
    }

    @IBAction func toggleButtonPressed(_ sender: UIButton) {
        let duration = Constants.UI.Duration.toggleAvailableCommandsDuration
        if availableCommandsView.alpha == 0 {
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.availableCommandsView.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: duration, animations: { () -> Void in
                self.availableCommandsView.alpha = 0.0
            })
        }
    }

    @IBAction func descriptionButtonPressed(_ sender: UIButton) {
        descriptionButton.backgroundColor = Constants.Background.levelDescriptionBackgroundColor
        editorButton.backgroundColor = nil
        descriptionView.isHidden = false
        lineNumberView.isHidden = true
        dragDropView.isHidden = true
    }

    @IBAction func editorButtonPressed(_ sender: UIButton) {
        descriptionButton.backgroundColor = nil
        editorButton.backgroundColor = Constants.Background.levelDescriptionBackgroundColor
        descriptionView.isHidden = true
        lineNumberView.isHidden = false
        dragDropView.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embeddedVC = segue.destination as? DragDropViewController {
            embeddedVC.model = self.model
            embeddedVC.resetGameDelegate = resetGameDelegate
        }
        if let embeddedVC = segue.destination as? LineNumberViewController {
            embeddedVC.model = self.model
        }
        if let embeddedVC = segue.destination as? LevelDescriptionViewController {
            embeddedVC.model = self.model
        }
    }

    // Load the available commands from model for the current level
    func setupAvailableCommandsView() {
        let initialY = availableCommandsView.frame.origin.y + Constants.UI.minimumLineSpacingForSection
        let initialX = availableCommandsView.frame.origin.x +  Constants.UI.availableCommandsPaddingX
        availableCommandsView.frame.size.height = 0

        for (commandTag, command) in model.currentLevel.availableCommands.enumerated() {
            let currentCommandPositionY = initialY + CGFloat(commandTag)
                                        * Constants.UI.commandButtonOffsetY

            let buttonOrigin = CGPoint(x: initialX,
                                       y: currentCommandPositionY)

            let commandButton = Drawer.drawCommandButton(command: command, origin: buttonOrigin,
                                                                 interactive: true)
            commandButton.tag = commandTag
            commandButton.addTarget(self, action: #selector(commandButtonPressed), for: .touchUpInside)
            commandButton.frame = view.convert(commandButton.frame, to: availableCommandsView)
            availableCommandsView.frame.size.height += commandButton.frame.size.height + Constants.UI.minimumLineSpacingForSection
            availableCommandsView.addSubview(commandButton)
            
        }
        availableCommandsView.frame.size.height += Constants.UI.minimumLineSpacingForSection
    }

    @objc private func commandButtonPressed(sender: UIButton) {
        let command = model.currentLevel.availableCommands[sender.tag]
        model.addCommand(commandEnum: command)

        NotificationCenter.default.post(name: Constants.NotificationNames.userAddCommandEvent,
                                        object: command,
                                        userInfo: nil)
    }
}

//MARK -- Event Handling
extension EditorViewController {
    fileprivate func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRunStateUpdate(notification:)),
            name: Constants.NotificationNames.runStateUpdated, object: nil)
    }

    // Updates whether the views are enabled depending on the `model.runState`.
    @objc fileprivate func handleRunStateUpdate(notification: Notification) {
        switch model.runState {
        case .running, .won, .stepping:
            resetButton.isEnabled = false
            availableCommandsView.isUserInteractionEnabled = false
        case .paused, .lost:
            resetButton.isEnabled = true
            availableCommandsView.isUserInteractionEnabled = true
        case .start:
            resetButton.isEnabled = true
            availableCommandsView.isUserInteractionEnabled = true
        }
    }
}
