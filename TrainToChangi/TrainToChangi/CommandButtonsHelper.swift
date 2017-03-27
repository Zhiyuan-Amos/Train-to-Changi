//
//  CommandButtonsHelper.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 27/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class CommandButtonHelper {

    static func generateCommandUIButton(for commandType: CommandData, position: CGPoint, tag: Int) -> UIButton {
        let currentCommandSize = CGSize(width: getCommandButtonWidth(commandType),
                                        height: Constants.UI.commandButtonHeight)

        let currentCommandFrame = CGRect(origin: position,
                                         size: currentCommandSize)

        let commandButton = UIButton(frame: currentCommandFrame)
        let imagePath = commandType.toString() + ".png"

        commandButton.setImage(UIImage(named: imagePath), for: UIControlState.normal)
        commandButton.tag = tag

        return commandButton
    }

    static func getCommandButtonWidth(_ commandType: CommandData) -> CGFloat {
        switch commandType {
        case .add(_), .jumpTarget:
            return Constants.UI.commandButtonWidthShort
        case .inbox, .outbox, .jump:
            return Constants.UI.commandButtonWidthMid
        case .copyTo(_), .copyFrom(_):
            return Constants.UI.commandButtonWidthLong
        }
    }

}
