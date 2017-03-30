//
//  CommandButtonsHelper.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 27/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class UIEntityHelper {

    static func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()

        let cellSnapshot: UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }

    static func generateArrowView(origin: CGPoint, height: CGFloat) -> UIImageView {
        let arrowSize = CGSize(width: Constants.UI.arrowWidth,
                               height: height)
        let arrowView = UIImageView()
        arrowView.image = UIImage(named: "arrownavy.png")
        arrowView.frame = CGRect(origin: origin, size: arrowSize)

        return arrowView
    }

    static func generateCommandUIButton(for commandType: CommandData,
                                        position: CGPoint, tag: Int) -> UIButton {
        let size = CGSize(width: getCommandButtonWidth(commandType),
                          height: Constants.UI.commandButtonHeight)
        let frame = CGRect(origin: position, size: size)
        let imagePath = commandType.toString() + ".png"

        let commandButton = UIButton(frame: frame)
        commandButton.setImage(UIImage(named: imagePath), for: UIControlState.normal)
        commandButton.tag = tag

        return commandButton
    }

    static func generateCommandUIImageView(for commandType: CommandData, position: CGPoint) -> UIImageView {
        let size = CGSize(width: getCommandButtonWidth(commandType),
                          height: Constants.UI.commandButtonHeight)
        let frame = CGRect(origin: position, size: size)
        let imagePath = commandType.toString() + ".png"

        let commandImageView = UIImageView(frame: frame)
        commandImageView.image = UIImage(named: imagePath)

        return commandImageView
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
