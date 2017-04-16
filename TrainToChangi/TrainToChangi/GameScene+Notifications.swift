//
// Created by zhongwei zhang on 4/15/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

// MARK: - Notification
/// This extension includes methods that are used to handle notifications concerning
/// GameScene. There are three types of notifications that GameScene is supposed to
/// handle: - move the robot in the scene,
///         - reset the scene to a previous point in gameplay
///         - update the speed of animation
extension GameScene {

    // Receive notification to control the game scene. Responds accordingly.
    // notification must contains `userInfo` with "destination" defined
    @objc func handleMovePerson(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let destination = userInfo["destination"] as? WalkDestination else {
            fatalError("[GameScene:handleMovePerson] Notification not set up properly")
        }

        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationBegan,
                                                     object: nil, userInfo: nil))
        move(to: destination)
    }

    @objc func handleResetScene(notification: Notification) {
        if notification.userInfo?["isAnimating"] as? Bool == true {
            suspendDispatch += 1
        }

        removeAllAnimations()
        if let levelState = notification.object as? LevelState {
            rePresentDynamicElements(levelState: levelState)
        } else {
            rePresentDynamicElements()
        }
    }

    @objc func updateNodesSpeed(notification: Notification) {
        guard let sliderValue = notification.userInfo?["sliderValue"] as? Float else {
            fatalError("Notification sender is not configured properly")
        }
        updateSpeed(sliderValue: CGFloat(sliderValue))
    }
}

