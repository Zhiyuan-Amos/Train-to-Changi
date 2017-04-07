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

    var model: Model!
    var resetGameDelegate: ResetGameDelegate!

    @IBOutlet weak var availableCommandsView: UIView!
    @IBOutlet weak var levelDescriptionTextView: UITextView!
    @IBOutlet weak var currentCommandsView: UIView!
    @IBOutlet weak var lineNumberView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLevelDescription()
        loadAvailableCommands()
        registerObservers()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embeddedVC = segue.destination as? DragDropViewController {
            embeddedVC.model = self.model
            embeddedVC.resetGameDelegate = resetGameDelegate
        }
        if let embeddedVC = segue.destination as? LineNumberViewController {
            embeddedVC.model = self.model
        }
    }

    // Initialise the height for level description
    private func setUpLevelDescription() {
        levelDescriptionTextView.text = model.currentLevel.levelDescriptor
        levelDescriptionTextView.isScrollEnabled = true
    }

    // Load the available commands from model for the current level
    func loadAvailableCommands() {
        let initialCommandPosition = availableCommandsView.frame.origin
        availableCommandsView.frame.size.height = 0

        for (commandTag, command) in model.currentLevel.availableCommands.enumerated() {
            let currentCommandPositionY = initialCommandPosition.y +
                CGFloat(commandTag) * Constants.UI.commandButtonOffsetY

            let buttonPosition = CGPoint(x: initialCommandPosition.x,
                                         y: currentCommandPositionY)

            let commandButton = UIEntityDrawer.generateCommandUIButton(for: command,
                                                                       position: buttonPosition,
                                                                       tag: commandTag)
            commandButton.addTarget(self, action: #selector(commandButtonPressed), for: .touchUpInside)
            commandButton.frame = view.convert(commandButton.frame, to: availableCommandsView)
            availableCommandsView.frame.size.height += commandButton.frame.size.height
            availableCommandsView.addSubview(commandButton)
        }
    }

    // MARK: - Button Actions Func
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
            availableCommandsView.isUserInteractionEnabled = false
            availableCommandsView.isHidden = true
        case .paused, .lost:
            availableCommandsView.isUserInteractionEnabled = true
            availableCommandsView.isHidden = true
        case .start:
            availableCommandsView.isUserInteractionEnabled = true
            availableCommandsView.isHidden = false
        }
    }
}
