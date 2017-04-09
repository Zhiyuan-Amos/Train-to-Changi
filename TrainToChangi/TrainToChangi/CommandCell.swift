//
//  CommandCell.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 17/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class CommandCell: UICollectionViewCell {

    private typealias Drawer = UIEntityDrawer

    func setup(command: CommandData) {
        for view in self.subviews {
            view.removeFromSuperview()
        }

        let buttonOrigin = CGPoint(x: 10, y: 0)
        let button = Drawer.drawCommandButton(command: command, origin: buttonOrigin,
                                              interactive: false)
        button.frame = self.convert(button.frame, to: self)
        self.addSubview(button)

        let labelOrigin = CGPoint(x: button.frame.width + 20, y: 0)
        guard let label = Drawer.drawCommandMemoryIndex(command: command, origin: labelOrigin) else {
            return
        }

        label.frame = self.convert(label.frame, to: self)
        self.addSubview(label)
    }

}
