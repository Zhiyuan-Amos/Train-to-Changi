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
    let player = SKSpriteNode(imageNamed: "player")
    // TODO: asset update

    fileprivate let inbox = SKSpriteNode()
    fileprivate let outbox = SKSpriteNode()

    fileprivate let moveDuration = TimeInterval(2)

    fileprivate var inboxNodes = [SKShapeNode]()
    fileprivate var memoryNodes = [SKShapeNode]()
    fileprivate var outboxNodes = [SKShapeNode]()
    fileprivate var holdingNode = SKShapeNode()

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white // TODO: asset update
        initPlayer()
        initStationElements()
        initNotification()

        /* testing, to remove when integrating
        let queue = Queue(array: [1, 2, 3, 4, 5])
        createInboxNodes(from: queue)
        move(to: .inbox)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.move(to: .outbox)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
            self.move(to: .inbox)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 9) {
            self.move(to: .outbox)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 12) {
            self.move(to: .inbox)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 15) {
            self.move(to: .outbox)
        }
        */
    }

}

// MARK: - Init
extension GameScene {
    func initStationState(_ stationState: StationState) {
        createInboxNodes(from: stationState.input)
        createMemoryNodes(from: stationState.memoryValues)
    }

    fileprivate func initPlayer() {
        player.size = Constants.Player.size
        player.position = Constants.Player.position
        addChild(player)
    }

    fileprivate func initStationElements() {
        inbox.size = Constants.Inbox.size
        inbox.color = Constants.Inbox.color
        inbox.position = Constants.Inbox.position

        outbox.size = Constants.Outbox.size
        outbox.color = Constants.Outbox.color
        outbox.position = Constants.Outbox.position

        addChild(inbox)
        addChild(outbox)
    }

    fileprivate func initNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(catchNotification(notification:)),
            name: Constants.NotificationNames.movePersonInScene, object: nil)
    }

    fileprivate func createMemoryNodes(from memoryValues: [Int?]) {
        // TODO: support memory values
    }

    fileprivate func createInboxNodes(from inboxValues: Queue<Int>) {
        inboxNodes = []
        for (index, value) in inboxValues.toArray.enumerated() {
            let label = SKLabelNode(text: String(value))
            let shape = SKShapeNode(rectOf: Constants.Box.size)
            shape.position = calculateInboxBoxPosition(index: index)
            shape.fillColor = .blue
            shape.addChild(label)
            inboxNodes.append(shape)
            self.addChild(shape)
        }
    }

    fileprivate func calculateInboxBoxPosition(index: Int) -> CGPoint {
        let startingX = inbox.position.x - inbox.size.width / 2 + Constants.Box.size.width / 2
        let calculateX = { (index: Int) -> CGFloat in
            return startingX + CGFloat(index) * Constants.Box.size.width
        }
        return CGPoint(x: calculateX(index), y: inbox.position.y)
    }
}

// MARK: - Notification
extension GameScene {

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
}

// MARK: - Animations
extension GameScene {

    // Move the player to a WalkDestination
    fileprivate func move(to destination: WalkDestination) {
        let moveAction = SKAction.move(to: destination.point, duration: moveDuration)
        switch destination {
        case .inbox:
            player.run(moveAction, completion: {
                self.grabFromInbox()
                let stepAside = SKAction.moveBy(x: 0, y: -100, duration: 0.5)
                self.player.run(stepAside, completion: {
                    _ = self.inboxNodes.map { node in
                        node.run(SKAction.moveBy(x: -100, y: 0, duration: 1))
                    }
                })
            })
        case .outbox:
            player.run(moveAction, completion: {
                _ = self.outboxNodes.map { node in
                    node.run(SKAction.moveBy(x: -100, y: 0, duration: 1))
                }
            })
            let wait = SKAction.wait(forDuration: moveDuration)
            player.run(wait, completion: {
                self.putToOutbox()
            })
        }
    }

    fileprivate func grabFromInbox() {
        guard !self.inboxNodes.isEmpty else {
            return
        }
        // remove from inbox queue and attach to player
        holdingNode = self.inboxNodes.removeFirst()
        holdingNode.move(toParent: player)
    }

    fileprivate func putToOutbox() {
        outboxNodes.append(holdingNode)
        holdingNode.move(toParent: scene!)
        holdingNode.run(SKAction.move(to: Constants.Outbox.entryPosition, duration: 1))
    }

}
