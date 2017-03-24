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
    case inbox, outbox, memory(layout: Memory.Layout, index: Int)

    var point: CGPoint {
        switch self {
        case .inbox:
            return Constants.Inbox.goto
        case .outbox:
            return Constants.Outbox.goto
        case let .memory(layout, index):
            return layout.locations[index]
        }
    }
}

class GameScene: SKScene {
    // when `isAnimating` == true, command must wait for animation to finish before executing next command
    fileprivate(set) var isAnimating = false

    fileprivate let player = SKSpriteNode(imageNamed: "player")

    fileprivate let inbox = SKSpriteNode()
    fileprivate let outbox = SKSpriteNode()

    fileprivate var inboxNodes = [SKShapeNode]()
    fileprivate var memoryNodes = [SKShapeNode]()
    fileprivate var outboxNodes = [SKShapeNode]()
    fileprivate var holdingNode = SKShapeNode()

    fileprivate let moveDuration = TimeInterval(2)

    fileprivate var backgroundTileMap: SKTileMapNode!
}

// MARK: - Init
extension GameScene {

    // Called by so that Scene knows data of current Level
    func initLevelState(_ level: Level) {
        initBackground()
        initPlayer()
        initInbox(values: level.initialState.inputs)
        initOutbox()
        initNotification()
        initMemory(from: level.initialState.memoryValues, layout: level.memoryLayout)
    }

    private func initBackground() {
        let rows = Constants.Background.rows
        let columns = Constants.Background.columns
        let size = Constants.Background.size

        guard let tileSet = SKTileSet(named: Constants.Background.tileSet) else {
            fatalError("Ground Tiles Tile Set not found")
        }

        backgroundTileMap = SKTileMapNode(tileSet: tileSet,
                                          columns: columns,
                                          rows: rows,
                                          tileSize: size)

        addChild(backgroundTileMap)

        let tileGroups = tileSet.tileGroups
        guard let bgTile = tileGroups.first(where: {$0.name == Constants.Background.tileGroup}) else {
            fatalError("No Grey Tiles definition found")
        }

        for row in 1...rows {
            for column in 1...columns {
                backgroundTileMap.setTileGroup(bgTile, forColumn: column, row: row)
            }
        }
    }

    private func initPlayer() {
        player.size = Constants.Player.size
        player.position = Constants.Player.position
        player.zPosition = Constants.Player.zPosition
        addChild(player)
    }

    private func initInbox(values: [Int]) {
        inbox.size = Constants.Inbox.size
        inbox.color = Constants.Inbox.color
        inbox.position = Constants.Inbox.position
        addChild(inbox)
        initInboxNodes(from: values)
    }

    private func initOutbox() {

        outbox.size = Constants.Outbox.size
        outbox.color = Constants.Outbox.color
        outbox.position = Constants.Outbox.position

        addChild(outbox)
    }

    private func initNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(catchNotification(notification:)),
            name: Constants.NotificationNames.movePersonInScene, object: nil)
    }

    private func initMemory(from memoryValues: [Int?], layout: Memory.Layout) {
        for (index, value) in memoryValues.enumerated() {
            guard layout.locations.count == memoryValues.count else {
                assertionFailure("Number of memory values differ from the layout specified. Check level data.")
                return
            }
            let box = SKShapeNode(rectOf: Constants.Box.size)
            box.name = "memory \(index)"
            box.position = layout.locations[index]
            box.fillColor = Constants.Memory.fillColor
            // TODO: create box for pre-loaded memory values
            let label = SKLabelNode(text: String(describing: index))
            label.fontSize = Constants.Memory.labelFontSize
            box.addChild(label)
            addChild(box)
        }
    }

    private func initInboxNodes(from inboxValues: [Int]) {
        inboxNodes = []
        for (index, value) in inboxValues.enumerated() {
            let label = SKLabelNode(text: String(value))
            let shape = SKShapeNode(rectOf: Constants.Box.size)
            shape.position = calculateInboxBoxPosition(index: index)
            shape.fillColor = .blue
            shape.addChild(label)
            inboxNodes.append(shape)
            self.addChild(shape)
        }
    }

    private func calculateInboxBoxPosition(index: Int) -> CGPoint {
        let startingX = inbox.position.x - inbox.size.width / 2 + Constants.Box.size.width / 2
        let calculateX = { (index: Int) -> CGFloat in
            return startingX + CGFloat(index) * Constants.Box.size.width
        }
        return CGPoint(x: calculateX(index), y: inbox.position.y)
    }
}

// MARK: - Touch
extension GameScene {
    func memoryLocation(of point: CGPoint) -> Int {
        var index = 0

        return index
    }
}

// MARK: - Notification
extension GameScene {

    // Receive notification to control the game scene. Responds accordingly.
    // notification must contains `userInfo` with "destination" defined
    @objc fileprivate func catchNotification(notification: Notification) {
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
        case let .memory(layout, index):
            break
        }
    }

    private func grabFromInbox() {
        guard !self.inboxNodes.isEmpty else {
            return
        }
        // remove from inbox queue and attach to player
        holdingNode = self.inboxNodes.removeFirst()
        holdingNode.move(toParent: player)
    }

    private func putToOutbox() {
        outboxNodes.append(holdingNode)
        holdingNode.move(toParent: scene!)
        holdingNode.run(SKAction.move(to: Constants.Outbox.entryPosition, duration: 1))
    }

}
