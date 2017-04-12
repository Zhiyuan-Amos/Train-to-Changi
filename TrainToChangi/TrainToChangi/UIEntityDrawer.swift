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
        cellSnapshot.layer.cornerRadius = Constants.UI.Snapshot.cornerRadius
        cellSnapshot.layer.shadowOffset = Constants.UI.Snapshot.shadowOffset
        cellSnapshot.layer.shadowRadius = Constants.UI.Snapshot.shadowRadius
        cellSnapshot.layer.shadowOpacity = Constants.UI.Snapshot.shadowOpacity
        return cellSnapshot
    }
}

// MARK: - Command Drawing Helper Functions
extension UIEntityDrawer {

    static func drawButton(title: String, backgroundColor: UIColor, width: CGFloat,
                           origin: CGPoint, interactive: Bool) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: UIControlState.normal)
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        button.backgroundColor = backgroundColor
        button.titleLabel?.font = Constants.UI.CommandButton.buttonTitleFont
        button.frame.origin = origin
        button.frame.size.width = width
        button.frame.size.height = Constants.UI.collectionCellHeight
        button.layer.cornerRadius = Constants.UI.CommandButton.cornerRadius
        button.isUserInteractionEnabled = interactive
        return button
    }

    static func drawMemoryIndex(index: Int, backgroundColor: UIColor, origin: CGPoint) -> UILabel {
        let memoryIndexLabel = UILabel()
        memoryIndexLabel.text = "\(index)"
        memoryIndexLabel.textColor = UIColor.black
        memoryIndexLabel.font = Constants.UI.CommandIndex.indexLabelFont
        memoryIndexLabel.backgroundColor = backgroundColor
        memoryIndexLabel.frame.origin = origin
        memoryIndexLabel.frame.size.width = Constants.UI.CommandIndex.indexLabelWidth
        memoryIndexLabel.frame.size.height = Constants.UI.collectionCellHeight
        memoryIndexLabel.clipsToBounds = true
        memoryIndexLabel.layer.cornerRadius = Constants.UI.CommandIndex.cornerRadius
        memoryIndexLabel.textAlignment = .center
        memoryIndexLabel.isUserInteractionEnabled = false
        return memoryIndexLabel
    }

    static func drawCommandMemoryIndex(command: CommandData, origin: CGPoint) -> UILabel? {
        switch command {
        case .copyFrom(let index), .copyTo(let index):
            return drawMemoryIndex(index: index, backgroundColor: Constants.UI.Colors.commandRed,
                                   origin: origin)
        case .add(let index), .sub(let index):
            return drawMemoryIndex(index: index, backgroundColor:  Constants.UI.Colors.commandOrange,
                                   origin: origin)
        default:
            return nil
        }
    }

    static func drawCommandButton(command: CommandData, origin: CGPoint,
                                  interactive: Bool) -> UIButton {
        switch command {
        case .inbox:
            return drawButton(title: "inbox", backgroundColor: Constants.UI.Colors.commandGreen,
                              width: Constants.UI.CommandButton.widthMid,
                              origin: origin, interactive: interactive)
        case .outbox:
            return drawButton(title: "outbox", backgroundColor: Constants.UI.Colors.commandGreen,
                              width: Constants.UI.CommandButton.widthMid,
                              origin: origin, interactive: interactive)
        case .copyFrom:
            return drawButton(title: "copyfrom", backgroundColor: Constants.UI.Colors.commandRed,
                              width: Constants.UI.CommandButton.widthLong,
                              origin: origin, interactive: interactive)
        case .copyTo:
            return drawButton(title: "copyto", backgroundColor: Constants.UI.Colors.commandRed,
                              width: Constants.UI.CommandButton.widthMid,
                              origin: origin, interactive: interactive)
        case .jump:
            return drawButton(title: "jump", backgroundColor: Constants.UI.Colors.commandBlue,
                              width: Constants.UI.CommandButton.widthShort,
                              origin: origin, interactive: interactive)
        case .jumpIfZero:
            return drawButton(title: "jumpifzero", backgroundColor: Constants.UI.Colors.commandBlue,
                              width: Constants.UI.CommandButton.widthShort,
                              origin: origin, interactive: interactive)
        case .jumpIfNegative:
            return drawButton(title: "jumpifnegative", backgroundColor: Constants.UI.Colors.commandBlue,
                              width: Constants.UI.CommandButton.widthShort,
                              origin: origin, interactive: interactive)
        case .jumpTarget:
            return drawButton(title: "", backgroundColor: Constants.UI.Colors.commandBlue,
                              width: Constants.UI.CommandButton.widthShort,
                              origin: origin, interactive: interactive)
        case .add:
            return drawButton(title: "add", backgroundColor:  Constants.UI.Colors.commandOrange,
                              width: Constants.UI.CommandButton.widthShort,
                              origin: origin, interactive: interactive)
        case .sub:
            return drawButton(title: "sub", backgroundColor:  Constants.UI.Colors.commandOrange,
                              width: Constants.UI.CommandButton.widthShort,
                              origin: origin, interactive: interactive)
        }
    }
}

// MARK: - Jump Arrow Drawing Helper Functions
extension UIEntityDrawer {
    static func drawJumpArrow(topIndexPath: IndexPath, bottomIndexPath: IndexPath,
                              reversed: Bool, arrowWidthIndex: Int) -> ArrowView {

        let origin = getArrowOrigin(at: topIndexPath)
        let height = getHeightBetweenIndexPaths(topIndexPath, bottomIndexPath)
        let width = Constants.UI.arrowView.arrowWidth * (1.0 + CGFloat(Float(arrowWidthIndex) / Constants.UI.arrowView.arrowIndexDivisor))

        return reversed ? generateReverseArrowView(origin: origin, height: height, width: width)
                        : generateArrowView(origin: origin, height: height, width: width)
    }

    static func getArrowOrigin(at indexPath: IndexPath) -> CGPoint {
        return CGPoint(Constants.UI.CommandButton.widthShort,
                       getMidYOfCell(at: indexPath))
    }

    static func getMidYOfCell(at indexPath: IndexPath) -> CGFloat {
        return (CGFloat(indexPath.item + 1)
             * (Constants.UI.collectionCellHeight + Constants.UI.minimumLineSpacingForSection))
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
