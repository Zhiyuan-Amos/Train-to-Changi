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
    weak var loadProgramDelegate: DataServiceLoadProgramDelegate?

    override func viewDidLoad() {
        programCollectionView.delegate = self
        programCollectionView.dataSource = self

        guard let userId = AuthService.instance.currentUserId else {
            fatalError("User must be logged in!")
        }
        DataService.instance.loadSavedProgramNames(userId: userId, loadSavedProgramNamesDelegate: self)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }

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

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "programCell",
            for: indexPath as IndexPath) as? ProgramCell else {
                fatalError("Cell not assigned the proper view subclass!")
        }

        let savedName = savedProgramNames[indexPath.section][indexPath.row]
        cell.setProgramCellLabel(programName: savedName)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "headerView",
                                                                           for: indexPath) as? LoadProgramHeaderView else {
            fatalError("Header View not assigned the proper view subclass!")
        }
        let labelText = Constants.StationNames.stationNames[indexPath.section]
        header.setLoadProgramHeaderLabel(labelText: labelText)
        return header
    }
}

// MARK - Extension UICollectionViewDelegateFlowLayout
extension LoadProgramViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // load the appropriate thing, reloadData, dismiss view
        let levelIndex = indexPath.section
        let saveName = savedProgramNames[levelIndex][indexPath.row]
        guard let userId = AuthService.instance.currentUserId else {
            fatalError("User must be logged in!")
        }
        guard let loadProgramDelegate = loadProgramDelegate else {
            fatalError("Delegate not set up!")
        }
        DataService.instance.loadSavedUserProgram(userId: userId,
                                                  levelIndex: levelIndex,
                                                  saveName: saveName,
                                                  loadProgramDelegate: loadProgramDelegate)
        dismiss(animated: true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width / 2.5
        let height = collectionView.bounds.height / 4
        return CGSize(width: width, height: height)
    }
}
