//
//  Config.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 26/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

// User settings that can be changed by user in app.
struct Config {

    static var saveSlot = SaveSlot.one
    static var isSoundEnabled = true

    enum SaveSlot: String {
        case one = "SlotOne"
        case two = "SlotTwo"
        case three = "SlotThree"
    }
}
