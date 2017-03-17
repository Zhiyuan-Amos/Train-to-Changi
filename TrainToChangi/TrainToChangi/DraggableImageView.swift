//
//  CommandImageView.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 16/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

// Not used for now
class DraggableImageView: UIImageView {

    var lastLocation: CGPoint?
    var panRecognizer: UIPanGestureRecognizer?
    var copyOnMove: Bool
    private let nc = NotificationCenter.default

    init(frame: CGRect, image: UIImage?, copyOnMove: Bool) {
        self.copyOnMove = copyOnMove
        super.init(image: image)
        self.frame = frame
        self.isUserInteractionEnabled = true
        self.lastLocation = self.center
        self.panRecognizer = UIPanGestureRecognizer(target: self,
                                                    action: #selector(detectPan))
        self.gestureRecognizers = [panRecognizer!]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    func detectPan(recognizer: UIPanGestureRecognizer) {
        recognizer.cancelsTouchesInView = false
        let translation  = recognizer.translation(in: self.superview!)
        self.center = CGPoint(x: lastLocation!.x + translation.x, y: lastLocation!.y + translation.y)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("began")
        if copyOnMove {
            let copiedImageView = DraggableImageView(frame: frame, image: image, copyOnMove: true)
            self.superview?.addSubview(copiedImageView)
        }
        // Promote the touched view
        self.superview?.bringSubview(toFront: self)

        // Remember original location
        lastLocation = self.center
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        nc.post(name: Notification.Name("Command Image is moving!"),
                object: nil,
                userInfo: ["CommandImageView": self])
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        nc.post(name: Notification.Name("Command Image has stopped moving!"),
                object: nil,
                userInfo: ["CommandImageView": self])
        self.removeFromSuperview()
    }

}
