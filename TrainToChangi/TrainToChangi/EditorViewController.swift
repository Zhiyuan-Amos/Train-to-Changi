//
//  EditorViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 27/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import Foundation

/**
 * View Controller responsible for the commands editor
 */
class EditorViewController: UIViewController {

    fileprivate typealias Drawer = UIEntityDrawer

    weak var dataServiceLoadProgramDelegate: DataServiceLoadProgramDelegate!
    weak var resetGameDelegate: ResetGameDelegate!
    weak var saveProgramDelegate: SaveProgramDelegate!
    weak var commandsEditorUpdateDelegate: CommandsEditorUpdateDelegate!

    var model: Model!
    private var dragDropVC: DragDropViewController?
    private var lineNumberVC: LineNumberViewController?

    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var editorButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    @IBOutlet weak var availableCommandsView: UIView!
    @IBOutlet weak var lineNumberView: UIView!
    @IBOutlet weak var dragDropView: UIView!
    @IBOutlet weak var descriptionView: UIView!

    @IBAction func resetButtonPressed(_ sender: UIButton) {
        resetGameDelegate.tryResetGame()
        presentEditorView()
        commandsEditorUpdateDelegate.resetCommands()
    }

    // Setup and present the load program modal view
    @IBAction func loadButtonPressed(_ sender: UIButton) {
        let identifier = Constants.UI.loadProgramViewControllerIdentifier
        guard let loadProgramController = loadModalViewControllers(identifier: identifier)
            as? LoadProgramViewController else {
                fatalError(Constants.Errors.wrongViewControllerLoaded)
        }
        loadProgramController.loadProgramDelegate = dataServiceLoadProgramDelegate
        self.present(loadProgramController, animated: true, completion: nil)
    }

    // Setup and present the save program modal view
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let identifier = Constants.UI.saveProgramViewControllerIdentifier
        guard let saveProgramController = loadModalViewControllers(identifier: identifier)
            as? SaveProgramViewController else {
            fatalError(Constants.Errors.wrongViewControllerLoaded)
        }
        saveProgramController.saveProgramDelegate = saveProgramDelegate
        self.present(saveProgramController, animated: true, completion: nil)
    }

    @IBAction func descriptionButtonPressed(_ sender: UIButton) {
        presentDescriptionView()
    }

    @IBAction func editorButtonPressed(_ sender: UIButton) {
        presentEditorView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvailableCommandsView()
        registerObservers()
        descriptionButton.backgroundColor = Constants.Background.levelDescriptionBackgroundColor
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let embeddedVC = segue.destination as? DragDropViewController {
            embeddedVC.model = self.model
            embeddedVC.resetGameDelegate = resetGameDelegate
            dataServiceLoadProgramDelegate = embeddedVC
            saveProgramDelegate = embeddedVC
            commandsEditorUpdateDelegate = embeddedVC
            dragDropVC = embeddedVC

            if lineNumberVC != nil {
                embeddedVC.lineNumberUpdateDelegate = lineNumberVC
            }
        }
        if let embeddedVC = segue.destination as? LineNumberViewController {
            embeddedVC.model = self.model
            lineNumberVC = embeddedVC
            dragDropVC?.lineNumberUpdateDelegate = embeddedVC
        }
        if let embeddedVC = segue.destination as? LevelDescriptionViewController {
            embeddedVC.model = self.model
        }
    }

    private func presentDescriptionView() {
        descriptionButton.backgroundColor = Constants.Background.levelDescriptionBackgroundColor
        editorButton.backgroundColor = nil
        descriptionView.isHidden = false
        lineNumberView.isHidden = true
        dragDropView.isHidden = true
    }

    fileprivate func presentEditorView() {
        editorButton.backgroundColor = Constants.Background.levelDescriptionBackgroundColor
        descriptionButton.backgroundColor = nil
        descriptionView.isHidden = true
        lineNumberView.isHidden = false
        dragDropView.isHidden = false
    }

    // Load the available commands from model for the current level
    fileprivate func setupAvailableCommandsView() {
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
            availableCommandsView.frame.size.height += commandButton.frame.size.height
                                                        + Constants.UI.minimumLineSpacingForSection
            availableCommandsView.addSubview(commandButton)

        }
        availableCommandsView.frame.size.height += Constants.UI.minimumLineSpacingForSection
    }

    @objc private func commandButtonPressed(sender: UIButton) {
        let command = model.currentLevel.availableCommands[sender.tag]
        model.addCommand(commandEnum: command)
        commandsEditorUpdateDelegate.addNewCommand(command: command)
        presentEditorView()
    }

    private func loadModalViewControllers(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: Constants.UI.mainStoryboardIdentifier, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        return controller

    }
}

//MARK: - Event Handling
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
            presentEditorView()
            resetButton.isEnabled = false
            descriptionButton.isEnabled = false
            availableCommandsView.isUserInteractionEnabled = false
            availableCommandsView.isHidden = true
        case .paused, .lost:
            resetButton.isEnabled = true
            descriptionButton.isEnabled = true
            availableCommandsView.isUserInteractionEnabled = true
            availableCommandsView.isHidden = true
        case .start:
            resetButton.isEnabled = true
            descriptionButton.isEnabled = true
            availableCommandsView.isUserInteractionEnabled = true
            availableCommandsView.isHidden = false
        }
    }
}
