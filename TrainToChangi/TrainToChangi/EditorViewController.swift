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
    private var jumpViewsBundles = [JumpViewsBundle]()

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
        for jumpViewsBundle in jumpViewsBundles {
            jumpViewsBundle.arrowView.removeFromSuperview()
        }
        jumpViewsBundles.removeAll()
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

    //TODO: To refactor
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: currentCommandsView)

        struct DragBundle {
            static var cellSnapshot: UIView?
            static var initialIndexPath: IndexPath?
        }

        switch gesture.state {
        case .began:
            guard let indexPath = currentCommandsView.indexPathForItem(at: location),
                  let cell = currentCommandsView.cellForItem(at: indexPath) else {
                return
            }

            DragBundle.initialIndexPath = indexPath
            DragBundle.cellSnapshot = snapshotOfCell(inputView: cell)
            DragBundle.cellSnapshot?.center = cell.center
            DragBundle.cellSnapshot?.alpha = 0.0
            currentCommandsView.addSubview(DragBundle.cellSnapshot!)

            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                DragBundle.cellSnapshot?.center.y = location.y
                DragBundle.cellSnapshot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                DragBundle.cellSnapshot?.alpha = 0.98
                cell.alpha = 0.0

            }, completion: { (finished) -> Void in
                if finished {
                    cell.isHidden = true
                }
            })

        case .changed:
            DragBundle.cellSnapshot?.center.y = location.y
            guard let indexPath = currentCommandsView.indexPathForItem(at: location),
                      indexPath != DragBundle.initialIndexPath! else {
                        return
            }
            currentCommandsView.moveItem(at: DragBundle.initialIndexPath!, to: indexPath)

            if model.userEnteredCommands[DragBundle.initialIndexPath!.item] == .jump
            && model.userEnteredCommands[indexPath.item] == .jumpTarget {
                updateArrowViewsBothJump(jumpIndexPath: DragBundle.initialIndexPath!, jumpTargetIndexPath: indexPath)
            } else if model.userEnteredCommands[indexPath.item] == .jump
                   && model.userEnteredCommands[DragBundle.initialIndexPath!.item] == .jumpTarget {
                updateArrowViewsBothJump(jumpIndexPath: indexPath, jumpTargetIndexPath: DragBundle.initialIndexPath!)
            } else if model.userEnteredCommands[DragBundle.initialIndexPath!.item] == .jump
                   || model.userEnteredCommands[DragBundle.initialIndexPath!.item] == .jumpTarget {
                updateArrowViews(oldIndexPath: DragBundle.initialIndexPath!, newIndexPath: indexPath)
            } else {
                updateArrowViews(oldIndexPath: indexPath, newIndexPath: DragBundle.initialIndexPath!)
            }

            model.moveCommand(fromIndex: DragBundle.initialIndexPath!.item, toIndex: indexPath.item)
            DragBundle.initialIndexPath = indexPath

        default:
            let cell = currentCommandsView.cellForItem(at: DragBundle.initialIndexPath!)
            cell?.isHidden = false
            cell?.alpha = 0.0

            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                DragBundle.cellSnapshot?.center = (cell?.center)!
                DragBundle.cellSnapshot?.transform = CGAffineTransform.identity
                DragBundle.cellSnapshot?.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    DragBundle.initialIndexPath = nil
                    DragBundle.cellSnapshot!.removeFromSuperview()
                    DragBundle.cellSnapshot = nil
                }
                self.currentCommandsView.reloadData()
            })

        }
    }

    /* Helper func */
    // TODO: To Refactor
    @objc private func commandButtonPressed(sender: UIButton) {
        let command = model.currentLevel.availableCommands[sender.tag]
        model.addCommand(commandEnum: command)

        let penultimateIndexPath = IndexPath(item: model.userEnteredCommands.count - 2, section: 0)
        let lastIndexPath = IndexPath(item: model.userEnteredCommands.count - 1, section: 0)

        if command == CommandData.jump {
            currentCommandsView.insertItems(at: [penultimateIndexPath, lastIndexPath])
            currentCommandsView.scrollToItem(at: lastIndexPath, at: UICollectionViewScrollPosition.top,
                                             animated: true)
            let arrowView: UIImageView

            if let jumpTargetCell = currentCommandsView.cellForItem(at: penultimateIndexPath) as? CommandCell,
               let jumpCell = currentCommandsView.cellForItem(at: lastIndexPath) as? CommandCell {

                arrowView = UIEntityHelper.generateArrowView(jumpTargetFrame: jumpTargetCell.frame,
                                                                 jumpFrame: jumpCell.frame)
                self.currentCommandsView.addSubview(arrowView)

            } else { // What is happening is that the jump cell and jump target cell are not visible
                //Get the last visible cell
                let thirdLastIndexPath = IndexPath(item: model.userEnteredCommands.count - 3, section: 0)
                guard let thirdLastCell = currentCommandsView.cellForItem(at: thirdLastIndexPath) as? CommandCell else {
                    return
                }
                let secondLastOrigin = CGPoint(thirdLastCell.frame.minX, thirdLastCell.frame.maxY)
                let secondLastFrame = CGRect(origin: secondLastOrigin, size: thirdLastCell.frame.size)

                let lastOrigin = CGPoint(thirdLastCell.frame.minX, secondLastFrame.maxY)
                let lastFrame = CGRect(origin: lastOrigin, size: thirdLastCell.frame.size)

                arrowView = UIEntityHelper.generateArrowView(jumpTargetFrame: secondLastFrame,
                                                             jumpFrame: lastFrame)
                self.currentCommandsView.addSubview(arrowView)
            }

            let jumpViewsBundle = JumpViewsBundle(jumpIndexPath: lastIndexPath,
                                                 jumpTargetIndexPath: penultimateIndexPath,
                                                 arrowView: arrowView)
            jumpViewsBundles.append(jumpViewsBundle)

        } else {
            currentCommandsView.insertItems(at: [lastIndexPath])
            currentCommandsView.scrollToItem(at: lastIndexPath, at: UICollectionViewScrollPosition.top,
                                             animated: true)
        }

    }

    //TODO: Refactor
    private func updateArrowViews(oldIndexPath: IndexPath, newIndexPath: IndexPath) {
        guard let jumpViewsBundle = getJumpViewsBundle(indexPath: oldIndexPath) else {
            return
        }

        if oldIndexPath == jumpViewsBundle.jumpIndexPath {
            jumpViewsBundle.jumpIndexPath = newIndexPath

            guard let jumpCell = currentCommandsView.cellForItem(at: newIndexPath) else {
                    return
            }
            if !jumpViewsBundle.inverted {
                let newSize = CGSize(width: Constants.UI.arrowWidth,
                                     height: jumpCell.frame.midY - jumpViewsBundle.arrowView.frame.origin.y)

                jumpViewsBundle.arrowView.frame = CGRect(origin: jumpViewsBundle.arrowView.frame.origin,
                                                         size: newSize)
            } else {
                let newOrigin = CGPoint(jumpCell.frame.midX, jumpCell.frame.midY)
                let newSize = CGSize(width: Constants.UI.arrowWidth,
                                     height: jumpViewsBundle.arrowView.frame.origin.y - newOrigin.y
                                        + jumpViewsBundle.arrowView.frame.height)
                jumpViewsBundle.arrowView.frame = CGRect(origin: newOrigin, size: newSize)
            }


        } else {
            jumpViewsBundle.jumpTargetIndexPath = newIndexPath

            guard let jumpTargetCell = currentCommandsView.cellForItem(at: newIndexPath) else {
                    return
            }

            if !jumpViewsBundle.inverted {
                let newOrigin = CGPoint(jumpTargetCell.frame.midX, jumpTargetCell.frame.midY)
                let newSize = CGSize(width: Constants.UI.arrowWidth,
                                     height: jumpViewsBundle.arrowView.frame.origin.y - newOrigin.y
                                        + jumpViewsBundle.arrowView.frame.height)
                jumpViewsBundle.arrowView.frame = CGRect(origin: newOrigin, size: newSize)
            } else {
                let newSize = CGSize(width: Constants.UI.arrowWidth,
                                     height: jumpTargetCell.frame.midY - jumpViewsBundle.arrowView.frame.origin.y)

                jumpViewsBundle.arrowView.frame = CGRect(origin: jumpViewsBundle.arrowView.frame.origin,
                                                         size: newSize)
            }
        }
    }

    private func updateArrowViewsBothJump(jumpIndexPath: IndexPath, jumpTargetIndexPath: IndexPath) {
        guard let jumpViewsBundle = getJumpViewsBundle(indexPath: jumpIndexPath) else {
            return
        }
        let temp = jumpViewsBundle.jumpIndexPath
        jumpViewsBundle.jumpIndexPath = jumpViewsBundle.jumpTargetIndexPath
        jumpViewsBundle.jumpTargetIndexPath = temp

        guard let jumpCell = currentCommandsView.cellForItem(at: jumpViewsBundle.jumpIndexPath),
              let jumpTargetCell = currentCommandsView.cellForItem(at: jumpViewsBundle.jumpTargetIndexPath) else {
                return
        }

        if jumpCell.frame.midY < jumpTargetCell.frame.midY {
            let newOrigin = CGPoint(jumpCell.frame.midX, jumpCell.frame.midY)
            let newSize = CGSize(width: Constants.UI.arrowWidth,
                                 height: jumpTargetCell.frame.midY - jumpCell.frame.midY)
            jumpViewsBundle.arrowView.image = UIImage(named: "arrownavyinvert.png")
            jumpViewsBundle.arrowView.frame = CGRect(origin: newOrigin, size: newSize)
            jumpViewsBundle.inverted = true
        } else {
            let newOrigin = CGPoint(jumpTargetCell.frame.midX, jumpTargetCell.frame.midY)
            let newSize = CGSize(width: Constants.UI.arrowWidth,
                                 height: jumpCell.frame.midY - jumpTargetCell.frame.midY)
            jumpViewsBundle.arrowView.image = UIImage(named: "arrownavy.png")
            jumpViewsBundle.arrowView.frame = CGRect(origin: newOrigin, size: newSize)
            jumpViewsBundle.inverted = false
        }
    }

    private func getJumpViewsBundle(indexPath: IndexPath) -> JumpViewsBundle? {
        for jumpViewBundle in jumpViewsBundles {
            if jumpViewBundle.jumpIndexPath == indexPath
                || jumpViewBundle.jumpTargetIndexPath == indexPath {
                return jumpViewBundle
            }
        }
        return nil
    }

    private func getCellAtGestureLocation(_ location: CGPoint) -> CommandCell? {
        let indexPath = currentCommandsView.indexPathForItem(at: location)
        guard let path = indexPath else {
            return nil
        }

        let cell = currentCommandsView.cellForItem(at: path)
        return cell as? CommandCell
    }

    private func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()

        let cellSnapshot: UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}

class JumpViewsBundle {
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
