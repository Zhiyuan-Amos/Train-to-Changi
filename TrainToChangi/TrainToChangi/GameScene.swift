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
enum StationLocation: CGPoint {
    // TODO: positions calculation
    case inbox = "{100, 0}"
    case outbox = "{800, 800}"
}

class GameScene: SKScene {
    let player = SKSpriteNode(imageNamed: "player") // TODO: asset update

    // TODO: refactor to constants
    private let inbox = SKSpriteNode(color: .black, size: CGSize(width: 100, height: 500))
    private let outbox = SKSpriteNode(color: .black, size: CGSize(width: 100, height: 500))
    private let notificationName = Notification.Name(rawValue: "movePersonInScene")
    private let moveDuration = TimeInterval(2)


    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white // TODO: asset update
        initPlayer()
        initStationElements()
        initNotification()
    }

    // TODO: positions calculation
    private func initPlayer() {
        player.size = CGSize(width: 100, height: 100)
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(player)
    }

    private func initStationElements() {
        inbox.position = CGPoint(x: 0, y: 0)
        outbox.position = CGPoint(x: size.width - 100, y: size.height - 500)
        addChild(inbox)
        addChild(outbox)
    }

    private func initNotification() {
        let nc = NotificationCenter.default
        let selector = #selector(catchNotification(notification:))
        nc.addObserver(self, selector: selector, name: notificationName, object: nil)
    }

    // Receive notification to control the game scene. Responds accordingly.
    // notification must contains `userInfo` with "location" defined
    func catchNotification(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print("[GameScene:catchNotification] No userInfo found in notification")
            return
        }

        guard let location = userInfo["location"] as? StationLocation else {
            print("[GameScene:catchNotification] Unable to find location in userInfo")
            return
        }

        move(to: location)
    }

    // Move the player to a StationLocation
    private func move(to location: StationLocation) {
        let moveAction = SKAction.move(to: location.rawValue, duration: moveDuration)
        player.run(moveAction)
    }
}

// Extends CGPoint so that it's convertible from Sgring literal,
// so CGPoint can be used as a raw type for enum
extension CGPoint: ExpressibleByStringLiteral {

    public init(stringLiteral value: StringLiteralType) {
        self = CGPointFromString(value)
    }

    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = CGPointFromString(value)
    }

    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = CGPointFromString(value)
    }
}
