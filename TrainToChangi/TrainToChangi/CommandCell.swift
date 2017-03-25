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
                                    indexImageName: "mathindex.png", hidden: false)
        case .copyFrom(let index), .copyTo(let index):
            setCommandImageAndIndex(imageName: imagePath, index: index,
                                    indexImageName: "copyindex.png", hidden: false)
        case .inbox, .outbox, .jump(_), .jumpTargetPlaceholder:
            setCommandImageAndIndex(imageName: imagePath, index: nil,
                                    indexImageName: nil, hidden: true)
        }

    }

    private func setCommandImageAndIndex(imageName: String, index: Int?,
                                         indexImageName: String?, hidden: Bool) {
        commandImage.frame.size.height = Constants.UI.commandButtonHeight
        commandImage.image = UIImage(named: imageName)
        commandIndexButton.setTitle("\(index)", for: UIControlState.normal)
        if let indexImageName = indexImageName {
            commandIndexButton.setBackgroundImage(UIImage(named: indexImageName),
                                                  for: UIControlState.normal)
        }
        commandIndexButton.isHidden = hidden
    }

}
