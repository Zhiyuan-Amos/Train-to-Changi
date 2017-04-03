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
        guard let index = notification.userInfo?["index"] as? Int,
            let cell = lineNumberCollection.cellForItem(
                at: IndexPath(row: index, section: 0)) else {
                    fatalError("Misconfiguration of notification on sender's side")
        }

        var origin = cell.frame.origin
        // `programCounter` is hidden at the start before the user presses the `play` /
        // `stepForward` button
        if programCounter.isHidden {
            programCounter.isHidden = false
            programCounter.frame.origin = origin
        } else {
            UIView.animate(withDuration: Constants.Animation.programCounterMovementDuration,
                           animations: { self.programCounter.frame.origin = origin })
        }
        print(programCounter.frame.origin)
    }

}
