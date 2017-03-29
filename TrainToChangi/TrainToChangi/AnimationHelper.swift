//
//  AnimationHelper.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 27/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class AnimationHelper {

    static func wiggleAnimation() -> CAKeyframeAnimation {
        let transformAnim  = CAKeyframeAnimation(keyPath:"transform")
        transformAnim.values  = [NSValue(caTransform3D: CATransform3DMakeRotation(0.04, 0.0, 0.0, 1.0)),
                                 NSValue(caTransform3D: CATransform3DMakeRotation(-0.04, 0, 0, 1))]
        transformAnim.autoreverses = true
        transformAnim.duration  = 0.2
        transformAnim.repeatCount = Float.infinity

        return transformAnim
    }

    static func dragBeganAnimation(location: CGPoint, cell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            DragBundle.cellSnapshot?.center.y = location.y
            DragBundle.cellSnapshot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            DragBundle.cellSnapshot?.alpha = 0.98
            cell.alpha = 0.0

        }, completion: { (finished) -> Void in
            if finished {
                cell.isHidden = true
            }
        })
    }

    static func dragEndAnimation(cell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            DragBundle.cellSnapshot?.center = cell.center
            DragBundle.cellSnapshot?.transform = CGAffineTransform.identity
            DragBundle.cellSnapshot?.alpha = 0.0
            cell.alpha = 1.0
        }, completion: { (finished) -> Void in
            if finished {
                DragBundle.initialIndexPath = nil
                DragBundle.cellSnapshot!.removeFromSuperview()
                DragBundle.cellSnapshot = nil
            }
        })
    }
}
