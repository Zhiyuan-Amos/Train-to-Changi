//
//  DragDropViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 2/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class DragDropViewController: UIViewController {

    var model: Model!
    fileprivate var jumpBundles = [JumpBundle]()
    fileprivate var updatingCellIndexPath: IndexPath?

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var currentCommandsView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectDataSourceAndDelegate()
        addGestureRecognisers()
        registerObservers()
    }

    @IBAction func resetButtonPressed(_ sender: Any) {
        model.clearAllCommands()
        removeAllJumpArrows()
        jumpBundles.removeAll()
        currentCommandsView.reloadData()

        NotificationCenter.default.post(name: Constants.NotificationNames.userResetCommandEvent,
                                        object: nil,
                                        userInfo: nil)
    }

    // MARK -- Setup
    private func connectDataSourceAndDelegate() {
        currentCommandsView.dataSource = self
        currentCommandsView.delegate = self
    }

    fileprivate func deleteCommand(indexPath: IndexPath) {
        // clear all jump arrow views before potentially deleting jumpBundle
        removeAllJumpArrows()

        // if command is related to jump, need to delete bundle
        if let jumpPartnerIndexPath = getJumpPartnerIndexPath(indexPath: indexPath) {
            updateJumpBundles(deletedIndexPath: indexPath,
                              deletedPartnerIndexPath: jumpPartnerIndexPath)
            deleteJumpBundle(deletedIndexPath: indexPath)
        } else {
            updateJumpBundles(deletedIndexPath: indexPath)
        }
        renderJumpArrows()

        _ = model.removeCommand(fromIndex: indexPath.item)
        currentCommandsView.reloadData()

        NotificationCenter.default.post(name: Constants.NotificationNames.userDeleteCommandEvent,
                                        object: nil,
                                        userInfo: nil)
    }
}

// MARK: - Gestures
extension DragDropViewController {

    fileprivate func addGestureRecognisers() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.3
        currentCommandsView.addGestureRecognizer(longPressGesture)

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .right
        currentCommandsView.addGestureRecognizer(swipeGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        currentCommandsView.addGestureRecognizer(tapGesture)

    }

    @objc private func handleTap(gesture: UISwipeGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        guard let indexPath = currentCommandsView.indexPathForItem(at: location),
              let cell = currentCommandsView.cellForItem(at: indexPath),
              isIndexedCommand(indexPath: indexPath) else {
                return
        }

        let indexCommand = model.userEnteredCommands[indexPath.item]

        if updatingCellIndexPath == nil {
            updatingCellIndexPath = indexPath
            switch indexCommand {
            case .add(let index), .copyTo(let index), .copyFrom(let index):
                updateCellIndex(cell: cell, index: index!)
            default:
                break
            }
        } else if updatingCellIndexPath == indexPath {
            updatingCellIndexPath = nil
            switch indexCommand {
            case .add(let index), .copyTo(let index), .copyFrom(let index):
                cancelUpdateCellIndex(cell: cell, index: index!)
            default:
                break
            }

        }
    }

    private func updateCellIndex(cell: UICollectionViewCell, index: Int) {
        cell.layer.backgroundColor = UIColor.red.cgColor
        NotificationCenter.default.post(name: Constants.NotificationNames.updateCommandIndexEvent,
                                        object: index,
                                        userInfo: nil)
    }

    private func cancelUpdateCellIndex(cell: UICollectionViewCell, index: Int) {
        cell.layer.backgroundColor = nil
        NotificationCenter.default.post(name: Constants.NotificationNames.cancelUpdateCommandIndexEvent,
                                        object: index,
                                        userInfo: nil)
    }

    @objc private func handleSwipe(gesture: UISwipeGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        guard let indexPath = currentCommandsView.indexPathForItem(at: location),
              let cell = currentCommandsView.cellForItem(at: indexPath),
              updatingCellIndexPath == nil else {
                return
        }

        AnimationHelper.swipeDeleteAnimation(cell: cell, indexPath: indexPath,
                                             deleteFunction: deleteCommand)

    }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        guard updatingCellIndexPath == nil else {
            return
        }

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

            if isJumpRelatedCommand(indexPath: DragBundle.initialIndexPath!)
                && isJumpRelatedCommand(indexPath: indexPath) {
                performBothJumpCommandsUpdate(indexPathOne: DragBundle.initialIndexPath!,
                                              indexPathTwo: indexPath)
                renderJumpArrows()
            } else if isJumpRelatedCommand(indexPath: DragBundle.initialIndexPath!) {
                performOneJumpCommandUpdate(oldIndexPath: DragBundle.initialIndexPath!,
                                            newIndexPath: indexPath)
                renderJumpArrows()
            } else if isJumpRelatedCommand(indexPath: indexPath) {
                performOneJumpCommandUpdate(oldIndexPath: indexPath,
                                            newIndexPath: DragBundle.initialIndexPath!)
                renderJumpArrows()
            }

            model.moveCommand(fromIndex: DragBundle.initialIndexPath!.item, toIndex: indexPath.item)
            DragBundle.initialIndexPath = indexPath

        default:
            guard let indexPath = DragBundle.initialIndexPath,
                let cell = currentCommandsView.cellForItem(at: indexPath) else {
                    break
            }
            cell.isHidden = false
            cell.alpha = 0.0
            AnimationHelper.dragEndedAnimation(cell: cell)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = currentCommandsView.contentOffset
        NotificationCenter.default.post(name: Constants.NotificationNames.userScrollEvent,
                                        object: offset,
                                        userInfo: nil)
    }

    private func initDragBundleAtGestureBegan(indexPath: IndexPath, cell: UICollectionViewCell) {
        DragBundle.initialIndexPath = indexPath
        DragBundle.cellSnapshot = UIEntityDrawer.snapshotOfCell(inputView: cell)
        DragBundle.cellSnapshot?.center = cell.center
        DragBundle.cellSnapshot?.alpha = 0.0
    }
}

// MARK: - Delete Helper Functions
extension DragDropViewController {
    // update jump bundles when a non-jump related command is being deleted
    fileprivate func updateJumpBundles(deletedIndexPath: IndexPath) {
        for jumpBundle in jumpBundles {
            guard jumpBundle.jumpIndexPath != deletedIndexPath
                && jumpBundle.jumpTargetIndexPath != deletedIndexPath else {
                    continue
            }
            if jumpBundle.jumpTargetIndexPath.item >= deletedIndexPath.item {
                jumpBundle.jumpTargetIndexPath.item -= 1
            }

            if jumpBundle.jumpIndexPath.item >= deletedIndexPath.item {
                jumpBundle.jumpIndexPath.item -= 1
            }
        }
    }

    // update jump bundles when a jump related command is being deleted
    fileprivate func updateJumpBundles(deletedIndexPath: IndexPath, deletedPartnerIndexPath: IndexPath) {
        for jumpBundle in jumpBundles {
            guard jumpBundle.jumpIndexPath != deletedIndexPath
                && jumpBundle.jumpTargetIndexPath != deletedIndexPath else {
                    continue
            }

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

    fileprivate func deleteJumpBundle(deletedIndexPath: IndexPath) {
        var index = 0
        for jumpBundle in jumpBundles {
            if jumpBundle.jumpIndexPath == deletedIndexPath
                || jumpBundle.jumpTargetIndexPath == deletedIndexPath {
                break
            }
            index += 1
        }
        jumpBundles.remove(at: index)
    }

    fileprivate func performBothJumpCommandsUpdate(indexPathOne: IndexPath, indexPathTwo: IndexPath) {
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

    fileprivate func performOneJumpCommandUpdate(oldIndexPath: IndexPath, newIndexPath: IndexPath) {
        guard let jumpBundle = getJumpViewsBundle(indexPath: oldIndexPath) else {
            return
        }
        if oldIndexPath == jumpBundle.jumpIndexPath {
            jumpBundle.jumpIndexPath = newIndexPath
        } else {
            jumpBundle.jumpTargetIndexPath = newIndexPath
        }
    }

    fileprivate func getJumpViewsBundle(indexPath: IndexPath) -> JumpBundle? {
        for jumpBundle in jumpBundles {
            if jumpBundle.jumpIndexPath == indexPath
                || jumpBundle.jumpTargetIndexPath == indexPath {
                return jumpBundle
            }
        }
        return nil
    }

    fileprivate func getJumpPartnerIndexPath(indexPath: IndexPath) -> IndexPath? {
        if isJump(indexPath: indexPath) {
            return getJumpViewsBundle(indexPath: indexPath)?.jumpTargetIndexPath
        } else if isJumpTarget(indexPath: indexPath) {
            return getJumpViewsBundle(indexPath: indexPath)?.jumpIndexPath
        } else {
            return nil
        }
    }

    fileprivate func removeAllJumpArrows() {
        for jumpBundle in jumpBundles {
            jumpBundle.arrowView.removeFromSuperview()
        }
    }

    fileprivate func redrawAllJumpArrows() -> [UIView] {
        var jumpArrows = [UIView]()
        for jumpBundle in jumpBundles {
            if jumpBundle.jumpIndexPath.item < jumpBundle.jumpTargetIndexPath.item {
                jumpBundle.arrowView = UIEntityDrawer.drawJumpArrow(topIndexPath: jumpBundle.jumpIndexPath,
                                                                    bottomIndexPath: jumpBundle.jumpTargetIndexPath)
                jumpArrows.append(jumpBundle.arrowView)
            } else {
                jumpBundle.arrowView = UIEntityDrawer.drawJumpArrow(topIndexPath: jumpBundle.jumpTargetIndexPath,
                                                                    bottomIndexPath: jumpBundle.jumpIndexPath)
                jumpArrows.append(jumpBundle.arrowView)
            }
        }
        return jumpArrows
    }

    fileprivate func renderJumpArrows() {
        removeAllJumpArrows()
        for jumpArrow in redrawAllJumpArrows() {
            currentCommandsView.addSubview(jumpArrow)
        }
    }

    fileprivate func isJumpRelatedCommand(indexPath: IndexPath) -> Bool {
        return model.userEnteredCommands[indexPath.item] == .jump
            || model.userEnteredCommands[indexPath.item] == .jumpTarget
    }

    fileprivate func isJump(indexPath: IndexPath) -> Bool {
        return model.userEnteredCommands[indexPath.item] == .jump
    }

    fileprivate func isJumpTarget(indexPath: IndexPath) -> Bool {
        return model.userEnteredCommands[indexPath.item] == .jumpTarget
    }


    fileprivate func isIndexedCommand(indexPath: IndexPath) -> Bool {
        switch model.userEnteredCommands[indexPath.item] {
        case .add(_), .copyFrom(_), .copyTo(_):
            return true
        default:
            return false
        }
    }
}

// MARK -- Event Handling
extension DragDropViewController {

    fileprivate func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRunStateUpdate(notification:)),
            name: Constants.NotificationNames.runStateUpdated,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAddCommand(notification:)),
            name: Constants.NotificationNames.userAddCommandEvent,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleSelectedIndex(notification:)),
            name: Constants.NotificationNames.userSelectedIndexEvent,
            object: nil)
    }

    @objc fileprivate func handleSelectedIndex(notification: Notification) {
        guard let index = notification.object as? Int,
              let indexPath = updatingCellIndexPath,
              let cell = currentCommandsView.cellForItem(at: indexPath) else {
            fatalError("Notification Data is not of type Int")
        }

        let command = model.userEnteredCommands[indexPath.item]
        _ = model.removeCommand(fromIndex: indexPath.item)

        switch command {
        case .copyFrom(_):
            model.insertCommand(commandEnum: CommandData.copyFrom(memoryIndex: index),
                                atIndex: indexPath.item)
        case .copyTo(_):
            model.insertCommand(commandEnum: CommandData.copyTo(memoryIndex: index),
                                atIndex: indexPath.item)
        case .add(_):
            model.insertCommand(commandEnum: CommandData.add(memoryIndex: index),
                                atIndex: indexPath.item)
        default:
            break
        }
        currentCommandsView.reloadData()
        updatingCellIndexPath = nil
        cell.layer.backgroundColor = nil
    }

    // Updates whether the views are enabled depending on the `model.runState`.
    @objc fileprivate func handleRunStateUpdate(notification: Notification) {
        switch model.runState {
        case .running, .won, .stepping:
            resetButton.isEnabled = false
            currentCommandsView.isUserInteractionEnabled = false
        case .paused, .lost:
            resetButton.isEnabled = true
            currentCommandsView.isUserInteractionEnabled = true
        }
    }

    @objc fileprivate func handleAddCommand(notification: Notification) {
        guard let command = notification.object as? CommandData else {
            fatalError("Notification Data is not of type CommandData")
        }

        let penultimateIndexPath = IndexPath(item: model.userEnteredCommands.count - 2, section: 0)
        let lastIndexPath = IndexPath(item: model.userEnteredCommands.count - 1, section: 0)

        if command == CommandData.jump {
            currentCommandsView.insertItems(at: [penultimateIndexPath, lastIndexPath])
            let arrowView = UIEntityDrawer.drawJumpArrow(topIndexPath: penultimateIndexPath,
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
}

class DragBundle {
    static var cellSnapshot: UIView?
    static var initialIndexPath: IndexPath?
}

class JumpBundle {
    var jumpIndexPath: IndexPath
    var jumpTargetIndexPath: IndexPath
    var arrowView: UIView
    var inverted = false

    init(jumpIndexPath: IndexPath, jumpTargetIndexPath: IndexPath, arrowView: UIView) {
        self.jumpIndexPath = jumpIndexPath
        self.jumpTargetIndexPath = jumpTargetIndexPath
        self.arrowView = arrowView
    }
}
