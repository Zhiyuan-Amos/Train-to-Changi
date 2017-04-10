//
//  SpeechBubbleSprite.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 5/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

class SpeechBubbleSprite: SKSpriteNode {

    fileprivate var label: SKLabelNode

    init(text: String, size: CGSize) {
        label = SKLabelNode(text: text)
        label.fontName = Constants.SpeechBubble.fontName
        label.fontSize = Constants.SpeechBubble.fontSize
        label.fontColor = Constants.SpeechBubble.fontColor
        label.position = CGPoint.zero

        super.init(texture: Constants.SpeechBubble.texture, color: UIColor.white, size: size)
        self.isUserInteractionEnabled = true
        self.isHidden = true
        self.zPosition = Constants.SpeechBubble.zPosition
        self.addChild(label)
        label.zPosition = zPosition

        registerObservers()
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

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRunStateUpdate(notification:)),
            name: Constants.NotificationNames.runStateUpdated, object: nil)

    }

    @objc fileprivate func handleToggleSpeech(notification: Notification) {
        self.isHidden = !self.isHidden
    }

    @objc fileprivate func handleRunStateUpdate(notification: Notification) {
        guard let newState = notification.object as? RunState else {
            return
        }

        switch newState {
        case .lost(let error):
            switch error {
            case .invalidOperation:
                label.text = "You are not allowed to \nexecute this command!"
            case .wrongOutboxValue:
                label.text = "The output is incorrect!"
            case .incompleteOutboxValues:
                label.text = "There should be more values!"
            }
            isHidden = false
        default:
            break
        }
    }
}
