//
//  SpeechBubbleSprite.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 5/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import SpriteKit

/**
 * Sprite for a Speech Bubble that contains labels with text
 */
class SpeechBubbleSprite: SKSpriteNode {

    init(size: CGSize) {
        super.init(texture: Constants.SpeechBubble.texture, color: UIColor.white, size: size)
        self.isHidden = true
        self.zPosition = Constants.SpeechBubble.zPosition
        registerObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Adds label nodes based on the length of the text 
    // on top of the SpeechBubble SKSpriteNode
    fileprivate func addLabelNodes(longText: String) {
        let textArr = longText.characters.split { $0 == " " }.map(String.init)

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

        // Prevents adding another node if the last node is able to contain
        // the remaining tokens
        if text.characters.count > 1 {
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
        addLabelNodes(longText: Constants.SpeechBubble.speechDefault)
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
                addLabelNodes(longText: Constants.SpeechBubble.speechInvalidOperation)

            case .wrongOutboxValue:
                self.removeAllChildren()
                addLabelNodes(longText: Constants.SpeechBubble.speechWrongOutput)

            case .incompleteOutboxValues:
                self.removeAllChildren()
                addLabelNodes(longText: Constants.SpeechBubble.speechIncompleteOutput)
            }

            isHidden = false

        default:
            break
        }
    }
}
