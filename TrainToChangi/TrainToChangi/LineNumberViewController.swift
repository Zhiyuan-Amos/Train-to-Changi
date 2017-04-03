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

}
