//
// Manages the logic required to update the model when commands are executed.
//

import Foundation
class LogicManager: Sequencer {
    unowned private let model: Model
    var commandIndex: Int

    init(model: Model) {
        self.model = model
        self.commandIndex = 0
    }

    // Executes the list of commands in `model.commands`.
    func executeCommands() {
        let commands = CommandTypeParser(sequencer: self).parse(model.currentCommands)

        while model.runState == .running {
            let command = commands[commandIndex]
            command.setModel(model)
            if !execute(command) {
                break
            }

            commandIndex += 1
        }
    }

    // Executes `command`. If execution succeeds, return true.
    private func execute(_ command: Command) -> Bool {
        let commandResult = command.execute()
        if !commandResult.isSuccessful {
            model.updateRunState(to: .lost)

            let errorMessage = commandResult.errorMessage!
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "gameLost"), object: errorMessage, userInfo: nil)
            return false
        }
        return true
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
