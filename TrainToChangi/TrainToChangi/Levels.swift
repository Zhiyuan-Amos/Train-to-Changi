//
//  Levels.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 2/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

// This struct is separated from Storage because the data is not written to file/
// any other storage medium.
struct Levels {
    static let levelData: [LevelData] = [LevelOneData(),
                                         LevelTwoData(),
                                         LevelThreeData()]
}
