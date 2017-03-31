//
//  Logic.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 22/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

protocol Logic: class {

    func executeCommands()

    func undo()

    func executeNextCommand()

}
