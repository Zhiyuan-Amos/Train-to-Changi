//
//  BossSprite.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 5/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

/**
 * Sprite representing the passenger of the game
 */
class JediSprite: SKSpriteNode {

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.toggleSpeechEvent,
                                                     object: self.index, userInfo: nil))
    }

    func playGameWonAnimation() {
        let animationTextures = [SKTexture(imageNamed: "jedi_01"), SKTexture(imageNamed: "jedi_05")]
        let animation = SKAction.repeatForever(SKAction.animate(with: animationTextures, timePerFrame: 0.2))
        self.run(animation)
    }
}
