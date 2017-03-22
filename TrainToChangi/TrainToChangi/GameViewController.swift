//
//  GameViewController.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 13/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import SpriteKit

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
        model = ModelManager(stationName: "Introduction")
        logic = LogicManager(model: model)
        // Previous view should have passed me the level. Simulate this.
        level = PreloadedLevels.levelOne
        super.init(coder: aDecoder)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLevelDescription()
        loadAvailableCommands()
        connectDataSourceAndDelegate()
        addPanGestureRecognizerToCommandsEditor()
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
    }


    /* Control Panel Logic */
    // Stop the game. Change runstate to .stop in model
    @IBAction func stopButtonPressed(_ sender: UIButton) {
    }

    // Start the game. Change runstate to .start in model
    @IBAction func playButtonPressed(_ sender: UIButton) {
        model.runState = .running
        logic.executeCommands()
    }

    @IBAction func resetButtonPressed(_ sender: UIButton) {
        model.clearAllCommands()
        print(model.currentCommands.count)
        commandsEditor.reloadData()
    }

    /* Setup */
    private func connectDataSourceAndDelegate() {
        commandsEditor.dataSource = self
        commandsEditor.delegate = self
    }

    private func setUpLevelDescription() {
        levelDescription.text = level.levelDescriptor
    }


    func loadAvailableCommands() {
        // Previous view should have passed me the level. Simulate this.
        let level = PreloadedLevels.levelOne

        let initialCommandPosition = availableCommandsView.frame.origin
        var commandIndex = 0
        var commandButtonOffsetY: CGFloat = Constants.commandButtonInitialOffsetY

        for command in level.commandTypes {
            let currentCommandPositionX = initialCommandPosition.x
            let currentCommandPositionY = initialCommandPosition.y + commandButtonOffsetY

            let currentCommandPosition = CGPoint(x: currentCommandPositionX,
                                                 y: currentCommandPositionY)
            let currentCommandSize = CGSize(width: Constants.commandButtonWidth,
                                            height: Constants.commandButtonHeight)
            let currentCommandFrame = CGRect(origin: currentCommandPosition,
                                             size: currentCommandSize)

            let currentCommandButton = getCommandUIButton(for: command, frame: currentCommandFrame)
            currentCommandButton.tag = commandIndex
            commandIndex += 1
            commandButtonOffsetY += Constants.commandButtonOffsetY
            view.addSubview(currentCommandButton)
        }
    }

    /* Gestures */
    private func addPanGestureRecognizerToCommandsEditor() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        commandsEditor.addGestureRecognizer(panGesture)
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
    }

    /// Use GameScene to move/animate the game character and ..
    // TODO: Integrate with gamescene
    private func presentGameScene() {
        let scene = GameScene(size: view.bounds.size)
        guard let skView = view as? SKView else {
            assertionFailure("View should be a SpriteKit View!")
            return
        }
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }


    /* Helper func */
    fileprivate func getLabel(for commandType: CommandType) -> CommandLabel {
        let commandLabel = CommandLabel()
        commandLabel.updateText(commandType: commandType)
        return commandLabel
    }


    /// Use GameScene to move/animate the game character and ..
    // TODO: Integrate with gamescene
    func presentGameScene() {
        let scene = GameScene(size: view.bounds.size)
        guard let skView = view as? SKView else {
            assertionFailure("View should be a SpriteKit View!")
            return
        }
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        scene.initLevelState(level.initialState)
    }

    @objc private func buttonPressed(sender: UIButton) {
        let command = level.availableCommands[sender.tag]
        model.addCommand(commandEnum: command)
        commandsEditor.reloadData()
    }


    private func getCommandUIButton(for commandType: CommandType, frame: CGRect) -> UIButton {
        let currentCommandButton = UIButton(frame: frame)
        switch commandType {
        case .add(_):
            currentCommandButton.setImage(UIImage(named: "add.png"), for: UIControlState.normal)
        case .copyFrom(_):
            currentCommandButton.setImage(UIImage(named: "copyfrom.png"), for: UIControlState.normal)
        case .copyTo(_):
            currentCommandButton.setImage(UIImage(named: "copyto.png"), for: UIControlState.normal)
        case .inbox:
            currentCommandButton.setImage(UIImage(named: "inbox.png"), for: UIControlState.normal)
        case .jump(_):
            currentCommandButton.setImage(UIImage(named: "jump.png"), for: UIControlState.normal)
        case .outbox:
            currentCommandButton.setImage(UIImage(named: "outbox.png"), for: UIControlState.normal)
        case .placeHolder:
            currentCommandButton.setImage(UIImage(named: "jumptarget.png"), for: UIControlState.normal)
        }

        currentCommandButton.addTarget(self, action: #selector(commandButtonPressed), for: .touchUpInside)
        return currentCommandButton
    }

    @objc private func commandButtonPressed(sender: UIButton) {
        let command = level.commandTypes[sender.tag]
        model.addCommand(commandType: command)
        commandsEditor.reloadData()
    }
}


// TODO: Refactor magic numbers after the layout is getting finalized
extension GameViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.userEnteredCommands.count
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        let movedCommand = model.removeCommand(fromIndex: sourceIndexPath.row)
        model.insertCommand(commandEnum: movedCommand, atIndex: destinationIndexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        let movedCommand = model.removeCommand(fromIndex: sourceIndexPath.item)
        model.insertCommand(atIndex: destinationIndexPath.item, commandType: movedCommand)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommandCell",
                                                            for: indexPath as IndexPath) as? CommandCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }

        // assign image to cell based on the command type.
        let command = model.currentCommands[indexPath.item]
        cell.setImageAndIndex(commandType: command)
        return cell
    }

}

extension GameViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = UIEdgeInsets(top: 10,
                                     left: 0,
                                     bottom: 0,
                                     right: 10)
        return edgeInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
