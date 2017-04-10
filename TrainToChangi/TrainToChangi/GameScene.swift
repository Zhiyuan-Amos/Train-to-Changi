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
    // works like a semaphore, except it doesn't pause the thread when value == 0
    fileprivate var suspendDispatch = 0

    fileprivate var level: Level! // implicit unwrap because scene can't recover from a nil `level`

    fileprivate let player = SKSpriteNode(imageNamed: "player")
    fileprivate var playerPreviousPositions = Stack<CGPoint>()

    fileprivate let inbox = SKSpriteNode(imageNamed: "conveyor-belt-1")
    fileprivate let outbox = SKSpriteNode(imageNamed: "conveyor-belt-1")

    fileprivate var inboxNodes = [Payload]()
    fileprivate var memoryNodes = [Int: Payload]()
    fileprivate var memorySlots = [MemorySlot]()
    fileprivate var outboxNodes = [Payload]()
    fileprivate var holdingNode: Payload?
    fileprivate var jedi: JediSprite
    fileprivate var speechBubble: SpeechBubbleSprite

    fileprivate var memoryLayout: Memory.Layout?

    fileprivate var backgroundTileMap: SKTileMapNode!

    init(_ level: Level, size: CGSize) {
        self.level = level

        jedi = JediSprite(texture: Constants.Jedi.texture,
                          color: UIColor.white,
                          size: CGSize(width: Constants.Jedi.width, height: Constants.Jedi.height))
        jedi.position = CGPoint(x: Constants.Jedi.positionX, y: Constants.Jedi.positionY)

        speechBubble = SpeechBubbleSprite(text: "",
                                          size: CGSize(width: Constants.SpeechBubble.width,
                                                       height: Constants.SpeechBubble.height))
        speechBubble.position = CGPoint(x: Constants.SpeechBubble.positionX,
                                        y: Constants.SpeechBubble.positionY)

        super.init(size: size)
    }

    override func didMove(to view: SKView) {
        initBackground()
        initPlayer()
        initInbox(values: level.initialState.inputs)
        initOutbox()
        initNotification()
        initMemory(from: level.initialState.memoryValues, layout: level.memoryLayout)
        initSpeed()

        addChild(jedi)
        addChild(speechBubble)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Init
extension GameScene {

    // Dynamic elements include `player` position, `player` value,
    // `payload`s on the inbox and outbox belt and on memory.
    // This method is called when scene is changed abruptly, by buttons "Stop", "Step backward".
    // Pass `levelState` to specify the locations of each sprite. If it's nil then re init from start.
    // Static elements are not refreshed again.
    func rePresentDynamicElements(levelState: LevelState? = nil) {
        inboxNodes.forEach { $0.removeFromParent() }
        inboxNodes.removeAll()
        outboxNodes.forEach { $0.removeFromParent() }
        outboxNodes.removeAll()
        memoryNodes.forEach { $1.removeFromParent() }
        memoryNodes.removeAll()
        player.removeAllChildren()
        if let levelState = levelState { // stepBack button pressed
            initConveyorNodes(inboxValues: levelState.inputs, outboxValues: levelState.outputs)
            guard let memoryLayout = memoryLayout else {
                // `memoryLayout` should already be initialized, else this func is called wrongly
                assertionFailure("Can't re-presenting scene with intermediate state when scene is not initialized")
                return
            }
            initMemory(from: levelState.memoryValues, layout: memoryLayout)
            let position = playerPreviousPositions.pop()
            if let p1 = position, let p2 = playerPreviousPositions.top {
                player.run(SKAction.rotate(toAngle: p2.absAngle(to: p1), duration: 0))
            } else {
                player.run(SKAction.rotate(toAngle: 0, duration: 0))
            }
            setPlayerAttributes(position: position, payloadValue: levelState.personValue)
        } else { // stop button pressed
            player.run(SKAction.rotate(toAngle: 0, duration: 0))
            playerPreviousPositions = Stack<CGPoint>()
            initConveyorNodes(inboxValues: level.initialState.inputs)
            initMemory(from: level.initialState.memoryValues, layout: level.memoryLayout)
            setPlayerAttributes()
        }
        speechBubble.isHidden = true
    }

    fileprivate func initBackground() {
        let rows = Constants.Background.rows
        let columns = Constants.Background.columns
        let size = Constants.Background.size

        guard let tileSet = SKTileSet(named: Constants.Background.tileSet) else {
            fatalError("Ground Tiles Tile Set not found")
        }
        guard let bgTile = tileSet.tileGroups.first(
            where: {$0.name == Constants.Background.tileGroup}) else {
                fatalError("Grey Tiles definition not found")
        }

        backgroundTileMap = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows,
                                          tileSize: size, fillWith: bgTile)
        backgroundTileMap.position = CGPoint(x: view!.frame.midX, y: view!.frame.midY)
        addChild(backgroundTileMap)
    }

    fileprivate func initPlayer() {
        setPlayerAttributes()
        addChild(player)
    }

    fileprivate func setPlayerAttributes(position: CGPoint? = nil, payloadValue: Int? = nil) {
        // - If position is nil, payloadValue must be nil as well. This is to set Player at the start of the game.
        // - When position is set, payloadValue should also be set (however payloadValue may be nil as the player
        //   may not hold anything).
        guard (position != nil) || (payloadValue == nil) else {
            assertionFailure("Can't specify payload value without specifying position")
            return
        }
        player.size = Constants.Player.size
        player.zPosition = Constants.Player.zPosition

        guard let position = position else {
            player.position = Constants.Player.position
            return
        }

        player.position = position

        guard let payloadValue = payloadValue else {
            return
        }

        let payload = Payload(position: position, value: payloadValue)
        holdingNode = payload
        addChild(payload)
        bootstrapPayload(payload)
    }

    fileprivate func initInbox(values: [Int]) {
        inbox.size = Constants.Inbox.size
        inbox.position = Constants.Inbox.position
        addChild(inbox)
        initConveyorNodes(inboxValues: values)
    }

    fileprivate func initOutbox() {
        outbox.size = Constants.Outbox.size
        outbox.position = Constants.Outbox.position

        addChild(outbox)
    }

    fileprivate func initNotification() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleMovePerson(notification:)),
            name: Constants.NotificationNames.movePersonInScene, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleResetScene(notification:)),
            name: Constants.NotificationNames.resetGameScene, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(updateNodesSpeed(notification:)),
            name: Constants.NotificationNames.sliderShifted, object: nil)
    }

    fileprivate func initMemory(from memoryValues: [Int?], layout: Memory.Layout) {
        self.memoryLayout = layout
        for (index, value) in memoryValues.enumerated() {
            guard layout.locations.count == memoryValues.count else {
                fatalError("[GameScene:initMemory] " +
                    "Number of memory values differ from the layout specified. Check level data.")
            }
            let node = MemorySlot(index: index, layout: layout)
            addChild(node)
            memorySlots.append(node)

            guard let value = value else { continue }
            let memorySprite = Payload(position: layout.locations[index], value: value)
            addChild(memorySprite)
            memoryNodes[index] = memorySprite
        }
    }

    fileprivate func initConveyorNodes(inboxValues: [Int], outboxValues: [Int]? = nil) {
        inboxNodes = []

        for (index, value) in inboxValues.enumerated() {
            let position = calculatePayloadPositionOnConveyor(index: index, forInbox: true)
            let payload = Payload(position: position, value: value)
            inboxNodes.append(payload)
            self.addChild(payload)
        }

        guard let outboxValues = outboxValues else { return }

        outboxNodes = []

        for (index, value) in outboxValues.enumerated() {
            let position = calculatePayloadPositionOnConveyor(index: index, forInbox: false)
            let payload = Payload(position: position, value: value)
            outboxNodes.append(payload)
            self.addChild(payload)
        }
    }

    fileprivate func calculatePayloadPositionOnConveyor(index: Int, forInbox: Bool) -> CGPoint {
        let startingX = forInbox ? Constants.Inbox.payloadStartingX : Constants.Outbox.entryPosition.x

        let imagePadding = forInbox ? Constants.Inbox.imagePadding : Constants.Outbox.imagePadding
        let offsetX = CGFloat(index) * (Constants.Payload.size.width + imagePadding)

        let x = forInbox ? startingX + offsetX : startingX - offsetX
        let y = (forInbox ? inbox.position.y : outbox.position.y) + Constants.Payload.imageOffsetY

        return CGPoint(x: x, y: y)
    }

    fileprivate func initSpeed() {
        let defaultSpeed = Constants.Animation.defaultSpeed
        player.speed = defaultSpeed
        inbox.speed = defaultSpeed
        outbox.speed = defaultSpeed
        inboxNodes.forEach({ $0.speed = defaultSpeed })
        outboxNodes.forEach({ $0.speed = defaultSpeed })
    }
}

// MARK: - Notification
extension GameScene {

    // Receive notification to control the game scene. Responds accordingly.
    // notification must contains `userInfo` with "destination" defined
    @objc fileprivate func handleMovePerson(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let destination = userInfo["destination"] as? WalkDestination else {
            fatalError("[GameScene:handleMovePerson] Notification not set up properly")
        }

        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationBegan,
                                                     object: nil, userInfo: nil))
        move(to: destination)
    }

    @objc fileprivate func handleResetScene(notification: Notification) {
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

    @objc fileprivate func updateNodesSpeed(notification: Notification) {
        guard let sliderValue = notification.userInfo?["sliderValue"] as? Float else {
            fatalError("Notification sender is not configured properly")
        }
        let resultantSpeed = CGFloat(sliderValue) * Constants.Animation.speedRange +
            Constants.Animation.defaultSpeed

        player.speed = resultantSpeed
        inbox.speed = resultantSpeed
        outbox.speed = resultantSpeed
        inboxNodes.forEach({ $0.speed = resultantSpeed })
        outboxNodes.forEach({ $0.speed = resultantSpeed })
    }
}

// MARK: - Animations
extension GameScene {

    func playJediGameWonAnimation() {
        self.jedi.playGameWonAnimation()
    }

    fileprivate func removeAllAnimations() {
        player.removeAllActions()
        inboxNodes.forEach { $0.removeAllActions() }
        outboxNodes.forEach { $0.removeAllActions() }
        memoryNodes.forEach { $1.removeAllActions() }
        jedi.removeAllActions()
    }

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
        playerPreviousPositions.push(player.position)

        // 1. rotate and move to inbox
        let destination = WalkDestination.inbox.point
        let rotate = SKAction.rotate(toAngle: player.position.absAngle(to: destination),
                                     duration: Constants.Animation.rotatePlayerDuration, shortestUnitArc: true)
        let move = SKAction.move(to: destination, duration: Constants.Animation.moveToConveyorBeltDuration)

        player.run(SKAction.sequence([rotate, move]), completion: {
            // 2. take payload from inbox, inbox payloads move along the conveyor
            self.grabFromInbox()
            self.inboxNodes.forEach { self.moveConveyorBelt($0) }
            let inboxAnimation = SKAction.repeat(
                SKAction.animate(with: Constants.Animation.conveyorBeltFrames,
                                 timePerFrame: Constants.Animation.conveyorBeltTimePerFrame,
                                 resize: false, restore: true),
                count: Constants.Animation.conveyorBeltAnimationCount)
            self.inbox.run(inboxAnimation, withKey: Constants.Animation.outboxAnimationKey)
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationEnded,
                                                         object: nil, userInfo: nil))
        })
    }

    private func animateGoToMemory(_ layout: Memory.Layout, _ index: Int, _ action: Memory.Action) {
        guard index >= 0 && index < layout.locations.count else {
            fatalError("[GameScene:animateGoToMemory] Trying to access memory out of bound")
        }
        if player.position != playerPreviousPositions.top! {
            playerPreviousPositions.push(player.position)
        }

        let destination = layout.locations[index] + Constants.Animation.moveToMemoryOffsetVector
        let rotate = SKAction.rotate(toAngle: player.position.absAngle(to: destination),
                                     duration: Constants.Animation.rotatePlayerDuration, shortestUnitArc: true)
        let move = SKAction.move(to: destination, duration: Constants.Animation.moveToMemoryDuration)

        player.run(SKAction.sequence([rotate, move]), completion: {
            // player already moved to memory location, perform memory actions
            switch action {
            case .get:
                self.getValueFromMemory(at: index)
            case .put:
                self.putValueToMemory(to: index)
            case let .compute(expected):
                self.computeWithMemory(index, expected: expected)
            }
        })
    }

    private func animateGoToOutbox() {
        playerPreviousPositions.push(player.position)

        let destination = WalkDestination.outbox.point
        let rotate = SKAction.rotate(toAngle: player.position.absAngle(to: destination),
                                     duration: Constants.Animation.rotatePlayerDuration, shortestUnitArc: true)
        let move = SKAction.move(to: destination, duration: Constants.Animation.moveToConveyorBeltDuration)

        player.run(SKAction.sequence([rotate, move]), completion: {
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationEnded,
                                                         object: nil, userInfo: nil))
        })

        self.outboxNodes.forEach { self.moveConveyorBelt($0) }
        let outboxAnimation = SKAction.repeat(
            SKAction.animate(with: Constants.Animation.conveyorBeltFrames,
                             timePerFrame: Constants.Animation.conveyorBeltTimePerFrame,
                             resize: false, restore: true),
            count: Constants.Animation.conveyorBeltAnimationCount)
        self.outbox.run(outboxAnimation, withKey: Constants.Animation.outboxAnimationKey)

        let wait = SKAction.wait(forDuration: Constants.Animation.moveToConveyorBeltDuration)
        player.run(wait, completion: {
            self.putToOutbox()
        })
    }

    // Player when at the location of a memory location, discards holding value, picks up box from memory
    // player should already move to necessary memory location
    private func getValueFromMemory(at index: Int) {
        guard let memory = memoryNodes[index] else {
            fatalError("memory at \(index) should not be nil")
        }

        // make a copy of the sprite already on memory, add the copy to scene, remove the existing sprite
        // and set holdingNode to the copy. Use `bootstrapPayload` to set the location of the copy and add
        // it as child of player
        let copy = memory.makeCopy()
        addChild(copy)
        self.player.removeAllChildren()
        self.holdingNode = copy
        bootstrapPayload(copy)
        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationEnded,
                                                     object: nil, userInfo: nil))
    }

    // Player when at the location of a memory location, drops a duplicate of his holding value to memory
    // player should already move to necessary memory location
    private func putValueToMemory(to index: Int) {
        guard let holdingNode = holdingNode else {
            fatalError("holdingNode can't be nil to put onto memory")
        }

        let position = memorySlots[index].position

        // make a copy of the holdingNode, retain a ref to the memory already on `index` if there's any
        // set the copy to memory, add to scene, remove the existing from scene if there's any
        let copyOfHoldingValue = holdingNode.makeCopy()
        let existing = memoryNodes[index]
        memoryNodes[index] = copyOfHoldingValue
        addChild(copyOfHoldingValue)

        // fixPosition because when shifting parent, the position gets reset
        let fixPosition = SKAction.move(to: player.position, duration: 0)
        let dropHoldingValue = SKAction.move(to: position, duration: Constants.Animation.holdingValueToMemoryDuration)
        copyOfHoldingValue.run(SKAction.sequence([fixPosition, dropHoldingValue]), completion: {
            existing?.removeFromParent()
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationEnded,
                                                         object: nil, userInfo: nil))
        })
    }

    // Do animations for command like "add 0", add value in memory to the person value
    private func computeWithMemory(_ index: Int, expected: Int) {
        guard let memory = memoryNodes[index], let layout = memoryLayout else {
            fatalError("memory at \(index) should not be nil")
        }

        guard let holdingNode = holdingNode else {
            fatalError("holdingNode can't be nil to compute with memory")
        }

        let copy = memory.makeCopy()
        addChild(copy)
        copy.zPosition = holdingNode.zPosition - 1

        let fixPosition = SKAction.move(to: layout.locations[index], duration: 0)
        let move = SKAction.move(to: player.position, duration: Constants.Animation.payloadOnToPlayerDuration)

        copy.run(SKAction.sequence([fixPosition, move]), completion: {
            holdingNode.setLabel(to: expected)
            self.removeChildren(in: [copy])
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationEnded,
                                                         object: nil, userInfo: nil))
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
        player.removeAllChildren()
        // remove from inbox queue and attach to player
        let firstPayload = self.inboxNodes.removeFirst()
        holdingNode = firstPayload
        bootstrapPayload(firstPayload)
    }

    private func putToOutbox() {
        guard let holdingNode = holdingNode else {
            fatalError("holdingNode can't be nil to put to outbox")
        }
        outboxNodes.append(holdingNode)
        holdingNode.move(toParent: scene!)
        holdingNode.run(SKAction.move(to: Constants.Outbox.entryPosition,
                                      duration: Constants.Animation.holdingToOutboxDuration))
        holdingNode.zPosition = player.zPosition - 1
    }

    // Move payload visually onto the player.
    fileprivate func bootstrapPayload(_ payload: Payload) {
        guard let holdingNode = holdingNode else {
            fatalError("holdingNode incorrectly configured")
        }
        payload.zPosition = player.zPosition + 1
        payload.run(SKAction.move(to: player.position, duration: Constants.Animation.payloadOnToPlayerDuration), completion: {
            // holdingNode can only be moved from scene to player here, after it has been shifted to player.position
            // somehow the .makeCopy() method can't set the position of the sprite copy,
            // so this manual update position is required
            holdingNode.move(toParent: self.player)
        })
    }
}
