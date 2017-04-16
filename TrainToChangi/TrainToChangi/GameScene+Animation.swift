//
// Created by zhongwei zhang on 4/15/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

// MARK: - Animations
/// This extension includes methods that are used to do animations in GameScene.
extension GameScene {
    typealias CAN = Constants.Animation
    func playJediGameWonAnimation() {
        self.jedi.playGameWonAnimation()
    }

    func removeAllAnimations() {
        player.removeAllActions()
        inboxNodes.forEach { $0.removeAllActions() }
        outboxNodes.forEach { $0.removeAllActions() }
        memoryNodes.forEach { $1.removeAllActions() }
        jedi.removeAllActions()
    }

    // Move the player to a WalkDestination
    func move(to destination: WalkDestination) {
        switch destination {
        case .inbox:
            animateGoToInbox()
        case .outbox:
            animateGoToOutbox()
        case let .memory(layout, index, action):
            animateGoToMemory(layout, index, action)
        }
    }

    func updateSpeed(sliderValue: CGFloat) {
        let resultantSpeed = CGFloat(sliderValue) * Constants.Animation.speedRange +
            Constants.Animation.defaultSpeed

        player.speed = resultantSpeed
        inbox.speed = resultantSpeed
        outbox.speed = resultantSpeed
        inboxNodes.forEach({ $0.speed = resultantSpeed })
        outboxNodes.forEach({ $0.speed = resultantSpeed })
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

        })
        let duration = CAN.rotatePlayerDuration + CAN.moveToConveyorBeltDuration +
            CAN.conveyorBeltTimePerFrame * Double(CAN.conveyorBeltAnimationCount)
        let wait = SKAction.wait(forDuration: duration)
        player.run(wait, completion: {
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
            self.outboxNodes.forEach { self.moveConveyorBelt($0) }
            let outboxAnimation = SKAction.repeat(
                SKAction.animate(with: Constants.Animation.conveyorBeltFrames,
                                 timePerFrame: Constants.Animation.conveyorBeltTimePerFrame,
                                 resize: false, restore: true),
                count: Constants.Animation.conveyorBeltAnimationCount)
            self.outbox.run(outboxAnimation, withKey: Constants.Animation.outboxAnimationKey)

            self.putToOutbox()
        })

        let duration = CAN.rotatePlayerDuration + CAN.moveToConveyorBeltDuration +
            CAN.conveyorBeltTimePerFrame * Double(CAN.conveyorBeltAnimationCount) + CAN.payloadOnToPlayerDuration
        player.run(SKAction.wait(forDuration: duration), completion: {
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.animationEnded,
                                                         object: nil, userInfo: nil))
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
            holdingNode.setValue(to: expected)
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
    func bootstrapPayload(_ payload: Payload) {
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
