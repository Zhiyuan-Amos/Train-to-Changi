//
//  GameScene.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 13/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit
import GameplayKit

// Stores the location that can be reached by player sprite.
// Each location is CGPoint stored as a String "{x, y}".
enum WalkDestination {
    case inbox, outbox

    var point: CGPoint {
        switch self {
        case .inbox:
            return Constants.Inbox.goto
        case .outbox:
            return Constants.Outbox.goto
        }
    }
}

class GameScene: SKScene {
    let player = SKSpriteNode(imageNamed: "player") // TODO: asset update

    private let inbox = SKSpriteNode()
    private let outbox = SKSpriteNode()
    private let moveDuration = TimeInterval(2)

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white // TODO: asset update
        initPlayer()
        initStationElements()
        initNotification()
    }

    private func initPlayer() {
        player.size = Constants.Player.size
        player.position = Constants.Player.position
        addChild(player)
    }

    private func initStationElements() {
        inbox.size = Constants.Inbox.size
        inbox.color = Constants.Inbox.color
        inbox.position = Constants.Inbox.position
        outbox.size = Constants.Outbox.size
        outbox.color = Constants.Outbox.color
        outbox.position = Constants.Outbox.position

        addChild(inbox)
        addChild(outbox)
    }

    private func initNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(catchNotification(notification:)),
            name: Constants.NotificationNames.movePersonInScene, object: nil)
    }

    // Receive notification to control the game scene. Responds accordingly.
    // notification must contains `userInfo` with "destination" defined
    func catchNotification(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print("[GameScene:catchNotification] No userInfo found in notification")
            return
        }

        guard let destination = userInfo["destination"] as? WalkDestination else {
            print("[GameScene:catchNotification] Unable to find destination in userInfo")
            return
        }

        move(to: destination)
    }

    // Move the player to a WalkDestination
    private func move(to destination: WalkDestination) {
        let moveAction = SKAction.move(to: destination.point, duration: moveDuration)
        player.run(moveAction)
    }
}
