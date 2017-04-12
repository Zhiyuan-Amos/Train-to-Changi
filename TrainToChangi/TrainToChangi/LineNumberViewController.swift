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

    var programCounter: UIImageView!
    @IBOutlet weak var lineNumberCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgramCounter()
        connectDataSourceAndDelegate()
        lineNumberCollection.isScrollEnabled = false
        registerObservers()
    }

    override func viewDidLayoutSubviews() {
        setBackgroundGradient()
    }

    private func setBackgroundGradient() {
        let gradient = CAGradientLayer()
        gradient.startPoint = Constants.Background.leftToRightGradientPoints["startPoint"]!
        gradient.endPoint = Constants.Background.leftToRightGradientPoints["endPoint"]!

        gradient.frame = view.bounds
        gradient.colors = [Constants.Background.editorGradientStartColor,
                           Constants.Background.editorGradientEndColor]
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func connectDataSourceAndDelegate() {
        lineNumberCollection.dataSource = self
        lineNumberCollection.delegate = self
    }

    fileprivate func setupProgramCounter() {
        programCounter = UIImageView(image: UIImage(named: "program-counter"))
        programCounter.frame.origin.x = 0
        programCounter.frame.origin.y = 0
        programCounter.frame.size.height = Constants.UI.collectionCellHeight
        programCounter.frame.size.width = 20
        programCounter.isHidden = false
        programCounter.frame = view.convert(programCounter.frame, to: lineNumberCollection)
        lineNumberCollection.addSubview(programCounter)
    }

    fileprivate func resetProgramCounter() {
        programCounter.frame.origin.x = 0
        programCounter.frame.origin.y = 10
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
            self, selector: #selector(handleAddCommand(notification:)),
            name: Constants.NotificationNames.userLoadCommandEvent,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleResetCommand(notification:)),
            name: Constants.NotificationNames.userResetCommandEvent,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleScroll(notification:)),
            name: Constants.NotificationNames.userScrollEvent,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleProgramCounterUpdate(notification:)),
            name: Constants.NotificationNames.moveProgramCounter,
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

    @objc private func handleLoadCommand(notification: Notification) {
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
            self.semaphore.wait()
            if self.model.runState == .running(isAnimating: true)
                || self.model.runState == .stepping(isAnimating: true) {
                self.semaphore.wait()
            }

            DispatchQueue.main.sync {
                self.updateProgramCounterCoordinates(notification: notification)
            }
        }
    }

    private func updateProgramCounterCoordinates(notification: Notification) {
        if let _ = notification.userInfo?["index"] as? Int {
            UIView.animate(withDuration: Constants.Animation.programCounterMovementDuration,
                           animations: { self.programCounter.frame.origin.y += CGFloat(50) })
        }
    }

    @objc fileprivate func handleAnimationEnd(notification: Notification) {
        semaphore.signal()
    }

    @objc fileprivate func handleEndOfCommandExecution(notification: Notification) {
        semaphore.signal()
    }

    // Updates the display of program counter depending on `runState`.
    @objc fileprivate func handleRunStateUpdate(notification: Notification) {
        if programCounter.isHidden {
            resetProgramCounter()
            programCounter.isHidden = false
        }

        switch model.runState {
        case .start, .lost:
            programCounter.isHidden = true
        default:
            break
        }
    }
}
