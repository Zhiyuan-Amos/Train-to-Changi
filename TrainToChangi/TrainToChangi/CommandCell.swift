//
//  CommandCell.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 17/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class CommandCell: UICollectionViewCell {
    private var label: CommandLabel?

    override func prepareForReuse() {
        label?.text = nil
    }

    func setLabel(_ label: CommandLabel) {
        let frame =  CGRect(x: 0, y: 0, width: 100, height: 30)
        label.frame = frame
        self.label = label
        contentView.addSubview(label)
    }
}
