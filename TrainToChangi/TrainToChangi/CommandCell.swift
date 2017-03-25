//
//  CommandCell.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 17/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class CommandCell: UICollectionViewCell {

    @IBOutlet weak var commandImage: UIImageView!
    @IBOutlet weak var commandIndexButton: UIButton!

    func setImageAndIndex(commandType: CommandData) {
        let imagePath = commandType.toString() + ".png"
        switch commandType {
        case .add(let index):
            setCommandImageAndIndex(imageName: imagePath, index: index,
                                    indexImageName: "mathindex.png", width: Constants.UI.commandButtonWidthShort)
        case .copyFrom(let index), .copyTo(let index):
            setCommandImageAndIndex(imageName: imagePath, index: index,
                                    indexImageName: "copyindex.png", width: Constants.UI.commandButtonWidthLong)
        case .inbox, .outbox, .jump(_), .jumpTarget:
            setCommandImageAndIndex(imageName: imagePath, index: nil,
                                    indexImageName: nil, width: Constants.UI.commandButtonWidthMid)
        }

    }

    private func setCommandImageAndIndex(imageName: String, index: Int?,
                                         indexImageName: String?, width: CGFloat) {

        commandImage.frame.size.height = Constants.UI.commandButtonHeight
        commandImage.frame.size.width = width
        commandImage.image = UIImage(named: imageName)

        commandIndexButton.setTitle("\(index)", for: UIControlState.normal)
        if let indexImageName = indexImageName {
            commandIndexButton.setBackgroundImage(UIImage(named: indexImageName),
                                                  for: UIControlState.normal)
            commandIndexButton.frame.origin = CGPoint(x: commandImage.frame.maxX,
                                                y: commandImage.frame.minY + 5)
            commandIndexButton.isHidden = false
        } else {
            commandIndexButton.isHidden = true
        }

    }

}
