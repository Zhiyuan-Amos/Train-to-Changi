//
//  LoadProgramViewController+.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

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
            withReuseIdentifier: Constants.UI.loadProgramCollectionViewCellIdentifier,
            for: indexPath as IndexPath) as? ProgramCell else {
                fatalError(Constants.Errors.cellNotAssignedCorrectViewSubclass)
        }

        let savedName = savedProgramNames[indexPath.section][indexPath.row]
        cell.setProgramCellLabel(programName: savedName)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let reuseIdentifier = Constants.UI.loadProgramCollectionViewHeaderViewIdentifier
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: reuseIdentifier,
                                                                           for: indexPath) as? LoadProgramHeaderView else {
                                                                            fatalError(Constants.Errors.headerViewNotAssignedCorrectViewSubclass)
        }

        let labelText = Constants.StationNames.stationNames[indexPath.section]
        header.setLoadProgramHeaderLabel(labelText: labelText)
        return header
    }
}

extension LoadProgramViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // load the appropriate thing, reloadData, dismiss view
        let levelIndex = indexPath.section
        let saveName = savedProgramNames[levelIndex][indexPath.row]
        guard let userId = AuthService.instance.currentUserId else {
            fatalError(Constants.Errors.userNotLoggedIn)
        }
        guard let loadProgramDelegate = loadProgramDelegate else {
            fatalError(Constants.Errors.delegateNotSet)
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

        let width = collectionView.bounds.width / Constants.UI.programCollectiovViewWidthRatio
        let height = collectionView.bounds.height / Constants.UI.programCollectiovViewHeightRatio
        return CGSize(width: width, height: height)
    }
}
