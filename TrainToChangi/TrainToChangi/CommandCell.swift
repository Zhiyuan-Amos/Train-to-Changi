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
    @IBOutlet weak var commandIndex: UILabel!

    func setImageAndIndex(commandType: CommandData) {
        let imagePath = commandType.toString() + ".png"
        switch commandType {
        case .add(let index):
            setCommandImageAndIndex(imageName: imagePath, index: index,
                                    indexImageName: "mathindex.png",
                                    width: Constants.UI.commandButtonWidthShort)

        case .copyFrom(let index), .copyTo(let index):
            setCommandImageAndIndex(imageName: imagePath, index: index,
                                    indexImageName: "copyindex.png",
                                    width: Constants.UI.commandButtonWidthLong)

        case .inbox, .outbox, .jump(_), .jumpTarget:
            setCommandImageAndIndex(imageName: imagePath, index: nil,
                                    indexImageName: nil, width: Constants.UI.commandButtonWidthMid)
        }
    }

    private func setCommandImageAndIndex(imageName: String, index: Int?,
                                         indexImageName: String?, width: CGFloat) {

        commandImage.image = UIImage(named: imageName)

        if let indexImageName = indexImageName {
            commandIndex.text = "\(index)"
            commandIndex.isHidden = false
        } else {
            commandIndex.isHidden = true
        }
        commandIndex.isUserInteractionEnabled = false
    }

}
