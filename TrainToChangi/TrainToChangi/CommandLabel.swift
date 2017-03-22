//
// Created by Yong Lin Han on 21/3/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class CommandLabel: UILabel {

    func updateText(commandType: CommandType) {
        switch commandType {
        case .add(let index):
            text = index == nil ? "add" : "add \(index)"
        case .copyFrom(let index):
            text = index == nil ? "copyFrom" : "copyFrom \(index)"
        case .copyTo(let index):
            text = index == nil ? "copyTo" : "copyTo \(index)"
        case .inbox:
            text = "inbox"
        case .jump(let index):
            text = index == nil ? "jump" : "jump \(index)"
        case .outbox:
            text = "outbox"
        case .placeHolder:
            text = ""
        }
    }
}
