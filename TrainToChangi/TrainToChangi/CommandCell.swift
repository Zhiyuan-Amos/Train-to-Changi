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
            commandImage.image = UIImage(named: "add.png")
            commandIndexButton.setTitle("\(index)", for: UIControlState.normal)
            commandIndexButton.setBackgroundImage(UIImage(named: "mathIndex"),
                                                  for: UIControlState.normal)
            commandIndexButton.isHidden = false
        case .copyFrom(let index):
            commandImage.image = UIImage(named: "copyfrom.png")
            commandIndexButton.setTitle("\(index)", for: UIControlState.normal)
            commandIndexButton.setBackgroundImage(UIImage(named: "copyIndex"),
                                                  for: UIControlState.normal)
            commandIndexButton.isHidden = false
        case .copyTo(let index):
            commandImage.image = UIImage(named: "copyto.png")
            commandIndexButton.setTitle("\(index)", for: UIControlState.normal)
            commandIndexButton.setBackgroundImage(UIImage(named: "copyIndex"),
                                                  for: UIControlState.normal)
            commandIndexButton.isHidden = false
        case .inbox:
            commandImage.image = UIImage(named: "inbox.png")
            commandIndexButton.isHidden = true

        case .jump(_):
            commandImage.image = UIImage(named: "jump.png")
            commandIndexButton.isHidden = true

        case .outbox:
            commandImage.image = UIImage(named: "outbox.png")
            commandIndexButton.isHidden = true

        case .placeholder:
            commandImage.image = UIImage(named: "jumptarget.png")
            commandIndexButton.isHidden = true
        }

    }

}
