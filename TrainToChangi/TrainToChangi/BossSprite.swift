//
//  BossSprite.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 5/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

class BossSprite: SKSpriteNode {

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)

        var jediFrames = [SKTexture]()
        let jediAtlas = SKTextureAtlas(named: "jedi")
        for index in 1...4 {
            let textureName = "jedi_0\(index)"
            jediFrames.append(jediAtlas.textureNamed(textureName))
        }

        self.name = "Jedi"
        self.isUserInteractionEnabled = true
        let action = SKAction.repeatForever(SKAction.animate(with: jediFrames, timePerFrame: 0.5))
        self.run(action)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Hello")
    }
}
