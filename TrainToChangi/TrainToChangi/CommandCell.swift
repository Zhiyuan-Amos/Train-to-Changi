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

    func setImageAndIndex(commandType: CommandEnum) {
        switch commandType {
        case .add(let index):
            setCommandImageAndIndex(imageName: "add.png", index: index,
                                    indexImageName: "mathIndex.png", hidden: false)
        case .copyFrom(let index):
            setCommandImageAndIndex(imageName: "copyfrom.png", index: index,
                                    indexImageName: "copyIndex.png", hidden: false)
        case .copyTo(let index):
            setCommandImageAndIndex(imageName: "copyto.png", index: index,
                                    indexImageName: "copyIndex.png", hidden: false)
        case .inbox:
            setCommandImageAndIndex(imageName: "inbox.png", index: nil,
                                    indexImageName: nil, hidden: true)
        case .jump(_):
            setCommandImageAndIndex(imageName: "jump.pmg", index: nil,
                                    indexImageName: nil, hidden: true)
        case .outbox:
            setCommandImageAndIndex(imageName: "outbox.png", index: nil,
                                    indexImageName: nil, hidden: true)
        case .placeholder:
            setCommandImageAndIndex(imageName: "jumptarget.png", index: nil,
                                    indexImageName: nil, hidden: true)
        }

    }

    private func setCommandImageAndIndex(imageName: String, index: Int?,
                                         indexImageName: String?, hidden: Bool) {
        commandImage.image = UIImage(named: imageName)
        commandIndexButton.setTitle("\(index)", for: UIControlState.normal)
        if let indexImageName = indexImageName {
            commandIndexButton.setBackgroundImage(UIImage(named: indexImageName),
                                                  for: UIControlState.normal)
        }
        commandIndexButton.isHidden = hidden
    }

}
