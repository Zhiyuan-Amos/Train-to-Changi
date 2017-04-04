//
//  EditorViewControllerExtensions.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 29/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
extension DragDropViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Constants.UI.numberOfSectionsInCollectionView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.userEnteredCommands.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cellIdentifier = Constants.UI.dragDropCollectionViewCellIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                            for: indexPath) as? CommandCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }

        let command = model.userEnteredCommands[indexPath.item]
        cell.setImageAndIndex(commandType: command)
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
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.UI.minimumLineSpacingForSection
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.UI.minimumInteritemSpacingForSection
    }
}

extension LineNumberViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Constants.UI.numberOfSectionsInCollectionView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.userEnteredCommands.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cellIdentifier = Constants.UI.lineNumberCollectionViewCellIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                            for: indexPath) as? LineNumberCell else {
            fatalError("Cell not assigned the proper view subclass!")
        }

        cell.setLineNumberLabel(index: indexPath.item + 1)
        return cell
    }

}

extension LineNumberViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        let edgeInset = UIEdgeInsets(top: Constants.UI.topEdgeInset,
                                     left: 0, bottom: 0,
                                     right: 0)
        return edgeInset
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
