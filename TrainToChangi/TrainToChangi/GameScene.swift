//
//  GameScene.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 13/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // works like a semaphore, except it doesn't pause the thread when value == 0
    var suspendDispatch = 0

    var level: Level! // implicit unwrap because scene can't recover from a nil `level`

    let player = SKSpriteNode(imageNamed: "r2d2")
    var playerPreviousPositions = Stack<CGPoint>()

    let inbox = SKSpriteNode(imageNamed: "conveyor-belt-1")
    let outbox = SKSpriteNode(imageNamed: "conveyor-belt-1")

    var inboxNodes = [Payload]()
    var memoryNodes = [Int: Payload]()
    var memorySlots = [MemorySlot]()
    var outboxNodes = [Payload]()
    var holdingNode: Payload?
    var jedi: JediSprite!
    var speechBubble: SpeechBubbleSprite!

    var memoryLayout: Memory.Layout?

    var backgroundTileMap: SKTileMapNode!

    init(_ level: Level, size: CGSize) {
        self.level = level
        super.init(size: size)
    }

    override func didMove(to view: SKView) {
        initBackground()
        initPlayer()
        initJedi()
        initInbox(values: level.initialState.inputs)
        initOutbox()
        initNotification()
        initMemory(from: level.initialState.memoryValues, layout: level.memoryLayout, valuesOnly: false)
        initSpeed()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

