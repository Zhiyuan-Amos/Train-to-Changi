//
//  SpeechBubbleSprite.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 5/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

class SpeechBubbleSprite: SKSpriteNode {

    var text: String

    init(text: String, size: CGSize) {
        self.text = text
        super.init(texture: SKTexture(imageNamed: "speech"), color: UIColor.white, size: size)
        self.isUserInteractionEnabled = true

        let label = SKLabelNode(text: text)
        label.fontName = "HelveticaNeue-Bold"
        label.fontSize = 12
        label.position = CGPoint(x: 0, y: 0)
        label.fontColor = UIColor.black
        self.addChild(label)

        registerObservers()
        self.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK -- Event Handling
extension SpeechBubbleSprite {
    fileprivate func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleToggleSpeech(notification:)),
            name: Constants.NotificationNames.toggleSpeechEvent, object: nil)

    }

    @objc fileprivate func handleToggleSpeech(notification: Notification) {
        self.isHidden = !self.isHidden
    }
}
