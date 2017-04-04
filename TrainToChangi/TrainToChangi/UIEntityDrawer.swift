//
//  CommandButtonsHelper.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 27/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class UIEntityDrawer {

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

    static func generateCommandUIButton(for commandType: CommandData,
                                        position: CGPoint, tag: Int) -> UIButton {
        let size = CGSize(width: getCommandButtonWidth(commandType),
                          height: Constants.UI.collectionCellHeight)
        let frame = CGRect(origin: position, size: size)
        let imagePath = commandType.toFilePath() + ".png"

        let commandButton = UIButton(frame: frame)
        commandButton.setBackgroundImage(UIImage(named: imagePath), for: UIControlState.normal)
        commandButton.tag = tag

        return commandButton
    }

    static func generateCommandUIImageView(for commandType: CommandData, position: CGPoint) -> UIImageView {
        let size = CGSize(width: getCommandButtonWidth(commandType),
                          height: Constants.UI.commandButtonHeight)
        let frame = CGRect(origin: position, size: size)
        let imagePath = commandType.toFilePath() + ".png"

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

    // MARK: - Jump Arrow Drawing Helper Functions
    static func drawJumpArrow(topIndexPath: IndexPath, bottomIndexPath: IndexPath,
                              reversed: Bool, arrowWidthIndex: Int) -> ArrowView {
        let origin = getArrowOrigin(at: topIndexPath)
        let height = getHeightBetweenIndexPaths(topIndexPath, bottomIndexPath)
        let width = Constants.UI.arrowView.arrowWidth * (1.0 + CGFloat(Float(arrowWidthIndex) / 10.0))

        return reversed ? generateReverseArrowView(origin: origin, height: height, width: width)
                        : generateArrowView(origin: origin, height: height, width: width)
    }

    static func getArrowOrigin(at indexPath: IndexPath) -> CGPoint {
        return CGPoint(Constants.UI.collectionCellWidth,
                       getMidYOfCell(at: indexPath))
    }

    static func getMidYOfCell(at indexPath: IndexPath) -> CGFloat {
        return Constants.UI.topEdgeInset
            + (CGFloat(indexPath.item + 1) * Constants.UI.collectionCellHeight)
            - (0.5 * Constants.UI.collectionCellHeight)
    }

    static func getHeightBetweenIndexPaths(_ indexPathOne: IndexPath,
                                           _ indexPathTwo: IndexPath) -> CGFloat {
        return abs(getMidYOfCell(at: indexPathOne)
            - getMidYOfCell(at: indexPathTwo)) * 1.03

    }

    static func generateArrowView(origin: CGPoint, height: CGFloat, width: CGFloat) -> ArrowView {
        let arrowSize = CGSize(width: width,
                               height: height)

        let arrowView = ArrowView(frame: CGRect(origin: origin, size: arrowSize))
        return arrowView
    }

    static func generateReverseArrowView(origin: CGPoint, height: CGFloat, width: CGFloat) -> ArrowView {
        let arrowSize = CGSize(width: width,
                               height: height)

        let arrowView = ArrowView(frame: CGRect(origin: origin, size: arrowSize))
        let transfrom = CGAffineTransform(scaleX: 1, y: -1)
        arrowView.transform = transfrom
        return arrowView
    }
}
