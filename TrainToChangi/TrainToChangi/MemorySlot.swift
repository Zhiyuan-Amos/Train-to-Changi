//
// Created by zhongwei zhang on 3/26/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

// Custom SKSpriteNode for the memory slots on the ground
class MemorySlot: SKSpriteNode {
    private(set) var index: Int
    private var layout: Memory.Layout

    var isUpdatingCommandIndex = false

    init(index: Int, layout: Memory.Layout) {
        self.index = index
        self.layout = layout

        let texture = SKTexture(imageNamed: "memory")
        // this initializer is the only designated one
        super.init(texture: texture, color: UIColor.clear, size: Constants.Memory.size)
        self.name = "memory \(index)"
        self.position = layout.locations[index]

        // create label for the index
        let label = SKLabelNode(text: String(describing: index))
        label.position = CGPoint(x: label.position.x + Constants.Memory.labelOffsetX,
                                 y: label.position.y + Constants.Memory.labelOffsetY)
        label.fontSize = Constants.Memory.labelFontSize
        self.addChild(label)
        self.isUserInteractionEnabled = true
        registerObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isUpdatingCommandIndex {
            isUpdatingCommandIndex = false
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.userSelectedIndexEvent,
                                                         object: self.index, userInfo: nil))
        }
    }
}

// MARK -- Event Handling
extension MemorySlot {
    fileprivate func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleUpdateCommandIndex(notification:)),
            name: Constants.NotificationNames.updateCommandIndexEvent, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleCancelUpdateCommandIndex(notification:)),
            name: Constants.NotificationNames.cancelUpdateCommandIndexEvent, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleCancelUpdateCommandIndex(notification:)),
            name: Constants.NotificationNames.userSelectedIndexEvent, object: nil)
    }

    @objc fileprivate func handleUpdateCommandIndex(notification: Notification) {
        guard let index = notification.object as? Int else {
            fatalError("[GameScene:handleUpdateCommandIndex] notification object should be Int")
        }

        isUpdatingCommandIndex = true
        if self.index == index {
            self.texture = SKTexture(imageNamed: "memory-select")
        }
    }

    @objc fileprivate func handleCancelUpdateCommandIndex(notification: Notification) {
        guard let _ = notification.object as? Int else {
            fatalError("[GameScene:handleUpdateCommandIndex] notification object should be Int")
        }

        isUpdatingCommandIndex = false
        self.texture = SKTexture(imageNamed: "memory")
    }
}
