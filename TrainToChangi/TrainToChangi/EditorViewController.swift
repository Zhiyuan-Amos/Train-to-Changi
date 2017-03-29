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
    private var jumpBundles = [JumpBundle]()

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

    @IBAction func resetButtonPressed(_ sender: Any) {
        model.clearAllCommands()
        removeAllJumpArrows()
        jumpBundles.removeAll()
        currentCommandsView.reloadData()
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

            let commandButton = UIEntityHelper.generateCommandUIButton(for: command,
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

        let doubleTapGesture = UITapGestureRecognizer (target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        currentCommandsView.addGestureRecognizer(doubleTapGesture)

        let singleTapGesture = UITapGestureRecognizer (target: self, action: #selector(handleSingleTap))
        currentCommandsView.addGestureRecognizer(singleTapGesture)
    }

    @objc private func handleSingleTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        guard let indexPath = currentCommandsView.indexPathForItem(at: location) else {
            return
        }

        guard let cell = currentCommandsView.cellForItem(at: indexPath) as? CommandCell else {
            return
        }

        if isIndexedCommand(indexPath: indexPath) {
            print("WAHLAHLAH")
        }
    }

    @objc private func handleDoubleTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        guard let indexPath = currentCommandsView.indexPathForItem(at: location) else {
                return
        }

        guard let cell = currentCommandsView.cellForItem(at: indexPath) as? CommandCell else {
            return
        }

        guard cell.commandImage.frame.contains(location) else {
            return
        }

        removeAllJumpArrows()

        var partnerIndexPath: IndexPath?
        if isJumpCommand(indexPath: indexPath) {
            partnerIndexPath = getJumpViewsBundle(indexPath: indexPath)?.jumpTargetIndexPath
        } else if isJumpTargetCommand(indexPath: indexPath) {
            partnerIndexPath = getJumpViewsBundle(indexPath: indexPath)?.jumpIndexPath
        }

        if let partnerIndexPath = partnerIndexPath {
            updateJumpBundles(deletedIndexPath: indexPath,
                              deletedPartnerIndexPath: partnerIndexPath)
            deleteJumpBundle(deletedIndexPath: indexPath)
        } else {
            updateJumpBundles(deletedIndexPath: indexPath)
        }
        renderJumpArrows()

        _ = model.removeCommand(fromIndex: indexPath.item)
        currentCommandsView.reloadData()
    }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        switch gesture.state {
        case .began:
            guard let indexPath = currentCommandsView.indexPathForItem(at: location),
                  let cell = currentCommandsView.cellForItem(at: indexPath) as? CommandCell else {
                return
            }
            
            initDragBundleAtGestureBegan(indexPath: indexPath, cell: cell)
            currentCommandsView.addSubview(DragBundle.cellSnapshot!)
            AnimationHelper.dragBeganAnimation(location: location, cell: cell)

        case .changed:
            DragBundle.cellSnapshot?.center.y = location.y
            guard let indexPath = currentCommandsView.indexPathForItem(at: location),
                      indexPath != DragBundle.initialIndexPath! else {
                        return
            }
            currentCommandsView.moveItem(at: DragBundle.initialIndexPath!, to: indexPath)

            if isOneOfJumpCommands(indexPath: DragBundle.initialIndexPath!)
                && isOneOfJumpCommands(indexPath: indexPath) {
                performBothJumpCommandsUpdate(indexPathOne: DragBundle.initialIndexPath!,
                                              indexPathTwo: indexPath)
                renderJumpArrows()
            } else if isOneOfJumpCommands(indexPath: DragBundle.initialIndexPath!) {
                performOneJumpCommandsUpdate(oldIndexPath: DragBundle.initialIndexPath!,
                                             newIndexPath: indexPath)
                renderJumpArrows()
            } else if isOneOfJumpCommands(indexPath: indexPath) {
                performOneJumpCommandsUpdate(oldIndexPath: indexPath,
                                             newIndexPath: DragBundle.initialIndexPath!)
                renderJumpArrows()
            }

            model.moveCommand(fromIndex: DragBundle.initialIndexPath!.item, toIndex: indexPath.item)
            DragBundle.initialIndexPath = indexPath

        default:
            guard let cell = currentCommandsView.cellForItem(at: DragBundle.initialIndexPath!) else {
                break
            }
            cell.isHidden = false
            cell.alpha = 0.0
            AnimationHelper.dragEndAnimation(cell: cell)
        }
    }

    /* Button actions func */
    @objc private func commandButtonPressed(sender: UIButton) {
        let command = model.currentLevel.availableCommands[sender.tag]
        model.addCommand(commandEnum: command)

        let penultimateIndexPath = IndexPath(item: model.userEnteredCommands.count - 2, section: 0)
        let lastIndexPath = IndexPath(item: model.userEnteredCommands.count - 1, section: 0)

        if command == CommandData.jump {
            currentCommandsView.insertItems(at: [penultimateIndexPath, lastIndexPath])
            let arrowView = drawJumpArrow(topIndexPath: penultimateIndexPath,
                                      bottomIndexPath: lastIndexPath)
            currentCommandsView.addSubview(arrowView)

            let jumpBundle = JumpBundle(jumpIndexPath: lastIndexPath,
                                        jumpTargetIndexPath: penultimateIndexPath,
                                        arrowView: arrowView)
            jumpBundles.append(jumpBundle)
        } else {
            currentCommandsView.insertItems(at: [lastIndexPath])
        }
        currentCommandsView.scrollToItem(at: lastIndexPath,
                                         at: UICollectionViewScrollPosition.top,
                                         animated: true)
    }

    /* Drawing Helper func */
    private func getArrowOriginAt(indexPath: IndexPath) -> CGPoint {
        return CGPoint(Constants.UI.collectionCellWidth * 0.5,
                       getMidYOfCellAt(indexPath: indexPath))
    }

    private func getMidYOfCellAt(indexPath: IndexPath) -> CGFloat {
        return Constants.UI.topEdgeInset
            + (CGFloat(indexPath.item + 1) * Constants.UI.collectionCellHeight)
            - (0.5 * Constants.UI.collectionCellHeight)
    }

    private func getHeightBetweenIndexPaths(indexPathOne: IndexPath, indexPathTwo: IndexPath) -> CGFloat {
        if indexPathOne.item < indexPathTwo.item {
            return getHeightBetweenIndexPaths(indexPathOne: indexPathTwo, indexPathTwo: indexPathOne)
        } else {
            return getMidYOfCellAt(indexPath: indexPathOne) - getMidYOfCellAt(indexPath: indexPathTwo)
        }

    }

    /* Jump Helper func */
    private func updateJumpBundles(deletedIndexPath: IndexPath) {
        for jumpBundle in jumpBundles {
            if jumpBundle.jumpIndexPath != deletedIndexPath
            && jumpBundle.jumpTargetIndexPath != deletedIndexPath {
                if jumpBundle.jumpTargetIndexPath.item >= deletedIndexPath.item {
                    jumpBundle.jumpTargetIndexPath.item -= 1
                }

                if jumpBundle.jumpIndexPath.item >= deletedIndexPath.item {
                    jumpBundle.jumpIndexPath.item -= 1
                }
            }
        }
    }

    private func updateJumpBundles(deletedIndexPath: IndexPath, deletedPartnerIndexPath: IndexPath) {
        for jumpBundle in jumpBundles {
            if jumpBundle.jumpIndexPath != deletedIndexPath
                && jumpBundle.jumpTargetIndexPath != deletedIndexPath {
                if jumpBundle.jumpTargetIndexPath.item >= deletedIndexPath.item {
                    jumpBundle.jumpTargetIndexPath.item -= 1
                }

                if jumpBundle.jumpTargetIndexPath.item >= deletedPartnerIndexPath.item {
                    jumpBundle.jumpTargetIndexPath.item -= 1
                }

                if jumpBundle.jumpIndexPath.item >= deletedIndexPath.item {
                    jumpBundle.jumpIndexPath.item -= 1
                }

                if jumpBundle.jumpIndexPath.item >= deletedPartnerIndexPath.item {
                    jumpBundle.jumpIndexPath.item -= 1
                }
            }
        }
    }

    private func deleteJumpBundle(deletedIndexPath: IndexPath) {
        var index = 0
        for jumpBundle in jumpBundles {
            if jumpBundle.jumpIndexPath == deletedIndexPath
                || jumpBundle.jumpTargetIndexPath == deletedIndexPath {
                break
            }
            index += 1
        }
        print(index)
        jumpBundles.remove(at: index)
    }

    private func performBothJumpCommandsUpdate(indexPathOne: IndexPath, indexPathTwo: IndexPath) {
        guard let jumpBundleOne = getJumpViewsBundle(indexPath: indexPathOne),
              let jumpBundleTwo = getJumpViewsBundle(indexPath: indexPathTwo) else {
                return
        }

        if indexPathOne == jumpBundleOne.jumpIndexPath {
            if indexPathTwo == jumpBundleTwo.jumpIndexPath {
                swap(&jumpBundleOne.jumpIndexPath, &jumpBundleTwo.jumpIndexPath)
            } else {
                swap(&jumpBundleOne.jumpIndexPath, &jumpBundleTwo.jumpTargetIndexPath)
            }
        } else {
            if indexPathTwo == jumpBundleTwo.jumpIndexPath {
                swap(&jumpBundleOne.jumpTargetIndexPath, &jumpBundleTwo.jumpIndexPath)
            } else {
                swap(&jumpBundleOne.jumpTargetIndexPath, &jumpBundleTwo.jumpTargetIndexPath)
            }
        }
    }

    private func performOneJumpCommandsUpdate(oldIndexPath: IndexPath, newIndexPath: IndexPath) {
        guard let jumpBundle = getJumpViewsBundle(indexPath: oldIndexPath) else {
                return
        }
        if oldIndexPath == jumpBundle.jumpIndexPath {
            jumpBundle.jumpIndexPath = newIndexPath
        } else {
            jumpBundle.jumpTargetIndexPath = newIndexPath
        }
    }

    private func getJumpViewsBundle(indexPath: IndexPath) -> JumpBundle? {
        for jumpBundle in jumpBundles {
            if jumpBundle.jumpIndexPath == indexPath
                || jumpBundle.jumpTargetIndexPath == indexPath {
                return jumpBundle
            }
        }
        return nil
    }

    private func removeAllJumpArrows() {
        for jumpBundle in jumpBundles {
            jumpBundle.arrowView.removeFromSuperview()
        }
    }

    private func redrawAllJumpArrows() -> [UIImageView] {
        var jumpArrows = [UIImageView]()
        for jumpBundle in jumpBundles {
            if jumpBundle.jumpIndexPath.item < jumpBundle.jumpTargetIndexPath.item {
                jumpBundle.arrowView = drawJumpArrow(topIndexPath: jumpBundle.jumpIndexPath,
                                                     bottomIndexPath: jumpBundle.jumpTargetIndexPath)
                jumpArrows.append(jumpBundle.arrowView)
            } else {
                jumpBundle.arrowView = drawJumpArrow(topIndexPath: jumpBundle.jumpTargetIndexPath,
                                                     bottomIndexPath: jumpBundle.jumpIndexPath)
                jumpArrows.append(jumpBundle.arrowView)
            }
        }
        return jumpArrows
    }

    private func drawJumpArrow(topIndexPath: IndexPath, bottomIndexPath: IndexPath) -> UIImageView {
        let origin = getArrowOriginAt(indexPath: topIndexPath)
        let height = getHeightBetweenIndexPaths(indexPathOne: topIndexPath,
                                                indexPathTwo: bottomIndexPath)
        return UIEntityHelper.generateArrowView(origin: origin,
                                                height: height)
    }

    private func renderJumpArrows() {
        removeAllJumpArrows()
        for jumpArrow in redrawAllJumpArrows() {
            currentCommandsView.addSubview(jumpArrow)
        }
    }

    private func isOneOfJumpCommands(indexPath: IndexPath) -> Bool {
        return model.userEnteredCommands[indexPath.item] == .jump
            || model.userEnteredCommands[indexPath.item] == .jumpTarget
    }

    private func isJumpCommand(indexPath: IndexPath) -> Bool {
        return model.userEnteredCommands[indexPath.item] == .jump
    }

    private func isJumpTargetCommand(indexPath: IndexPath) -> Bool {
        return model.userEnteredCommands[indexPath.item] == .jumpTarget
    }

    /* Gesture Helper func */
    private func initDragBundleAtGestureBegan(indexPath: IndexPath, cell: UICollectionViewCell) {
        DragBundle.initialIndexPath = indexPath
        DragBundle.cellSnapshot = UIEntityHelper.snapshotOfCell(inputView: cell)
        DragBundle.cellSnapshot?.center = cell.center
        DragBundle.cellSnapshot?.alpha = 0.0
    }

    /* Other Helper func */
    private func isIndexedCommand(indexPath: IndexPath) -> Bool {
        switch model.userEnteredCommands[indexPath.item] {
        case .add(_), .copyFrom(_), .copyTo(_):
            return true
        default:
            return false
        }
    }
}

struct DragBundle {
    static var cellSnapshot: UIView?
    static var initialIndexPath: IndexPath?
}

class JumpBundle {
    var jumpIndexPath: IndexPath
    var jumpTargetIndexPath: IndexPath
    var arrowView: UIImageView
    var inverted = false

    init(jumpIndexPath: IndexPath, jumpTargetIndexPath: IndexPath, arrowView: UIImageView) {
        self.jumpIndexPath = jumpIndexPath
        self.jumpTargetIndexPath = jumpTargetIndexPath
        self.arrowView = arrowView
    }
}

extension EditorViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Constants.UI.numberOfSectionsInCollection
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.userEnteredCommands.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.UI.collectionViewCellIdentifier,
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

        return CGSize(width: Constants.UI.collectionCellWidth,
                      height: Constants.UI.collectionCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        let edgeInset = UIEdgeInsets(top: Constants.UI.topEdgeInset,
                                     left: 0, bottom: 0,
                                     right: Constants.UI.rightEdgeInset)
        return edgeInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.UI.minimumLineSpacingForSection
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.UI.minimumInteritemSpacingForSection
    }
}
