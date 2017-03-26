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
    case inbox, outbox, memory(layout: Memory.Layout, index: Int, action: Memory.Action)

    var point: CGPoint {
        switch self {
        case .inbox:
            return Constants.Inbox.goto
        case .outbox:
            return Constants.Outbox.goto
        case let .memory(layout, index, _):
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
                fatalError("[GameScene:initMemory] " +
                               "Number of memory values differ from the layout specified. Check level data.")
            }

            addChild(MemorySlot(index: index, layout: layout))
        }
    }

    private func initInboxNodes(from inboxValues: [Int]) {
        inboxNodes = []
        for (index, value) in inboxValues.enumerated() {
            let payload = Payload(position: calculateInboxBoxPosition(index: index), value: value)
            inboxNodes.append(payload)
            self.addChild(payload)
        }
    }

    private func calculateInboxBoxPosition(index: Int) -> CGPoint {
        let startingX = inbox.position.x - inbox.size.width / 2 + Constants.Payload.size.width / 2
            + Constants.Inbox.imagePadding

        let offsetX = CGFloat(index) * (Constants.Payload.size.width + Constants.Inbox.imagePadding)

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationEnded,
                                                         object: nil, userInfo: nil))
        })
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
        case let .memory(layout, index, action):
            animateGoToMemory(layout, index, action)
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

    private func animateGoToMemory(_ layout: Memory.Layout, _ index: Int, _ action: Memory.Action) {
        guard index > 0 && index < memoryNodes.count else {
            fatalError("[GameScene:animateGoToMemory] Trying to access memory out of bound")
        }
        let moveAction = SKAction.move(to: layout.locations[index],
                                       duration: Constants.Animation.moveToMemoryDuration)
        player.run(moveAction, completion: {
            // player already moved to memory location, perform memory actions
            switch action {
            case .pickUp:
                self.pickUpMemory(index)
            case .putDown:
                self.putDownToMemory(index)
            case let .compute(expected):
                self.computeWithMemory(index, expected: expected)
                break
            }
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

    // player should already move to necessary memory location
    private func pickUpMemory(_ index: Int) {
        let memory = memoryNodes[index]
        let throwHoldingVal = SKAction.fadeOut(withDuration: 0.5)
        let removeFromParent = SKAction.removeFromParent()

        holdingNode.run(SKAction.sequence([throwHoldingVal, removeFromParent]), completion: {
            memory.move(toParent: self.player)
        })
    }

    // player should already move to necessary memory location
    private func putDownToMemory(_ index: Int) {
        guard let copyOfHoldingValue = holdingNode.copy() as? SKSpriteNode else {
            fatalError("[GameScene:putDownToMemory] Can't make a copy of holding value")
        }

        let position = memoryNodes[index].position

        copyOfHoldingValue.move(toParent: scene!)
        let dropHolding = SKAction.move(to: position, duration: 0.5)
        copyOfHoldingValue.run(dropHolding)
    }

    private func computeWithMemory(_ index: Int, expected: Int) {
        guard let payloadOnMemory = memoryNodes[index].childNode(withName: Constants.Payload.labelName)
              as? SKLabelNode else {
            fatalError("[GameScene:computeWithMemory] Unable to find payload's label")
        }
        payloadOnMemory.text = String(expected)
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
