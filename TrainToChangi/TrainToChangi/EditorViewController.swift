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
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var programCounter: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectDataSourceAndDelegate()

        setUpLevelDescription()
        loadAvailableCommands()

        adjustCurrentCommandsCollectionView()
        addGestureRecognisers()

        registerObservers()
    }

    @IBAction func resetButtonPressed(_ sender: Any) {
        model.clearAllCommands()
        removeAllJumpArrows()
        jumpBundles.removeAll()
        currentCommandsView.reloadData()
    }

    // MARK: - Setup
    private func connectDataSourceAndDelegate() {
        currentCommandsView.dataSource = self
        currentCommandsView.delegate = self
    }

    // Initialise the height for level description
    private func setUpLevelDescription() {
        levelDescriptionTextView.text = model.currentLevel.levelDescriptor

        let defaultWidth = levelDescriptionTextView.frame.size.width
        let sizeThatFits = CGSize(width: defaultWidth,
                                  height: CGFloat.greatestFiniteMagnitude)
        let newSize = levelDescriptionTextView.sizeThatFits(sizeThatFits)
        levelDescriptionTextView.frame.size = CGSize(width: max(newSize.width, defaultWidth),
                                                     height: newSize.height)

    }

    // Adjust the position of current commands collection view to be below level description
    private func adjustCurrentCommandsCollectionView() {
        let x = currentCommandsView.frame.minX
        let y = levelDescriptionTextView.frame.maxY + 5
        let width = currentCommandsView.frame.width - 5
        let height = editorView.frame.height - levelDescriptionTextView.frame.height - 80

        currentCommandsView.frame = CGRect(x: x, y: y, width: width, height: height)
    }

    // Load the available commands from model for the current level
    func loadAvailableCommands() {
        let initialCommandPosition = availableCommandsView.frame.origin

        for (commandTag, command) in model.currentLevel.availableCommands.enumerated() {
            let currentCommandPositionY = initialCommandPosition.y +
                CGFloat(commandTag) * Constants.UI.commandButtonOffsetY

            let buttonPosition = CGPoint(x: initialCommandPosition.x,
                                         y: currentCommandPositionY)

            let commandButton = UIEntityHelper.generateCommandUIButton(for: command,
                                                                       position: buttonPosition,
                                                                       tag: commandTag)
            commandButton.addTarget(self, action: #selector(commandButtonPressed), for: .touchUpInside)
            commandButton.frame = view.convert(commandButton.frame, to: availableCommandsView)
            availableCommandsView.addSubview(commandButton)
        }
    }

    // MARK: - Gestures
    private func addGestureRecognisers() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.3
        currentCommandsView.addGestureRecognizer(longPressGesture)

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .right
        currentCommandsView.addGestureRecognizer(swipeGesture)

    }

    @objc private func handleSwipe(gesture: UISwipeGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        guard let indexPath = currentCommandsView.indexPathForItem(at: location),
              let cell = currentCommandsView.cellForItem(at: indexPath) else {
                return
        }

        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            cell.center.x += 300
            cell.alpha = 0.0
        }, completion: { (finished) -> Void in
            if finished {
                // clear all jump arrow views before potentially deleting jumpBundle
                self.removeAllJumpArrows()

                //reset cell position and alpha
                cell.center.x -= 300
                cell.alpha = 1.0

                // if command is related to jump, need to delete bundle
                if let jumpPartnerIndexPath = self.getJumpPartnerIndexPath(indexPath: indexPath) {
                    self.updateJumpBundles(deletedIndexPath: indexPath,
                                      deletedPartnerIndexPath: jumpPartnerIndexPath)
                    self.deleteJumpBundle(deletedIndexPath: indexPath)
                } else {
                    self.updateJumpBundles(deletedIndexPath: indexPath)
                }
                self.renderJumpArrows()

                _ = self.model.removeCommand(fromIndex: indexPath.item)
                self.currentCommandsView.reloadData()

            }
        })
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

    // MARK: - Button Actions Func
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

    // MARK: - Drawing Helper Functions
    private func getArrowOrigin(at indexPath: IndexPath) -> CGPoint {
        return CGPoint(Constants.UI.collectionCellWidth * 0.5,
                       getMidYOfCell(at: indexPath))
    }

    private func getMidYOfCell(at indexPath: IndexPath) -> CGFloat {
        return Constants.UI.topEdgeInset
            + (CGFloat(indexPath.item + 1) * Constants.UI.collectionCellHeight)
            - (0.5 * Constants.UI.collectionCellHeight)
    }

    private func getHeightBetweenIndexPaths(_ indexPathOne: IndexPath,
                                            _ indexPathTwo: IndexPath) -> CGFloat {
        return abs(getMidYOfCell(at: indexPathOne)
             - getMidYOfCell(at: indexPathTwo))

    }

    // MARK: - Jump Helper Functions

    // update jump bundles when a non-jump related command is being deleted
    private func updateJumpBundles(deletedIndexPath: IndexPath) {
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
    private func updateJumpBundles(deletedIndexPath: IndexPath, deletedPartnerIndexPath: IndexPath) {
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

    private func deleteJumpBundle(deletedIndexPath: IndexPath) {
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

    private func performOneJumpCommandUpdate(oldIndexPath: IndexPath, newIndexPath: IndexPath) {
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

    private func getJumpPartnerIndexPath(indexPath: IndexPath) -> IndexPath? {
        if isJump(indexPath: indexPath) {
            return getJumpViewsBundle(indexPath: indexPath)?.jumpTargetIndexPath
        } else if isJumpTarget(indexPath: indexPath) {
            return getJumpViewsBundle(indexPath: indexPath)?.jumpIndexPath
        } else {
            return nil
        }
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
        let origin = getArrowOrigin(at: topIndexPath)
        let height = getHeightBetweenIndexPaths(topIndexPath, bottomIndexPath)
        return UIEntityHelper.generateArrowView(origin: origin,
                                                height: height)
    }

    private func renderJumpArrows() {
        removeAllJumpArrows()
        for jumpArrow in redrawAllJumpArrows() {
            currentCommandsView.addSubview(jumpArrow)
        }
    }

    private func isJumpRelatedCommand(indexPath: IndexPath) -> Bool {
        return model.userEnteredCommands[indexPath.item] == .jump
            || model.userEnteredCommands[indexPath.item] == .jumpTarget
    }

    private func isJump(indexPath: IndexPath) -> Bool {
        return model.userEnteredCommands[indexPath.item] == .jump
    }

    private func isJumpTarget(indexPath: IndexPath) -> Bool {
        return model.userEnteredCommands[indexPath.item] == .jumpTarget
    }

    // MARK: - Gesture Helper Func
    private func initDragBundleAtGestureBegan(indexPath: IndexPath, cell: UICollectionViewCell) {
        DragBundle.initialIndexPath = indexPath
        DragBundle.cellSnapshot = UIEntityHelper.snapshotOfCell(inputView: cell)
        DragBundle.cellSnapshot?.center = cell.center
        DragBundle.cellSnapshot?.alpha = 0.0
    }

    // MARK: - Other Helper Func
    private func isIndexedCommand(indexPath: IndexPath) -> Bool {
        switch model.userEnteredCommands[indexPath.item] {
        case .add(_), .copyFrom(_), .copyTo(_):
            return true
        default:
            return false
        }
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRunStateUpdate(notification:)),
            name: Constants.NotificationNames.runStateUpdated, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleProgramCounterUpdate(notification:)),
            name: Constants.NotificationNames.moveProgramCounter, object: nil)
    }

    // Updates whether the views are enabled depending on the `model.runState`.
    @objc fileprivate func handleRunStateUpdate(notification: Notification) {
        switch model.runState {
        case .running, .won, .stepping:
            resetButton.isEnabled = false
            currentCommandsView.isUserInteractionEnabled = false
            availableCommandsView.isUserInteractionEnabled = false
        case .paused, .lost:
            resetButton.isEnabled = true
            currentCommandsView.isUserInteractionEnabled = true
            availableCommandsView.isUserInteractionEnabled = true
        }
    }

    // Updates the position of the program counter image depending on which 
    // command is currently being executed.
    @objc fileprivate func handleProgramCounterUpdate(notification: Notification) {
        guard let index = notification.userInfo?["index"] as? Int,
            let cell = currentCommandsView.cellForItem(
                at: IndexPath(row: index, section: 0)) else {
                    fatalError("Misconfiguration of notification on sender's side")
        }

        var origin = currentCommandsView.convert(cell.frame.origin, to: view)
        origin.x -= (programCounter.frame.size.width + Constants.UI.programCounterOffsetX)

        // `programCounter` is hidden at the start before the user presses the `play` /
        // `stepForward` button.
        if programCounter.isHidden {
            programCounter.isHidden = false
            programCounter.frame.origin = origin
        } else {
            UIView.animate(withDuration: Constants.Animation.programCounterMovementDuration,
                           animations: { self.programCounter.frame.origin = origin })
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
