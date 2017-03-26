//
// Created by zhongwei zhang on 3/26/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

// custom SKSpriteNode that represents the value that player needs to manipulate
class Payload: SKSpriteNode {
    private var value: Int

    init(position: CGPoint, value: Int) {
        self.value = value

        let texture = SKTexture(imageNamed: Constants.Payload.imageName)
        // this initializer is the only designated one
        super.init(texture: texture, color: UIColor.clear, size: Constants.Memory.size)
        self.size = Constants.Payload.size
        self.position = position
        self.zRotation = Constants.Payload.rotationAngle

        // label that shows the value on the payload
        let label = SKLabelNode(text: String(value))
        label.position.y += Constants.Payload.labelOffsetY
        label.fontName = Constants.Payload.fontName
        label.fontSize = Constants.Payload.fontSize
        label.fontColor = Constants.Payload.fontColor
        self.addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
