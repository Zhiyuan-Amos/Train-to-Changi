//
//  AnimationHelper.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 27/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

/**
 *  Helper class for running animation for drag and drop commands view
 */
class AnimationHelper {

    static func swipeDeleteAnimation(cell: UICollectionViewCell, indexPath: IndexPath,
                                     deleteFunction: @escaping (IndexPath) -> Void) {
        let duration = Constants.Animation.swipeAnimationDuration
        UIView.animate(withDuration: duration, animations: { () -> Void in
            cell.center.x += 300
            cell.alpha = 0.0
        }, completion: { (finished) -> Void in
            if finished {
                //reset cell position and alpha
                cell.center.x -= 300
                cell.alpha = 1.0

                deleteFunction(indexPath)
            }
        })
    }

    static func dragBeganAnimation(location: CGPoint, cell: UICollectionViewCell, dragBundle: DragBundle) {
        let duration = Constants.Animation.dragAnimationDuration
        UIView.animate(withDuration: duration, animations: { () -> Void in
            dragBundle.cellSnapshot?.center.y = location.y
            dragBundle.cellSnapshot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            dragBundle.cellSnapshot?.alpha = 0.98
            cell.alpha = 0.0

        }, completion: { (finished) -> Void in
            if finished {
                cell.isHidden = true
            }
        })
    }

    static func dragEndedAnimation(cell: UICollectionViewCell, dragBundle: DragBundle) {
        let duration = Constants.Animation.dragAnimationDuration
        UIView.animate(withDuration: duration, animations: { () -> Void in
            dragBundle.cellSnapshot?.center = cell.center
            dragBundle.cellSnapshot?.transform = CGAffineTransform.identity
            dragBundle.cellSnapshot?.alpha = 0.0
            cell.alpha = 1.0
        }, completion: { (finished) -> Void in
            if finished {
                dragBundle.initialIndexPath = nil
                dragBundle.cellSnapshot!.removeFromSuperview()
                dragBundle.cellSnapshot = nil
                cell.isHidden = false
            }
        })
    }
}
