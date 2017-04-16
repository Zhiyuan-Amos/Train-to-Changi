//
//  CommandDataListInfo.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 30/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import Foundation

// Wrapper struct that contains all information needed to init a CommandDataList from storage.
struct CommandDataListInfo {
    let commandDataArray: [CommandData]
    let jumpMappings: [Int: Int]
}
