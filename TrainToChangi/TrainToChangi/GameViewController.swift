//
//  GameViewController.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 13/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import SpriteKit

// What should be in the scene, what should be in ViewController?
// ViewController:
// -Buttons (Play, stop, back..)
// -EditorView (The place to drop the commands)
// -CommandsView (The place to get available commands from)
// Scene:
// -The rest? How to pass the level to scene? E.g. number of memory locations
// Subclass GameScene and pass in level in presentGameScene()?

// Full drag and drop is not implemented yet.
// Click on commands to add them to editor.
// Able to move these commands in editor around normally.
// Deletion of commands not supported, use reset button to clear.

// Scrolling interferes with pan gesture when reordering.
// There is a workaround but it will both pan & scroll at the same time.
// Maybe put another view on top of the editor then set the pan
// gesture to be on this view? Then leave the right side for scrolling.
class GameViewController: UIViewController {

    // VC is currently first responder, to be changed when we add other views.
    fileprivate let model: Model
    private let logic: Logic
    private let level: Level

    // TODO: Refactor out
    let commandCellIdentifier = "CommandCell"

    // TODO: change to another Collectionview then
    // implement drag & drop
    // The area which shows availableCommandsForUser
    @IBOutlet private var availableCommandsView: UIView!

    // The level description.
    // To create programatically so size varies.
    @IBOutlet private var levelDescription: UITextView!

    // The area which user programs by dropping commands.
    @IBOutlet private var commandsEditor: UICollectionView!

    required init?(coder aDecoder: NSCoder) {
<<<<<<< HEAD
        model = ModelManager()
        logic = LogicManager(model: model)
        level = model.currentLevel
=======
        model = ModelManager(stationName: "Introduction")
        logic = LogicManager(model: model)
        // Previous view should have passed me the level. Simulate this.
        level = PreloadedLevels.levelOne
>>>>>>> Hacked UI out
        super.init(coder: aDecoder)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD
        setUpLevelDescription()
        loadAvailableCommands()
        connectDataSourceAndDelegate()
        addPanGestureRecognizerToCommandsEditor()
        presentGameScene()
=======
        levelDescription.text = level.levelDescriptor
        loadAvailableCommands()
        commandsEditor.dataSource = self
        commandsEditor.delegate = self
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        commandsEditor.addGestureRecognizer(panGesture)
    }

    func handlePan(gesture: UIPanGestureRecognizer) {
        switch(gesture.state) {

        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = commandsEditor.indexPathForItem(at: gesture.location(in: commandsEditor)) else {
                break
            }
            commandsEditor.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            commandsEditor.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            commandsEditor.endInteractiveMovement()
        default:
            commandsEditor.cancelInteractiveMovement()
        }
>>>>>>> Hacked UI out
    }

    // Stop the game. Change runstate to .stop in model
    @IBAction func stopButtonPressed(_ sender: UIButton) {
    }

    // Start the game. Change runstate to .start in model
    @IBAction func playButtonPressed(_ sender: UIButton) {
<<<<<<< HEAD
        model.runState = .running
=======
>>>>>>> Hacked UI out
        logic.executeCommands()
    }

    @IBAction func resetButtonPressed(_ sender: UIButton) {
        model.clearAllCommands()
        commandsEditor.reloadData()
    }

<<<<<<< HEAD
    private func setUpLevelDescription() {
        levelDescription.text = level.levelDescriptor
    }

    private func loadAvailableCommands() {
        let initialCommandPosition = availableCommandsView.frame.origin
        var commandIndex = 0
        var commandOffset: CGFloat = 0

        for command in level.availableCommands {
=======
    func loadAvailableCommands() {
        // Previous view should have passed me the level. Simulate this.
        let level = PreloadedLevels.levelOne
        let initialCommandPosition = availableCommandsView.frame.origin
        var commandOffset: CGFloat = 0

        for command in level.commandTypes {
>>>>>>> Hacked UI out
            let currentCommandPositionX = initialCommandPosition.x
            let currentCommandPositionY = initialCommandPosition.y + commandOffset
            let currentCommandPosition = CGPoint(x: currentCommandPositionX,
                                                 y: currentCommandPositionY)
            let currentCommandSize = CGSize(width: 100, height: 30)

            let currentCommandFrame = CGRect(origin: currentCommandPosition,
                                             size: currentCommandSize)

            let currentCommandButton = UIButton(frame: currentCommandFrame)
<<<<<<< HEAD
            let currentCommandLabel = getLabel(for: command)
            currentCommandButton.setTitle(currentCommandLabel.text, for: .normal)
            currentCommandButton.setTitleColor(UIColor.gray, for: .highlighted)
            currentCommandButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            currentCommandButton.tag = commandIndex
            view.addSubview(currentCommandButton)
            commandIndex += 1
            commandOffset += 40
        }
    }

    private func connectDataSourceAndDelegate() {
        commandsEditor.dataSource = self
        commandsEditor.delegate = self
    }

    private func addPanGestureRecognizerToCommandsEditor() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        commandsEditor.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {

        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = commandsEditor.indexPathForItem(at:
                gesture.location(in: commandsEditor)) else {
                break
            }
            commandsEditor.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            commandsEditor.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            commandsEditor.endInteractiveMovement()
        default:
            commandsEditor.cancelInteractiveMovement()
=======
            let currentCommandImage = getImage(for: command)
            currentCommandButton.setImage(currentCommandImage, for: .normal)
            currentCommandButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            // Int for commandtype enum plz
            switch command {
            case .inbox:
                currentCommandButton.tag = 1
            case .outbox:
                currentCommandButton.tag = 2
            default: fatalError("should not reach here")
            }
            view.addSubview(currentCommandButton)
            commandOffset += 40
        }
        // For commands that require targetIndex, enter MemoryIndexSelectMode after dropping
        // MemorySelectMode: Tap on memory cell. Tapping anywhere else cancels this mode
    }

    func buttonPressed(sender: UIButton) {
        // Add int to commandtype enum to eliminate this.
        if sender.tag == 1 {
            model.addCommand(commandType: .inbox)
        } else if sender.tag == 2 {
            model.addCommand(commandType: .outbox)
        } else {
            fatalError("Should never happen.")
        }
        commandsEditor.reloadData()
    }

    fileprivate func getImage(for commandType: CommandType) -> UIImage {
        // TODO: Refactor
        switch commandType {
        case .inbox:
            guard let image = UIImage(named: "input-temp") else {
                fatalError("input-temp picture missing")
            }
            return image
        case .outbox:
            guard let image = UIImage(named: "output-temp") else {
                fatalError("output-temp picture missing")
            }
            return image
        default: fatalError("should not reach here")
>>>>>>> Hacked UI out
        }
    }

    /// Use GameScene to move/animate the game character and ..
    // TODO: Integrate with gamescene
<<<<<<< HEAD
    private func presentGameScene() {
=======
    func presentGameScene() {
>>>>>>> Hacked UI out
        let scene = GameScene(size: view.bounds.size)
        guard let skView = view as? SKView else {
            assertionFailure("View should be a SpriteKit View!")
            return
        }
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
<<<<<<< HEAD
        scene.initLevelState(level.initialState)
    }

    @objc private func buttonPressed(sender: UIButton) {
        let command = level.availableCommands[sender.tag]
        model.addCommand(commandEnum: command)
        commandsEditor.reloadData()
    }

    fileprivate func getLabel(for commandEnum: CommandEnum) -> CommandLabel {
        let commandLabel = CommandLabel()
        commandLabel.updateText(commandEnum: commandEnum)
        return commandLabel
    }
}

// TODO: Refactor magic numbers after the layout is getting finalized
=======
    }
}

// TODO: refactor magic
>>>>>>> Hacked UI out
extension GameViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
<<<<<<< HEAD
        return model.userEnteredCommands.count
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        let movedCommand = model.removeCommand(fromIndex: sourceIndexPath.row)
        model.insertCommand(commandEnum: movedCommand, atIndex: destinationIndexPath.row)
=======
        return model.currentCommands.count
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCommand = model.removeCommand(fromIndex: sourceIndexPath.row)
        model.insertCommand(atIndex: destinationIndexPath.row, commandType: movedCommand)
>>>>>>> Hacked UI out
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
<<<<<<< HEAD
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
            "CommandCell", for: indexPath as IndexPath) as? CommandCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }
        // assign image to cell based on the command type.
        let command = model.userEnteredCommands[indexPath.row]
        let label = getLabel(for: command)
        cell.setLabel(label)
=======
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommandCell", for: indexPath as IndexPath) as? CommandCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }
        // assign image to cell based on the command type.
        let command = model.currentCommands[indexPath.row]
        let image = getImage(for: command)
        cell.setImage(image)
>>>>>>> Hacked UI out
        return cell
    }

}

extension GameViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = UIEdgeInsets(top: 5,
                                     left: 10,
                                     bottom: 5,
                                     right: 50)
        return edgeInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
<<<<<<< HEAD
        return CGSize(width: width * 0.6, height: 30.0)
=======
        //hardcode
        return CGSize(width: width*0.6, height: 30.0)
>>>>>>> Hacked UI out
    }
}
