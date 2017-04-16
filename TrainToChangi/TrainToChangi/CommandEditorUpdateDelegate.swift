//
//  CommandsEditorUpdateDelegate.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 11/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

/**
 *  View controllers that implement this delegate should
 *  have reference to the commands collection view.
 */
protocol CommandsEditorUpdateDelegate: class {

    // Add a new command into the commands collection view
    func addNewCommand(command: CommandData)

    // Remove all the commands in the collection view
    func resetCommands()
}
