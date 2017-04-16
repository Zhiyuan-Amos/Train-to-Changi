//
//  GameScene.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 13/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The Scene class that displays the game states to the user. GameScene is dumb and does
/// not know the logic and execution states of the game. It only responds by reacting to
/// notifications telling it what to do. GameScene will display relevant animations and
/// send a notification to indicate that the animation is finished, for other components
/// to proceed.
class GameScene: SKScene {
    // MARK: - Concurrency
    // works like a semaphore, except it doesn't pause the thread when value == 0
    var suspendDispatch = 0

    // MARK: - Level
    var level: Level! // implicit unwrap because scene can't recover from a nil `level`

    // MARK: - Player/Robot/Boss
    let player = SKSpriteNode(imageNamed: Constants.Player.imageNamed) // The object that shifts things around
    var holdingNode: Payload? // The value `player` is holding
    var jedi: JediSprite! // The object that gives instructions and feedbacks
    var speechBubble: SpeechBubbleSprite! // Speech bubble of `jedi`

    // Remembers the positions `player` has visited. When `player` is at new position, push old position; when
    // needs to step back, pop the last position and move `player` back to that position
    var playerPreviousPositions = Stack<CGPoint>()

    // MARK: - Inbox
    let inbox = SKSpriteNode(imageNamed: Constants.Inbox.imageNamed) // inbox conveyor
    var inboxNodes = [Payload]() // payloads on `inbox`

    // MARK: - Outbox
    let outbox = SKSpriteNode(imageNamed: Constants.Outbox.imageNamed) // outbox conveyor
    var outboxNodes = [Payload]() // payloads on `outbox`

    // MARK: - Memory
    var memoryLayout: Memory.Layout? // How memories are laid out on the station floor
    var memorySlots = [MemorySlot]() // The memory locations that payload can be put onto

    // The payloads that are inside memory. Use a dictionary to avoid inserting empty
    // payloads (as it is unnecessary to start filling the memory from location 0).
    var memoryNodes = [Int: Payload]()

    // MARK: - Background
    var backgroundTileMap: SKTileMapNode! // The station ground displayed as 2D arrays

    // MARK: - Init
    init(_ level: Level, size: CGSize) {
        self.level = level
        super.init(size: size)
    }

    override func didMove(to view: SKView) {
        initElements(level: level)
        initNotification()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
