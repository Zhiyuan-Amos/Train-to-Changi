//
//  LineNumberViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 2/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class LineNumberViewController: UIViewController {

    var model: Model!
    let semaphore = DispatchSemaphore(value: 0)

    @IBOutlet weak var programCounter: UIImageView!
    @IBOutlet weak var lineNumberCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectDataSourceAndDelegate()
        lineNumberCollection.isScrollEnabled = false
        registerObservers()
    }

    private func connectDataSourceAndDelegate() {
        lineNumberCollection.dataSource = self
        lineNumberCollection.delegate = self
    }
}

// MARK -- Event Handling
extension LineNumberViewController {
    fileprivate func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleDeleteCommand(notification:)),
            name: Constants.NotificationNames.userDeleteCommandEvent,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAddCommand(notification:)),
            name: Constants.NotificationNames.userAddCommandEvent,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleResetCommand(notification:)),
            name: Constants.NotificationNames.userResetCommandEvent,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleProgramCounterUpdate(notification:)),
            name: Constants.NotificationNames.moveProgramCounter,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleScroll(notification:)),
            name: Constants.NotificationNames.userScrollEvent,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleEndOfCommandExecution(notification:)),
            name: Constants.NotificationNames.endOfCommandExecution, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRunStateUpdate(notification:)),
            name: Constants.NotificationNames.runStateUpdated, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAnimationEnd(notification:)),
            name: Constants.NotificationNames.animationEnded, object: nil)
    }

    @objc private func handleAddCommand(notification: Notification) {
        lineNumberCollection.reloadData()

        let lastIndexPath = IndexPath(item: model.userEnteredCommands.count - 1, section: 0)
        lineNumberCollection.scrollToItem(at: lastIndexPath,
                                         at: UICollectionViewScrollPosition.top,
                                         animated: true)
    }

    @objc private func handleDeleteCommand(notification: Notification) {
        lineNumberCollection.reloadData()
    }

    @objc private func handleResetCommand(notification: Notification) {
        lineNumberCollection.reloadData()
        programCounter.isHidden = true
    }

    @objc private func handleScroll(notification: Notification) {
        guard let offset = notification.object as? CGPoint else {
            fatalError("Scroll event object should be CGPoint")
        }
        var contentOffset = lineNumberCollection.contentOffset
        contentOffset.y = offset.y
        lineNumberCollection.setContentOffset(contentOffset, animated: false)
    }

    // Updates the position of the program counter image depending on which
    // command is currently being executed.
    @objc fileprivate func handleProgramCounterUpdate(notification: Notification) {
        let serialQueue = DispatchQueue(label: Constants.Concurrency.serialQueue)

        serialQueue.async {
            print("queuing to update PC")
            self.semaphore.wait()
            if self.model.runState == .running(isAnimating: true)
                || self.model.runState == .stepping(isAnimating: true) {
                print("sleeping zzz")
                self.semaphore.wait()
            }
            print("not animating or woken up")
            DispatchQueue.main.sync {
                self.updateProgramCounterCoordinates(notification: notification)
            }
        }
    }

    private func setUpProgramCounter() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        if let cell = lineNumberCollection.cellForItem(at: firstIndexPath) {
            var origin = lineNumberCollection.convert(cell.frame.origin, to: view)
            origin.x -= (programCounter.frame.size.width + Constants.UI.programCounterOffsetX)
            programCounter.frame.origin = origin
        }
    }

    private func updateProgramCounterCoordinates(notification: Notification) {
        if let index = notification.userInfo?["index"] as? Int,
            let cell = lineNumberCollection.cellForItem(at:
                IndexPath(row: index, section: 0)) {
            let cellYCoords = lineNumberCollection.convert(cell.frame.origin, to: self.view).y
            UIView.animate(withDuration: Constants.Animation.programCounterMovementDuration,
                           animations: { self.programCounter.frame.origin.y = cellYCoords })
        } else {
            UIView.animate(withDuration: Constants.Animation.programCounterMovementDuration,
                           animations: { self.programCounter.frame.origin.y += CGFloat(40) })
        }
    }

    @objc fileprivate func handleAnimationEnd(notification: Notification) {
        print("animationEnded")
        semaphore.signal()
    }

    @objc fileprivate func handleEndOfCommandExecution(notification: Notification) {
        print("executionEnded")
        semaphore.signal()
    }

    // Updates the display of program counter depending on `runState`.
    @objc fileprivate func handleRunStateUpdate(notification: Notification) {
        if programCounter.isHidden {
            setUpProgramCounter()
            programCounter.isHidden = false
        }

        switch model.runState {
        case .start:
            programCounter.isHidden = true
        default:
            break
        }
    }
}
