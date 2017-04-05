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
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.toggleSpeechEvent,
                                                     object: self.index, userInfo: nil))
    }
}


