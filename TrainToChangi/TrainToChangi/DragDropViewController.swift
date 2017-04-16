//
//  DragDropViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 2/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

// Bundle class that encapsulates drag and drop information.
class DragBundle {
    var cellSnapshot: UIView?
    var initialIndexPath: IndexPath?
}

/**
 * View Controller responsible for the drag and drop commands editor
 */
class DragDropViewController: UIViewController {

    fileprivate typealias Drawer = UIEntityDrawer
    fileprivate typealias Animator = AnimationHelper

    weak var model: Model!
    weak var lineNumberUpdateDelegate: LineNumberUpdateDelegate!
    weak var resetGameDelegate: ResetGameDelegate!

    fileprivate var jumpArrows = [ArrowView]()
    fileprivate var updatingCellIndexPath: IndexPath?
    fileprivate var dragBundle = DragBundle()

    @IBOutlet weak var currentCommandsView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCommandDataList()
        connectDataSourceAndDelegate()
        addGestureRecognisers()
        registerObservers()
        currentCommandsView.backgroundColor = Constants.UI.Colors.currentCommandsBackgroundColor
    }

    private func connectDataSourceAndDelegate() {
        currentCommandsView.dataSource = self
        currentCommandsView.delegate = self
    }

    // Loads the user's saved data for this level
    private func loadCommandDataList() {
        guard let userId = AuthService.instance.currentUserId else {
            fatalError(Constants.Errors.userNotLoggedIn)
        }
        DataService.instance.loadAutoSavedUserProgram(userId: userId,
                                                      levelIndex: model.currentLevelIndex,
                                                      loadProgramDelegate: self)
    }

    fileprivate func deleteCommand(indexPath: IndexPath) {
        _ = model.removeCommand(fromIndex: indexPath.item)
        currentCommandsView.reloadData()
        renderJumpArrows()
        lineNumberUpdateDelegate.updateLineNumbers()
    }
}

// MARK: - DataServiceLoadProgramDelegate
extension DragDropViewController: DataServiceLoadProgramDelegate {
    func load(commandDataListInfo: CommandDataListInfo) {
        model.loadCommandDataListInfo(commandDataListInfo: commandDataListInfo)
        currentCommandsView.reloadData()
        renderJumpArrows()
        lineNumberUpdateDelegate.updateLineNumbers()
    }
}

// MARK: - SaveProgramDelegate
extension DragDropViewController: SaveProgramDelegate {
    func saveProgram(saveName: String) {
        guard let userId = AuthService.instance.currentUserId else {
            fatalError(Constants.Errors.userNotLoggedIn)
        }
        DataService.instance.saveUserProgram(userId: userId,
                                             levelIndex: model.currentLevelIndex,
                                             saveName: saveName,
                                             commandDataListInfo: model.getCommandDataListInfo())
    }
}

// MARK: - CommandsEditorUpdateDelegate
extension DragDropViewController: CommandsEditorUpdateDelegate {

    func addNewCommand(command: CommandData) {
        let penultimateIndexPath = IndexPath(item: model.userEnteredCommands.count - 2, section: 0)
        let lastIndexPath = IndexPath(item: model.userEnteredCommands.count - 1, section: 0)

        if command.isJumpCommand {
            currentCommandsView.insertItems(at: [penultimateIndexPath, lastIndexPath])
            renderJumpArrows()
        } else {
            currentCommandsView.insertItems(at: [lastIndexPath])
        }
        currentCommandsView.scrollToItem(at: lastIndexPath,
                                         at: UICollectionViewScrollPosition.top,
                                         animated: true)
        lineNumberUpdateDelegate.updateLineNumbers()
    }

    func resetCommands() {
        model.clearAllCommands()
        removeAllJumpArrows()
        currentCommandsView.reloadData()
        lineNumberUpdateDelegate.updateLineNumbers()
    }
}

// MARK: - Gestures
extension DragDropViewController {

    fileprivate func addGestureRecognisers() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = Constants.UI.Delay.longPressDuration
        currentCommandsView.addGestureRecognizer(longPressGesture)

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .right
        currentCommandsView.addGestureRecognizer(swipeGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        currentCommandsView.addGestureRecognizer(tapGesture)

    }

    // Handle tap gestures on the drag and drop commands editor 
    // for user to change memory indices. It checks if a change 
    // process is ongoing and if so, cancels that process else it
    // will begin that process and store the indexPath of the command
    // being updated
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
            case .add(let index), .sub(let index), .copyTo(let index), .copyFrom(let index):
                updateCellIndex(cell: cell, index: index)
            default:
                break
            }
        } else if updatingCellIndexPath == indexPath {
            updatingCellIndexPath = nil
            switch indexCommand {
            case .add(let index), .sub(let index), .copyTo(let index), .copyFrom(let index):
                cancelUpdateCellIndex(cell: cell, index: index)
            default:
                break
            }

        }
        resetGameDelegate.tryResetGame()
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

    // Handles swipe gestures for deleting commands
    @objc private func handleSwipe(gesture: UISwipeGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        guard let indexPath = currentCommandsView.indexPathForItem(at: location),
              let cell = currentCommandsView.cellForItem(at: indexPath),
              updatingCellIndexPath == nil else {
                return
        }

        Animator.swipeDeleteAnimation(cell: cell, indexPath: indexPath,
                                             deleteFunction: deleteCommand)
        resetGameDelegate.tryResetGame()
    }

    // Handles long press gestures for drag and drop
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        // prevent long press and tap gestures to be activated at the same time
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
            currentCommandsView.addSubview(dragBundle.cellSnapshot!) 
            Animator.dragBeganAnimation(location: location, cell: cell, dragBundle: dragBundle)

        case .changed:
            dragBundle.cellSnapshot?.center.y = location.y
            // Only activate if the cell is dragged to new IndexPath
            guard let indexPath = currentCommandsView.indexPathForItem(at: location),
                  let initialIndexPath = dragBundle.initialIndexPath,
                  indexPath != initialIndexPath else {
                    return
            }

            // Update the collection view and model
            currentCommandsView.moveItem(at: initialIndexPath, to: indexPath)
            model.moveCommand(fromIndex: initialIndexPath.item, toIndex: indexPath.item)

            renderJumpArrows()
            dragBundle.initialIndexPath = indexPath //update the initialIndexPath to the new indexPath

        default:
            // Prevents dragging to an indexPath that is not visible
            guard let indexPath = dragBundle.initialIndexPath,
                  let cell = currentCommandsView.cellForItem(at: indexPath) else {
                    return
            }
            cell.isHidden = false
            cell.alpha = 0.0
            Animator.dragEndedAnimation(cell: cell, dragBundle: dragBundle)
        }
        resetGameDelegate.tryResetGame()
    }

    // Sync the scrolling between line numbers collection view 
    // and the current commands collection view
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = currentCommandsView.contentOffset
        lineNumberUpdateDelegate.scrollToOffset(offset: offset)
    }

    private func initDragBundleAtGestureBegan(indexPath: IndexPath, cell: UICollectionViewCell) {
        dragBundle.initialIndexPath = indexPath
        dragBundle.cellSnapshot = Drawer.snapshotOfCell(inputView: cell)
        dragBundle.cellSnapshot?.center = cell.center
        dragBundle.cellSnapshot?.alpha = 0.0
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

    fileprivate func isIndexedCommand(indexPath: IndexPath) -> Bool {
        switch model.userEnteredCommands[indexPath.item] {
        case .add(_), .sub(_), .copyFrom(_), .copyTo(_):
            return true
        default:
            return false
        }
    }
}

// MARK: - Event Handling
extension DragDropViewController {

    fileprivate func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRunStateUpdate(notification:)),
            name: Constants.NotificationNames.runStateUpdated,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleSelectedIndex(notification:)),
            name: Constants.NotificationNames.userSelectedIndexEvent,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleProgramCounterUpdate(notification:)),
            name: Constants.NotificationNames.moveProgramCounter,
            object: nil)
    }

    // Handles the scrolling during program execution
    @objc fileprivate func handleProgramCounterUpdate(notification: Notification) {
        if let index = notification.userInfo?["index"] as? Int {
            currentCommandsView.scrollToItem(at: IndexPath(item: index, section: 0),
                                             at: UICollectionViewScrollPosition.bottom,
                                             animated: true)
        }
    }

    // Update the user's new choice of index
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
        case .sub(_):
            model.insertCommand(commandEnum: CommandData.sub(memoryIndex: index),
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
            currentCommandsView.isUserInteractionEnabled = false
        case .paused, .lost, .start:
            currentCommandsView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                             at: UICollectionViewScrollPosition.bottom,
                                             animated: true)
            currentCommandsView.isUserInteractionEnabled = true
        }
    }
}
