//
//  JumpIfZeroCommand.swift
//  TrainToChangi
//
//  Created by Yong Lin Han on 12/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

// Jumps if currently holding a zero.
class JumpIfZeroCommand: Command {
    private unowned let iterator: CommandDataListIterator
    private let model: Model

    init(model: Model, iterator: CommandDataListIterator) {
        self.iterator = iterator
        self.model = model
    }

    func execute() -> CommandResult {
        guard let personValue = model.getValueOnPerson() else {
            return .failure(error: .invalidOperation)
        }
        if personValue == 0 {
            iterator.jump()
            return .success(isJump: true)
        }
        return .success(isJump: false)
    }

    func undo() {}
}
