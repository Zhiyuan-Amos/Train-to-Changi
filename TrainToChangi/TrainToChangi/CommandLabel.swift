//
// Created by Yong Lin Han on 21/3/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class CommandLabel: UILabel {

    func updateText(commandEnum: CommandData) {
        switch commandEnum {
        case .add(let index):
            if index == nil {
                text = "add"
            } else {
                text = "add \(index)"
            }
        case .copyFrom(let index):
            if index == nil {
                text = "copyFrom"
            } else {
                text = "copyFrom \(index)"
            }
        case .copyTo(let index):
            if index == nil {
                text = "copyTo"
            } else {
                text = "copyTo \(index)"
            }
        case .inbox: text = "inbox"
        case .jump(let index):
            if index == nil {
                text = "jump"
            } else {
                text = "jump \(index)"
            }
        case .outbox: text = "outbox"
        case .placeholder: text = ""
        }
    }
}
