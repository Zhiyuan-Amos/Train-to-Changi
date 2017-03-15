//
// Manages the logic required to update the model when commands are executed.
//

import Foundation
class LogicManager {
    unowned private var model: Model

    init(model: Model) {
        self.model = model
    }

    // Executes the list of commands in `model.commands`.
    func executeCommands() {
        var commandIndex = 0
        //TODO: Clean up this after finishing up JumpCommand
        let commands = CommandTypeParser().parse(model.currentCommands)
        while model.runState == .running {
            let command = commands[commandIndex]
            command.setModel(model)
            let commandResult = commands[commandIndex].execute()
            if !commandResult.isSuccessful {
                model.updateRunState(to: .lost)

                let errorMessage = commandResult.errorMessage!
                NotificationCenter.default.post(name: Notification.Name(
                    rawValue: "gameLost"), object: errorMessage, userInfo: nil)
                break
            }

            commandIndex += 1
        }
    }

    // Reverts the state of the model by one command execution backward.
    func undo() {
        guard model.undo() else {
            fatalError("User should not be allowed to undo")
        }
    }

    // Reverts the state of the model by one command execution forward.
    func redo() {
        guard model.redo() else {
            fatalError("User should not be allowed to redo")
        }
    }
}
