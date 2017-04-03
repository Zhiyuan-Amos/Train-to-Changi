//
// Created by zhongwei zhang on 3/26/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

// Custom SKSpriteNode for the memory slots on the ground
class MemorySlot: SKSpriteNode {
    private var index: Int
    private var layout: Memory.Layout

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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getIndex() -> Int {
        return index
    }
}
