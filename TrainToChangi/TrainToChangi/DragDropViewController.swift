//
//  DragDropViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 2/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class DragDropViewController: UIViewController {

    fileprivate typealias Drawer = UIEntityDrawer
    fileprivate typealias Animator = AnimationHelper

    var model: Model!
    fileprivate var jumpArrows = [ArrowView]()
    fileprivate var updatingCellIndexPath: IndexPath?

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var currentCommandsView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCommandDataList()
        connectDataSourceAndDelegate()
        addGestureRecognisers()
        registerObservers()
        renderJumpArrows()
    }

    @IBAction func resetButtonPressed(_ sender: Any) {
        model.clearAllCommands()
        removeAllJumpArrows()
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

    private func loadCommandDataList() {
        guard let userID = AuthService.instance.currentUserID else {
            fatalError("Must be logged in")
        }
        let ref = DataService.instance.usersRef.child(userID).child("commandDataListInfo").child("default")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let commandDataListInfo = CommandDataListInfo.fromSnapshot(snapshot: snapshot) {
                self.model.loadCommandDataListInfo(commandDataListInfo: commandDataListInfo)
            }
            self.currentCommandsView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    fileprivate func deleteCommand(indexPath: IndexPath) {
        _ = model.removeCommand(fromIndex: indexPath.item)
        currentCommandsView.reloadData()
        renderJumpArrows()
        NotificationCenter.default.post(name: Constants.NotificationNames.userDeleteCommandEvent,
                                        object: nil,
                                        userInfo: nil)
    }
}

// MARK: - Gestures
extension DragDropViewController {

    fileprivate func addGestureRecognisers() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.2
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

        Animator.swipeDeleteAnimation(cell: cell, indexPath: indexPath,
                                             deleteFunction: deleteCommand)

    }

    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        if updatingCellIndexPath != nil {
            return
        }

        switch gesture.state {
        case .began:
            guard let indexPath = currentCommandsView.indexPathForItem(at: location),
                  let cell = currentCommandsView.cellForItem(at: indexPath) as? CommandCell,
                  location.x < cell.frame.midX else {
                    return
            }

            initDragBundleAtGestureBegan(indexPath: indexPath, cell: cell)
            currentCommandsView.addSubview(DragBundle.cellSnapshot!)
            Animator.dragBeganAnimation(location: location, cell: cell)

        case .changed:
            DragBundle.cellSnapshot?.center.y = location.y
            guard let indexPath = currentCommandsView.indexPathForItem(at: location),
                  let initialIndexPath = DragBundle.initialIndexPath,
                  indexPath !=  initialIndexPath else {
                    return
            }
            currentCommandsView.moveItem(at: initialIndexPath, to: indexPath)
            model.moveCommand(fromIndex: initialIndexPath.item, toIndex: indexPath.item)

            renderJumpArrows()
            DragBundle.initialIndexPath = indexPath

        default:
            guard let indexPath = DragBundle.initialIndexPath,
                  let cell = currentCommandsView.cellForItem(at: indexPath) else {
                    break
            }
            cell.isHidden = false
            cell.alpha = 0.0
            Animator.dragEndedAnimation(cell: cell)
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
        DragBundle.cellSnapshot = Drawer.snapshotOfCell(inputView: cell)
        DragBundle.cellSnapshot?.center = cell.center
        DragBundle.cellSnapshot?.alpha = 0.0
    }
}

// MARK: - Jump Arrow Drawing Helper Functions
extension DragDropViewController {

    fileprivate func removeAllJumpArrows() {
        for jumpArrow in jumpArrows {
            jumpArrow.removeFromSuperview()
        }
        jumpArrows.removeAll()
    }

    fileprivate func redrawAllJumpArrows() -> [ArrowView] {
        var jumpArrows = [ArrowView]()
        for (index, jumpMapping) in model.getCommandDataListInfo().jumpMappings.enumerated() {
            let parentIndexPath = IndexPath(item: jumpMapping.key, section: 0)
            let targetIndexPath = IndexPath(item: jumpMapping.value, section: 0)

            if jumpMapping.key < jumpMapping.value {
                let arrowView = Drawer.drawJumpArrow(topIndexPath: parentIndexPath,
                                                     bottomIndexPath: targetIndexPath,
                                                     reversed: true, arrowWidthIndex: index)
                jumpArrows.append(arrowView)
            } else {
                let arrowView = Drawer.drawJumpArrow(topIndexPath: targetIndexPath,
                                                     bottomIndexPath: parentIndexPath,
                                                     reversed: false, arrowWidthIndex: index)
                jumpArrows.append(arrowView)
            }
        }
        return jumpArrows
    }

    fileprivate func renderJumpArrows() {
        removeAllJumpArrows()
        jumpArrows = redrawAllJumpArrows()
        for jumpArrow in jumpArrows {
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
            renderJumpArrows()
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
