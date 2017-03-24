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

    fileprivate var inboxNodes = [SKSpriteNode]()
    fileprivate var memoryNodes = [SKSpriteNode]()
    fileprivate var outboxNodes = [SKSpriteNode]()
    fileprivate var holdingNode = SKSpriteNode()

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
        for (index, _) in memoryValues.enumerated() {
            guard layout.locations.count == memoryValues.count else {
                assertionFailure("Number of memory values differ from the layout specified. Check level data.")
                return
            }
            let box = SKSpriteNode(imageNamed: "memory")
            box.size = Constants.Memory.size
            box.position = layout.locations[index]
            box.name = "memory \(index)"

            // TODO: create box for pre-loaded memory values
            let label = SKLabelNode(text: String(describing: index))
            label.position = CGPoint(x: label.position.x + Constants.Memory.labelOffsetX,
                                     y: label.position.y + Constants.Memory.labelOffsetY)
            label.fontSize = Constants.Memory.labelFontSize
            box.addChild(label)
            addChild(box)
        }
    }

    private func initInboxNodes(from inboxValues: [Int]) {
        inboxNodes = []
        for (index, value) in inboxValues.enumerated() {
            //TODO: Wondering if we can place the values init somewhere else.
            let label = SKLabelNode(text: String(value))
            label.position.y += Constants.Box.labelOffsetY
            label.fontName = Constants.Box.fontName
            label.fontSize = Constants.Box.fontSize
            label.fontColor = Constants.Box.fontColor

            let box = SKSpriteNode(imageNamed: Constants.Box.imageName)
            box.size = Constants.Box.size
            box.position = calculateInboxBoxPosition(index: index)
            box.zRotation = Constants.Box.rotationAngle

            box.addChild(label)
            inboxNodes.append(box)
            self.addChild(box)
        }
    }

    private func calculateInboxBoxPosition(index: Int) -> CGPoint {
        let startingX = inbox.position.x - inbox.size.width / 2 + Constants.Box.size.width / 2
            + Constants.Inbox.imagePadding

        let offsetX = CGFloat(index) * (Constants.Box.size.width + Constants.Inbox.imagePadding)

        return CGPoint(x: startingX + offsetX, y: inbox.position.y)
    }
}

// MARK: - Touch
extension GameScene {
    func memoryLocation(of point: CGPoint) -> Int {
        let index = 0

        return index
    }
}

// MARK: - Notification
extension GameScene {

    // Receive notification to control the game scene. Responds accordingly.
    // notification must contains `userInfo` with "destination" defined
    @objc fileprivate func catchNotification(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            fatalError("[GameScene:catchNotification] Notification has no userInfo")
        }

        guard let destination = userInfo["destination"] as? WalkDestination else {
            fatalError("[GameScene:catchNotification] userInfo should contain destination")
        }

        move(to: destination)
    }
}

// MARK: - Animations
extension GameScene {

    // Move the player to a WalkDestination
    fileprivate func move(to destination: WalkDestination) {
        switch destination {
        case .inbox:
            animateGoToInbox()
        case .outbox:
            animateGoToOutbox()
        case .memory(_, _):
            break
        }
    }

    private func animateGoToInbox() {
        // 1. walk to inbox
        let moveAction = SKAction.move(to: WalkDestination.inbox.point,
                                       duration: Constants.Animation.moveToConveyorBeltDuration)
        player.run(moveAction, completion: {
            self.grabFromInbox()
            // 2. step aside after getting box
            let stepAside = SKAction.move(by: Constants.Animation.afterInboxStepVector,
                                          duration: Constants.Animation.afterInboxStepDuration)
            // 3. meantime inbox items move left
            self.player.run(stepAside, completion: {
                _ = self.inboxNodes.map { node in self.moveConveyorBelt(node) }
            })
        })
    }

    private func animateGoToOutbox() {
        // 1. walk to outbox
        let moveAction = SKAction.move(to: WalkDestination.outbox.point,
                                       duration: Constants.Animation.moveToConveyorBeltDuration)
        player.run(moveAction, completion: {
            // 2. then, outbox items move left
            _ = self.outboxNodes.map { node in self.moveConveyorBelt(node) }
        })
        let wait = SKAction.wait(forDuration: Constants.Animation.moveToConveyorBeltDuration)
        player.run(wait, completion: {
            // 3. wait for outbox movements finish, put on outbox
            self.putToOutbox()
        })
    }

    private func moveConveyorBelt(_ node: SKSpriteNode) {
        node.run(
            SKAction.move(by: Constants.Animation.moveConveyorBeltVector,
                          duration: Constants.Animation.moveConveyorBeltDuration))
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
        holdingNode.run(SKAction.move(to: Constants.Outbox.entryPosition,
                                      duration: Constants.Animation.holdingToOutboxDuration))
    }

}
