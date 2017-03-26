//
//  GameViewController.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 13/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import SpriteKit

protocol GameVCTouchDelegate: class {
    func memoryIndex(at: CGPoint) -> Int?
}

class GameViewController: UIViewController {

    // VC is currently first responder, to be changed when we add other views.
    fileprivate var model: Model
    fileprivate var logic: Logic

    // The area which shows availableCommandsForUser
    @IBOutlet private var availableCommandsView: UIView!

    @IBOutlet weak var editor: UIView!
    @IBOutlet private var commandsEditor: UICollectionView!

    // The level description.
    @IBOutlet private var levelDescription: UITextView!

    required init?(coder aDecoder: NSCoder) {
        // Change level by setting levelIndex here.
        model = ModelManager(levelData: LevelDataHelper.levelData(levelIndex: 0))
        logic = LogicManager(model: model)
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(
            self, selector: #selector(animationBegan(notification:)),
            name: Constants.NotificationNames.animationBegan, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(animationEnded(notification:)),
            name: Constants.NotificationNames.animationEnded, object: nil)
    }

    @objc fileprivate func animationBegan(notification: Notification) {
        model.runState = .running(isAnimating: true)
    }

    @objc fileprivate func animationEnded(notification: Notification) {
        model.runState = .running(isAnimating: false)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        connectDataSourceAndDelegate()

        setUpLevelDescription()
        loadAvailableCommands()

        adjustCommandsEditorPosition()
        addLongPressGestureRecognizerToCommandsEditor()

        presentGameScene()
        AudioPlayer.sharedInstance.playBackgroundMusic()
    }

    /* Control Panel Logic */
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        model.runState = .stopped
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        model.runState = .running(isAnimating: false)
        logic.executeCommands()
    }

    @IBAction func stepBackButtonPressed(_ sender: Any) {
        _ = logic.undo()
    }

    @IBAction func stepForwardButtonPressed(_ sender: Any) {
        logic.executeNextCommand()
    }

    @IBAction func resetButtonPressed(_ sender: UIButton) {
        model.clearAllCommands()
        commandsEditor.reloadData()
    }

    @IBAction func exitButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: {
            AudioPlayer.sharedInstance.stopBackgroundMusic()
        })
    }

    /* Setup */
    private func adjustCommandsEditorPosition() {
        commandsEditor.frame = CGRect(x: commandsEditor.frame.minX,
                                      y: levelDescription.frame.maxY + 5,
                                      width: commandsEditor.frame.width - 5,
                                      height: editor.frame.height - levelDescription.frame.height - 80)
    }

    private func connectDataSourceAndDelegate() {
        commandsEditor.dataSource = self
        commandsEditor.delegate = self
    }

    private func setUpLevelDescription() {
        levelDescription.text = model.currentLevel.levelDescriptor

        let fixedWidth = levelDescription.frame.size.width
        let newSize = levelDescription.sizeThatFits(CGSize(width: fixedWidth,
                                                           height: CGFloat.greatestFiniteMagnitude))
        var newFrame = levelDescription.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        levelDescription.frame = newFrame
    }

    func loadAvailableCommands() {
        let initialCommandPosition = availableCommandsView.frame.origin
        var commandIndex = 0
        var commandButtonOffsetY: CGFloat = Constants.UI.commandButtonInitialOffsetY

        for command in model.currentLevel.availableCommands {
            let currentCommandPositionX = initialCommandPosition.x
            let currentCommandPositionY = initialCommandPosition.y + commandButtonOffsetY

            let currentCommandPosition = CGPoint(x: currentCommandPositionX,
                                                 y: currentCommandPositionY)

            let currentCommandSize = CGSize(width: getCommandButtonWidth(command),
                                            height: Constants.UI.commandButtonHeight)
            let currentCommandFrame = CGRect(origin: currentCommandPosition,
                                             size: currentCommandSize)

            let currentCommandButton = generateCommandUIButton(for: command, frame: currentCommandFrame)
            currentCommandButton.tag = commandIndex
            commandIndex += 1
            commandButtonOffsetY += Constants.UI.commandButtonOffsetY
            view.addSubview(currentCommandButton)
        }
    }

    /* Gestures */
    private func addLongPressGestureRecognizerToCommandsEditor() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.3
        commandsEditor.addGestureRecognizer(longPressGesture)
    }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: commandsEditor)
        if let commandCell = getCellAtGestureLocation(location) {
            let transformAnim  = CAKeyframeAnimation(keyPath:"transform")
            transformAnim.values  = [NSValue(caTransform3D: CATransform3DMakeRotation(0.04, 0.0, 0.0, 1.0)),
                                     NSValue(caTransform3D: CATransform3DMakeRotation(-0.04, 0, 0, 1))]
            transformAnim.autoreverses = true
            transformAnim.duration  = 0.2
            transformAnim.repeatCount = Float.infinity

            switch gesture.state {
            case UIGestureRecognizerState.began:
                let indexPath = commandsEditor.indexPathForItem(at: gesture.location(in: commandsEditor))
                guard let selectedIndexPath = indexPath else {
                    break
                }
                commandsEditor.beginInteractiveMovementForItem(at: selectedIndexPath)
                commandCell.layer.add(transformAnim, forKey: "transform")
            case UIGestureRecognizerState.changed:
                commandsEditor.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            case UIGestureRecognizerState.ended:
                commandCell.layer.removeAllAnimations()
                commandsEditor.endInteractiveMovement()
            default:
                commandsEditor.cancelInteractiveMovement()
            }
        }
    }

    /// Use GameScene to move/animate the game objects
    func presentGameScene() {
        let scene = GameScene(size: view.bounds.size)
        guard let skView = view as? SKView else {
            assertionFailure("View should be a SpriteKit View!")
            return
        }
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        scene.initLevelState(model.currentLevel)
    }

    /* Helper func */
    private func generateCommandUIButton(for commandType: CommandData, frame: CGRect) -> UIButton {
        let currentCommandButton = UIButton(frame: frame)
        let imagePath = commandType.toString() + ".png"

        currentCommandButton.setImage(UIImage(named: imagePath), for: UIControlState.normal)
        currentCommandButton.addTarget(self, action: #selector(commandButtonPressed), for: .touchUpInside)
        return currentCommandButton
    }

    private func getCommandButtonWidth(_ commandType: CommandData) -> CGFloat {
        switch commandType {
        case .add(_), .jumpTarget:
            return Constants.UI.commandButtonWidthShort
        case .inbox, .outbox, .jump:
            return Constants.UI.commandButtonWidthMid
        case .copyTo(_), .copyFrom(_):
            return Constants.UI.commandButtonWidthLong
        }
    }

    @objc private func commandButtonPressed(sender: UIButton) {
        let command = model.currentLevel.availableCommands[sender.tag]
        model.addCommand(commandEnum: command)
        if command == CommandData.jump {
            commandsEditor.insertItems(at: [IndexPath(item: model.userEnteredCommands.count - 2, section: 0),
                                            IndexPath(item: model.userEnteredCommands.count - 1, section: 0)])
            let jumpTargetIndex = model.userEnteredCommands.count - 2
            let jumpIndex = model.userEnteredCommands.count - 1

            guard let jumpTargetCell = commandsEditor.cellForItem(at: IndexPath(item: jumpTargetIndex,
                                                                                section: 0)) else {
                                                                                    return
            }

            guard let jumpCell = commandsEditor.cellForItem(at: IndexPath(item: jumpIndex,
                                                                          section: 0)) else {
                                                                            return
            }

            let arrowOrigin = CGPoint(jumpTargetCell.frame.maxX - 30, jumpTargetCell.frame.midY)
            let arrowSize = CGSize(width: 20, height: jumpCell.frame.midY - jumpTargetCell.frame.midY)
            let arrowView = UIImageView()
            arrowView.image = UIImage(named: "arrownavy.png")
            arrowView.frame = CGRect(origin: arrowOrigin, size: arrowSize)

            commandsEditor.addSubview(arrowView)
        } else {
            commandsEditor.insertItems(at: [IndexPath(item: model.userEnteredCommands.count - 1, section: 0)])
        }
    }

    private func getCellAtGestureLocation(_ location: CGPoint) -> CommandCell? {
        let indexPath = commandsEditor.indexPathForItem(at: location)
        guard let path = indexPath else {
            return nil
        }

        let cell = commandsEditor.cellForItem(at: path)
        return cell as? CommandCell
    }
}

extension GameViewController: MapViewControllerDelegate {
    func initLevel(name: String?) {
        model = ModelManager(levelData: LevelDataHelper.levelData(levelIndex: 0))
        logic = LogicManager(model: model)
    }
}

extension GameViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.userEnteredCommands.count
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        model.moveCommand(fromIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.UI.commandCellIdentifier,
                                                      for: indexPath)

        guard let commandCell =  cell as? CommandCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }

        let command = model.userEnteredCommands[indexPath.item]
        commandCell.setImageAndIndex(commandType: command)
        return commandCell
    }

}

extension GameViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width - 10,
                      height: Constants.UI.commandButtonHeight - 10)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        let edgeInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 10)
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
