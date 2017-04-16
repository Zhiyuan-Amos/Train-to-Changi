//
//  LoadProgramViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 10/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

/**
 * View controller responsible for the load program view
 */
class LoadProgramViewController: UIViewController {

    internal var savedProgramNames: [[String]] = []
    weak var loadProgramDelegate: DataServiceLoadProgramDelegate?

    @IBOutlet weak var programCollectionView: UICollectionView!

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        programCollectionView.delegate = self
        programCollectionView.dataSource = self

        guard let userId = AuthService.instance.currentUserId else {
            fatalError(Constants.Errors.userNotLoggedIn)
        }
        DataService.instance.loadSavedProgramNames(userId: userId, loadSavedProgramNamesDelegate: self)
    }
}

extension LoadProgramViewController: DataServiceLoadSavedProgramNamesDelegate {
    func load(savedProgramNames: [[String]]) {
        self.savedProgramNames = savedProgramNames
        programCollectionView.reloadData()
    }
}
