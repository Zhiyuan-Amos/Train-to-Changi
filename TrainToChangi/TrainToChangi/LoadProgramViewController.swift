//
//  LoadProgramViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 10/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class LoadProgramViewController: UIViewController {
    @IBOutlet weak var programCollectionView: UICollectionView!
    fileprivate var savedProgramNames: [[String]] = []

    override func viewDidLoad() {
        programCollectionView.delegate = self
        programCollectionView.dataSource = self
        guard let userId = AuthService.instance.currentUserId else {
            fatalError("bug")
        }
        DataService.instance.loadUserAddedCommands(userId: userId, loadSavedProgramNamesDelegate: self)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }

    //TODO - on tap on collection cell, use delegate!!! Not notifications
    // do not abuse notifications please
}

extension LoadProgramViewController: DataServiceLoadSavedProgramNamesDelegate {
    func load(savedProgramNames: [[String]]) {
        self.savedProgramNames = savedProgramNames
        programCollectionView.reloadData()
    }
}

// MARK - Extension UICollectionViewDataSource

extension LoadProgramViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return savedProgramNames.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedProgramNames[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Cell dequeued")
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "programCell",
            for: indexPath as IndexPath) as? ProgramCell else {
                fatalError("Cell not assigned the proper view subclass!")
        }
        let savedName = savedProgramNames[indexPath.section][indexPath.row]
        cell.setProgramCellLabel(programName: savedName)
        return cell
    }
}

// MARK - Extension UICollectionViewDelegateFlowLayout

extension LoadProgramViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell selected at \(indexPath)")
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = UIEdgeInsets(top: 0,
                                     left: 0,
                                     bottom: 0,
                                     right: 0)
        return edgeInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width / 2.5
        let height = collectionView.bounds.height / 4
        return CGSize(width: width, height: height)
    }
}
