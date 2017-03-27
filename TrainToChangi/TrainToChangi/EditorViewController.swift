//
//  EditorViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 27/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {

    var model: Model!

    @IBOutlet weak var availableCommandsView: UIView!
    @IBOutlet weak var editorView: UIImageView!
    @IBOutlet weak var levelDescriptionTextView: UITextView!
    @IBOutlet weak var currentCommandsView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectDataSourceAndDelegate()

        setUpLevelDescription()
        loadAvailableCommands()

        adjustCommandsEditorPosition()
        addGestureRecognisers()
    }

    /* Setup Code */
    private func connectDataSourceAndDelegate() {
        currentCommandsView.dataSource = self
        currentCommandsView.delegate = self
    }

    private func setUpLevelDescription() {
        levelDescriptionTextView.text = model.currentLevel.levelDescriptor

        let fixedWidth = levelDescriptionTextView.frame.size.width
        let newSize = levelDescriptionTextView.sizeThatFits(CGSize(width: fixedWidth,
                                                                   height: CGFloat.greatestFiniteMagnitude))
        var newFrame = levelDescriptionTextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        levelDescriptionTextView.frame = newFrame
    }

    private func adjustCommandsEditorPosition() {
        let x = currentCommandsView.frame.minX
        let y = levelDescriptionTextView.frame.maxY + 5
        let width = currentCommandsView.frame.width - 5
        let height = editorView.frame.height - levelDescriptionTextView.frame.height - 80

        currentCommandsView.frame = CGRect(x: x, y: y, width: width, height: height)
    }

    func loadAvailableCommands() {
        let initialCommandPosition = availableCommandsView.frame.origin
        var commandButtonOffsetY = Constants.UI.commandButtonInitialOffsetY
        var commandTag = 0

        for command in model.currentLevel.availableCommands {
            let currentCommandPositionX = initialCommandPosition.x
            let currentCommandPositionY = initialCommandPosition.y + commandButtonOffsetY

            let buttonPosition = CGPoint(x: currentCommandPositionX,
                                         y: currentCommandPositionY)


            let commandButton = CommandButtonHelper.generateCommandUIButton(for: command,
                                                                            position: buttonPosition,
                                                                            tag: commandTag)
            commandButton.addTarget(self, action: #selector(commandButtonPressed), for: .touchUpInside)

            commandTag += 1
            commandButtonOffsetY += Constants.UI.commandButtonOffsetY
            view.addSubview(commandButton)
        }
    }

    /* Gestures */
    private func addGestureRecognisers() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.3
        currentCommandsView.addGestureRecognizer(longPressGesture)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        currentCommandsView.addGestureRecognizer(doubleTapGesture)

    }

    @objc private func handleDoubleTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        guard let indexPath = currentCommandsView.indexPathForItem(at: location) else {
                return
        }

        _ = model.removeCommand(fromIndex: indexPath.item)
        currentCommandsView.deleteItems(at: [indexPath])

    }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        guard let indexPath = currentCommandsView.indexPathForItem(at: location),
              let commandCell = currentCommandsView.cellForItem(at: indexPath) else {
            return
        }
        switch gesture.state {
        case UIGestureRecognizerState.began:
            currentCommandsView.beginInteractiveMovementForItem(at: indexPath)
            commandCell.layer.add(AnimationHelper.wiggleAnimation(), forKey: "transform")
        case UIGestureRecognizerState.changed:
            currentCommandsView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            commandCell.layer.removeAllAnimations()
            currentCommandsView.endInteractiveMovement()
        default:
            currentCommandsView.cancelInteractiveMovement()
        }

    }

    /* Helper func */
    @objc private func commandButtonPressed(sender: UIButton) {
        let command = model.currentLevel.availableCommands[sender.tag]
        model.addCommand(commandEnum: command)
        if command == CommandData.jump {
            currentCommandsView.insertItems(at: [IndexPath(item: model.userEnteredCommands.count - 2, section: 0),
                                            IndexPath(item: model.userEnteredCommands.count - 1, section: 0)])
            let jumpTargetIndex = model.userEnteredCommands.count - 2
            let jumpIndex = model.userEnteredCommands.count - 1

            guard let jumpTargetCell = currentCommandsView.cellForItem(at: IndexPath(item: jumpTargetIndex,
                                                                                section: 0)) else {
                                                                                    return
            }

            guard let jumpCell = currentCommandsView.cellForItem(at: IndexPath(item: jumpIndex,
                                                                          section: 0)) else {
                                                                            return
            }

            let arrowOrigin = CGPoint(jumpTargetCell.frame.maxX - 30, jumpTargetCell.frame.midY)
            let arrowSize = CGSize(width: 20, height: jumpCell.frame.midY - jumpTargetCell.frame.midY)
            let arrowView = UIImageView()
            arrowView.image = UIImage(named: "arrownavy.png")
            arrowView.frame = CGRect(origin: arrowOrigin, size: arrowSize)

            currentCommandsView.addSubview(arrowView)
        } else {
            currentCommandsView.insertItems(at: [IndexPath(item: model.userEnteredCommands.count - 1, section: 0)])
        }
    }

    private func getCellAtGestureLocation(_ location: CGPoint) -> CommandCell? {
        let indexPath = currentCommandsView.indexPathForItem(at: location)
        guard let path = indexPath else {
            return nil
        }

        let cell = currentCommandsView.cellForItem(at: path)
        return cell as? CommandCell
    }
}

extension EditorViewController: UICollectionViewDataSource {

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

extension EditorViewController: UICollectionViewDelegateFlowLayout {

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
