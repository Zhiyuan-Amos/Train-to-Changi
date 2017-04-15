//
// Created by zhongwei zhang on 4/15/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

// MARK: - Init
/// This extension includes methods that are used to initialize elements in `GameScene`,
/// or used to later re-initialize elements during gameplay.
extension GameScene {

    // Dynamic elements include `player` position, `player` value,
    // `payload`s on the inbox and outbox belt and on memory.
    // This method is called when scene is changed abruptly, by buttons "Stop", "Step backward".
    // Pass `levelState` to specify the locations of each sprite. If it's nil then re init from start.
    // Static elements are not refreshed again.
    func rePresentDynamicElements(levelState: LevelState? = nil) {
        player.removeAllChildren()
        enumerateChildNodes(withName: Constants.Payload.imageName, using: { node, _ in
            node.removeFromParent()
        })
        if let levelState = levelState { // stepBack button pressed
            initConveyorNodes(inboxValues: levelState.inputs, outboxValues: levelState.outputs)
            guard let memoryLayout = memoryLayout else {
                // `memoryLayout` should already be initialized, else this func is called wrongly
                assertionFailure("Can't re-presenting scene with intermediate state when scene is not initialized")
                return
            }
            initMemory(from: levelState.memoryValues, layout: memoryLayout, valuesOnly: true)
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
            initMemory(from: level.initialState.memoryValues, layout: level.memoryLayout, valuesOnly: true)
            setPlayerAttributes()
        }
        speechBubble.isHidden = true
    }

    func initBackground() {
        let rows = Constants.Background.rows
        let columns = Constants.Background.columns
        let size = Constants.Background.size

        guard let tileSet = SKTileSet(named: Constants.Background.tileSet) else {
            fatalError("Ground Tiles Tile Set not found")
        }
        guard let bgTile = tileSet.tileGroups.first(
            where: { $0.name == Constants.Background.tileGroup }) else {
            fatalError("Grey Tiles definition not found")
        }

        backgroundTileMap = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows,
                                          tileSize: size, fillWith: bgTile)
        backgroundTileMap.position = CGPoint(x: view!.frame.midX, y: view!.frame.midY)
        addChild(backgroundTileMap)
    }

    func initJedi() {
        jedi = JediSprite(texture: Constants.Jedi.texture,
                          color: UIColor.white,
                          size: CGSize(width: Constants.Jedi.width, height: Constants.Jedi.height))
        jedi.position = CGPoint(x: Constants.Jedi.positionX, y: Constants.Jedi.positionY)

        speechBubble = SpeechBubbleSprite(text: "",
                                          size: CGSize(width: Constants.SpeechBubble.width,
                                                       height: Constants.SpeechBubble.height))
        speechBubble.position = CGPoint(x: Constants.SpeechBubble.positionX,
                                        y: Constants.SpeechBubble.positionY)

        addChild(jedi)
        addChild(speechBubble)
    }

    func initPlayer() {
        setPlayerAttributes()
        addChild(player)
    }

    func setPlayerAttributes(position: CGPoint? = nil, payloadValue: Int? = nil) {
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

    func initInbox(values: [Int]) {
        inbox.size = Constants.Inbox.size
        inbox.position = Constants.Inbox.position
        addChild(inbox)
        initConveyorNodes(inboxValues: values)
    }

    func initOutbox() {
        outbox.size = Constants.Outbox.size
        outbox.position = Constants.Outbox.position

        addChild(outbox)
    }

    func initNotification() {
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

    func initMemory(from memoryValues: [Int?], layout: Memory.Layout, valuesOnly: Bool) {
        self.memoryLayout = layout
        self.memoryNodes.removeAll(keepingCapacity: true)
        for (index, value) in memoryValues.enumerated() {
            guard layout.locations.count == memoryValues.count else {
                fatalError("[GameScene:initMemory] " +
                               "Number of memory values differ from the layout specified. Check level data.")
            }
            if !valuesOnly {
                let node = MemorySlot(index: index, layout: layout)
                addChild(node)
                memorySlots.append(node)
            }

            guard let value = value else {
                continue
            }
            let memorySprite = Payload(position: layout.locations[index], value: value)
            addChild(memorySprite)
            memoryNodes[index] = memorySprite
        }
    }

    func initConveyorNodes(inboxValues: [Int], outboxValues: [Int]? = nil) {
        inboxNodes = []

        for (index, value) in inboxValues.enumerated() {
            let position = calculatePayloadPositionOnConveyor(index: index, forInbox: true)
            let payload = Payload(position: position, value: value)
            inboxNodes.append(payload)
            self.addChild(payload)
        }

        guard let outboxValues = outboxValues else {
            return
        }

        outboxNodes = []

        for (index, value) in outboxValues.enumerated() {
            let position = calculatePayloadPositionOnConveyor(index: index, forInbox: false, outboxValues.count)
            let payload = Payload(position: position, value: value)
            outboxNodes.append(payload)
            self.addChild(payload)
        }
    }

    private func calculatePayloadPositionOnConveyor(index: Int, forInbox: Bool, _ outboxCount: Int? = nil) -> CGPoint {

        let imagePadding = forInbox ? Constants.Inbox.imagePadding : Constants.Outbox.imagePadding
        let offsetX = (Constants.Payload.size.width + imagePadding)
        let startingX = forInbox
            ? Constants.Inbox.payloadStartingX
            : Constants.Outbox.entryPosition.x - CGFloat(outboxCount! - 1) * offsetX

        let x = startingX + CGFloat(index) * offsetX
        let y = (forInbox ? inbox.position.y : outbox.position.y) + Constants.Payload.imageOffsetY

        return CGPoint(x: x, y: y)
    }

    func initSpeed() {
        let defaultSpeed = Constants.Animation.defaultSpeed
        player.speed = defaultSpeed
        inbox.speed = defaultSpeed
        outbox.speed = defaultSpeed
        inboxNodes.forEach({ $0.speed = defaultSpeed })
        outboxNodes.forEach({ $0.speed = defaultSpeed })
    }
}
