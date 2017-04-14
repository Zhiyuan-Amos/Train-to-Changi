//
//  DragDropViewController+.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 14/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

extension DragDropViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Constants.UI.numberOfSectionsInCommandsCollectionView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.userEnteredCommands.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cellIdentifier = Constants.UI.dragDropCollectionViewCellIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                            for: indexPath) as? CommandCell else {
            fatalError(Constants.Errors.cellNotAssignedCorrectViewSubclass)
        }

        let command = model.userEnteredCommands[indexPath.item]
        cell.setup(command: command)
        return cell
    }

}

extension DragDropViewController: UICollectionViewDelegateFlowLayout {
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
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.UI.dragDropCollectionCellWidth,
                      height: Constants.UI.commandCollectionCellHeight)
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
