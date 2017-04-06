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
    fileprivate var hasPaused = false // Reflects the run state, not the scene state

    fileprivate var level: Level! // implicit unwrap because scene can't recover from a nil `level`

    fileprivate let player = SKSpriteNode(imageNamed: "player")
    fileprivate var playerPreviousPositions = Stack<CGPoint>()
    fileprivate var playerPickupPosition: CGPoint {
        return CGPoint(x: player.position.x,
                       y: player.position.y - Constants.Player.pickupOffsetY)
    }

    fileprivate let inbox = SKSpriteNode(imageNamed: "conveyor-belt-1")
    fileprivate let outbox = SKSpriteNode(imageNamed: "conveyor-belt-1")

    fileprivate var inboxNodes = [SKSpriteNode]()
    fileprivate var memoryNodes = [MemorySlot]()
    fileprivate var outboxNodes = [SKSpriteNode]()
    fileprivate var holdingNode = SKSpriteNode()
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
        inboxNodes.forEach { inboxNode in inboxNode.removeFromParent() }
        inboxNodes.removeAll()
        outboxNodes.forEach { outboxNode in outboxNode.removeFromParent() }
        outboxNodes.removeAll()
        memoryNodes.forEach { memoryNode in memoryNode.removeFromParent() }
        memoryNodes.removeAll()
        player.removeAllChildren()
        if let levelState = levelState { // game in .stepping state
            initConveyorNodes(inboxValues: levelState.inputs, outboxValues: levelState.outputs)
            guard let memoryLayout = memoryLayout else {
                // `memoryLayout` should already be initialized, else this func is called wrongly
                assertionFailure("Can't re-presenting scene with intermediate state when scene is not initialized")
                return
            }
            initMemory(from: levelState.memoryValues, layout: memoryLayout)
            let position = playerPreviousPositions.pop()
            setPlayerAttributes(position: position, payloadValue: levelState.personValue)
        } else { // game start from the beginning
            initConveyorNodes(inboxValues: level.initialState.inputs)
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
        if let position = position {
            player.position = position
            if let payloadValue = payloadValue {
                holdingNode = Payload(position: playerPickupPosition, value: payloadValue)
                addChild(holdingNode)
                holdingNode.move(toParent: player)
            }
        } else {
            player.position = Constants.Player.position
        }
        player.zPosition = Constants.Player.zPosition
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

    }

    fileprivate func initMemory(from memoryValues: [Int?], layout: Memory.Layout) {
        self.memoryLayout = layout
        for (index, _) in memoryValues.enumerated() {
            guard layout.locations.count == memoryValues.count else {
                fatalError("[GameScene:initMemory] " +
                    "Number of memory values differ from the layout specified. Check level data.")
            }
            let node = MemorySlot(index: index, layout: layout)
            addChild(node)
            memoryNodes.append(node)

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
}

// MARK: - Touch
extension GameScene: GameVCTouchDelegate {

    // Accepts a CGPoint and returns the index of memory if the touch is inside the memory grid.
    // Returns nil if `userTouchedPoint` is outside the grid.
    func memoryIndex(at userTouchedPoint: CGPoint) -> Int? {
        guard let centers = memoryLayout?.locations else {
            fatalError("[GameScene:memoryIndex] memoryLayout has not been initialized")
        }

        // there have to be at least one memory location to detect
        guard centers.count > 0 else {
            return nil
        }

        // calculate distance between `point` and each memory center, return the one with the min distance
        let distancesToPoint: [CGFloat] = memoryNodes.map { $0.position.distance(to: userTouchedPoint) }
        return distancesToPoint.index(of: distancesToPoint.min()!)
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

        hasPaused = false
        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationBegan,
                                                     object: nil, userInfo: nil))
        move(to: destination)
        //TODO: animation duration cannot be hardcoded
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            // this check is necessary or after 2 sec the notification will be posted when it shouldn't
            guard !self.hasPaused else { return }
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationEnded,
                                                         object: nil, userInfo: nil))
        })
    }

    @objc fileprivate func handleResetScene(notification: Notification) {
        removeAllAnimations()
        if let levelState = notification.object as? LevelState {
            rePresentDynamicElements(levelState: levelState)
        } else {
            rePresentDynamicElements()
        }
    }
}

// MARK: - Animations
extension GameScene {

    fileprivate func removeAllAnimations() {
        hasPaused = true
        player.removeAllActions()
        inboxNodes.forEach { inboxNode in inboxNode.removeAllActions() }
        outboxNodes.forEach { outboxNode in outboxNode.removeAllActions() }
        memoryNodes.forEach { memoryNode in memoryNode.removeAllActions() }
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
                self.inboxNodes.forEach { node in self.moveConveyorBelt(node) }
                let inboxAnimation = SKAction.repeat(
                    SKAction.animate(with: Constants.Animation.conveyorBeltFrames,
                                     timePerFrame: Constants.Animation.conveyorBeltTimePerFrame,
                                     resize: false, restore: true),
                    count: Constants.Animation.conveyorBeltAnimationCount)
                self.inbox.run(inboxAnimation, withKey: Constants.Animation.outboxAnimationKey)
            })
        })
    }

    private func animateGoToMemory(_ layout: Memory.Layout, _ index: Int, _ action: Memory.Action) {
        guard index > 0 && index < memoryNodes.count else {
            fatalError("[GameScene:animateGoToMemory] Trying to access memory out of bound")
        }
        playerPreviousPositions.push(player.position)
        let moveAction = SKAction.move(to: layout.locations[index],
                                       duration: Constants.Animation.moveToMemoryDuration)
        player.run(moveAction, completion: {
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
        // 1. walk to outbox
        let moveAction = SKAction.move(to: WalkDestination.outbox.point,
                                       duration: Constants.Animation.moveToConveyorBeltDuration)
        player.run(moveAction, completion: {
            // 2. then, outbox items move left
            self.outboxNodes.forEach { node in self.moveConveyorBelt(node) }
            let outboxAnimation = SKAction.repeat(
                SKAction.animate(with: Constants.Animation.conveyorBeltFrames,
                                 timePerFrame: Constants.Animation.conveyorBeltTimePerFrame,
                                 resize: false, restore: true),
                count: Constants.Animation.conveyorBeltAnimationCount)
            self.outbox.run(outboxAnimation, withKey: Constants.Animation.outboxAnimationKey)
        })
        let wait = SKAction.wait(forDuration: Constants.Animation.moveToConveyorBeltDuration)
        player.run(wait, completion: {
            // 3. wait for outbox movements finish, put on outbox
            self.putToOutbox()
        })
    }

    // Player when at the location of a memory location, discards holding value, picks up box from memory
    // player should already move to necessary memory location
    private func getValueFromMemory(at index: Int) {
        let memory = memoryNodes[index]
        let throwPersonValue = SKAction.fadeOut(withDuration: Constants.Animation.discardHoldingValueDuration)
        let removeFromParent = SKAction.removeFromParent()

        holdingNode.run(SKAction.sequence([throwPersonValue, removeFromParent]), completion: {
            memory.move(toParent: self.player)
        })
    }

    // Player when at the location of a memory location, drops a duplicate of his holding value to memory
    // player should already move to necessary memory location
    private func putValueToMemory(to index: Int) {
        guard let copyOfHoldingValue = holdingNode.copy() as? SKSpriteNode else {
            fatalError("[GameScene:putDownToMemory] Can't make a copy of holding value")
        }

        let position = memoryNodes[index].position

        copyOfHoldingValue.move(toParent: scene!)
        let dropHoldingValue = SKAction.move(to: position, duration: Constants.Animation.holdingValueToMemoryDuration)
        copyOfHoldingValue.run(dropHoldingValue)
    }

    // Do animations for command like "add 0", add value in memory to the person value
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
