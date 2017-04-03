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
        registerObservers()
    }

    // MARK -- Setup
    private func connectDataSourceAndDelegate() {
        lineNumberCollection.dataSource = self
        lineNumberCollection.delegate = self
    }

    // MARK -- Event Handling
    private func registerObservers() {
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

    // Updates the position of the program counter image depending on which
    // command is currently being executed.
    @objc fileprivate func handleProgramCounterUpdate(notification: Notification) {
        guard let index = notification.userInfo?["index"] as? Int,
            let cell = lineNumberCollection.cellForItem(
                at: IndexPath(row: index, section: 0)) else {
                    fatalError("Misconfiguration of notification on sender's side")
        }

        var origin = lineNumberCollection.convert(cell.frame.origin, to: view)
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
