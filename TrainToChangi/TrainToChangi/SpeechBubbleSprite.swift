//
//  SpeechBubbleSprite.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 5/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

class SpeechBubbleSprite: SKSpriteNode {

    init(text: String, size: CGSize) {
        super.init(texture: Constants.SpeechBubble.texture, color: UIColor.white, size: size)
        self.isHidden = true
        self.zPosition = Constants.SpeechBubble.zPosition
        registerObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func addLabelNodes(longText: String) {
        let textArr = longText.characters.split{$0 == " "}.map(String.init)

        var text = ""
        var labelNodeIndex = 0

        for token in textArr {
            if text.characters.count < Constants.SpeechBubble.maxCharactersInLine {
                text += token + " "
            } else {
                self.addChild(makeLabelNode(text: text, labelNodeIndex: labelNodeIndex))
                text = token + " "
                labelNodeIndex += 1
            }
        }
        if (text.characters.count > 1) {
            self.addChild(makeLabelNode(text: text, labelNodeIndex: labelNodeIndex))
        }
    }

    private func makeLabelNode(text: String, labelNodeIndex: Int) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = Constants.SpeechBubble.fontName
        label.fontSize = Constants.SpeechBubble.fontSize
        label.fontColor = Constants.SpeechBubble.fontColor
        label.position = CGPoint(x: 0, y: 0 - CGFloat(labelNodeIndex) * Constants.SpeechBubble.labelHeight)
        label.zPosition = zPosition
        return label
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
        self.removeAllChildren()
        addLabelNodes(longText: "Siao liao lah. Train breakdown again.")
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
                self.removeAllChildren()
                addLabelNodes(longText: "You are not allowed to execute this command!")
            case .wrongOutboxValue:
                self.removeAllChildren()
                addLabelNodes(longText: "The output is incorrect!")
            case .incompleteOutboxValues:
                self.removeAllChildren()
                addLabelNodes(longText: "There should be more values!")
            }
            isHidden = false
        default:
            break
        }
    }
}
