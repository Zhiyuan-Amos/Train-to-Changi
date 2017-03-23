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
        commandsEditor.reloadData()
    }

    private func setUpLevelDescription() {
        levelDescription.text = level.levelDescriptor
    }


    func loadAvailableCommands() {
        // Previous view should have passed me the level. Simulate this.
        let level = PreloadedLevels.levelOne

        let initialCommandPosition = availableCommandsView.frame.origin
        var commandOffset: CGFloat = 0

        for command in level.commandTypes {
            let currentCommandPositionX = initialCommandPosition.x
            let currentCommandPositionY = initialCommandPosition.y + commandOffset
            let currentCommandPosition = CGPoint(x: currentCommandPositionX,
                                                 y: currentCommandPositionY)
            let currentCommandSize = CGSize(width: 100, height: 30)

            let currentCommandFrame = CGRect(origin: currentCommandPosition,
                                             size: currentCommandSize)

            let currentCommandButton = UIButton(frame: currentCommandFrame)
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

    @objc private func buttonPressed(sender: UIButton) {
        // Add int to commandtype enum to enable this.
        // With that, code is shorter and doesn't need to change with new commands:
//        guard let command = CommandType(rawValue: sender.tag) else {
//            assertionFailure("Should have a valid tag!")
//            return
//        }
//        model.addCommand(commandType: command)
        // Since the above doesn't work for indexed commands,
        // Have a wrapper class to wrap (CommandType, Index?)
        // Overload constructor to assign nil to commandtype with no index
        // Keep enums as enums

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
        // TODO: Refactor out into CommandImageView.
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
        }
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

    fileprivate func getLabel(for commandEnum: CommandEnum) -> CommandLabel {
        let commandLabel = CommandLabel()
        commandLabel.updateText(commandEnum: commandEnum)
        return commandLabel
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

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCommand = model.removeCommand(fromIndex: sourceIndexPath.row)
        model.insertCommand(atIndex: destinationIndexPath.row, commandType: movedCommand)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommandCell", for: indexPath as IndexPath) as? CommandCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }
        // assign image to cell based on the command type.
        let command = model.currentCommands[indexPath.row]
        let image = getImage(for: command)
        cell.setImage(image)
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
        return CGSize(width: width * 0.6, height: 30.0)
    }
}
