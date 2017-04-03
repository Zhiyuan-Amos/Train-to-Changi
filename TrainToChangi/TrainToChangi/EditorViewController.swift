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

    @IBOutlet weak var availableCommandsView: UIView!
    @IBOutlet weak var levelDescriptionTextView: UITextView!
    @IBOutlet weak var programCounter: UIImageView!
    @IBOutlet weak var currentCommandsView: UIView!
    @IBOutlet weak var lineNumberView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLevelDescription()
        loadAvailableCommands()
        adjustCurrentCommandsCollectionView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embeddedVC = segue.destination as? DragDropViewController {
            embeddedVC.model = self.model
        }
        if let embeddedVC = segue.destination as? LineNumberViewController {
            embeddedVC.model = self.model
        }
    }

    // Initialise the height for level description
    private func setUpLevelDescription() {
        levelDescriptionTextView.text = model.currentLevel.levelDescriptor

        let defaultWidth = levelDescriptionTextView.frame.size.width
        let sizeThatFits = CGSize(width: defaultWidth,
                                  height: CGFloat.greatestFiniteMagnitude)
        let newSize = levelDescriptionTextView.sizeThatFits(sizeThatFits)
        levelDescriptionTextView.frame.size = CGSize(width: max(newSize.width, defaultWidth),
                                                     height: newSize.height)

    }

    private func adjustCurrentCommandsCollectionView() {
        currentCommandsView.frame.origin.y = levelDescriptionTextView.frame.maxY
                                            + levelDescriptionTextView.frame.size.height
                                            + 10

        currentCommandsView.frame.size.height = view.frame.height
                                                - currentCommandsView.frame.origin.y

        lineNumberView.frame.origin.y = levelDescriptionTextView.frame.maxY
                                        + levelDescriptionTextView.frame.size.height
                                        + 10
        
        lineNumberView.frame.size.height = view.frame.height
                                            - lineNumberView.frame.origin.y

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

            let commandButton = UIEntityHelper.generateCommandUIButton(for: command,
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
