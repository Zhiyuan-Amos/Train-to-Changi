//
// Manages the logic required to update the model when commands are executed.
// It also contains methods pertaining to the game logic.
//

class LogicManager {
    unowned private let model: Model
    private let updater: RunStateUpdater

    init(model: Model) {
        self.model = model
        self.updater = RunStateUpdater(runStateDelegate: model)
    }

    // Executes the list of commands in `model.currentCommands`.
    func executeCommands() {
        model.commandIndex = 0
        let commands = CommandTypeParser(sequencer: model).parse(model.currentCommands)

        while model.runState == .running {
            let command = commands[model.commandIndex!]
            command.setModel(model)
            let commandResult = command.execute()

            model.commandIndex! += 1

            if !(command is PlaceholderCommand) {
                model.numSteps += 1
            }

            if hasMetWinCondition() {
                updater.update(to: .won, notificationIdentifer: "gameWon", error: nil)
            } else if !commandResult.isSuccessful {
                updater.update(to: .lost, notificationIdentifer: "gameLost",
                               error: commandResult.errorMessage!)
            } else if !isOutputValid() {
                updater.update(to: .lost, notificationIdentifer: "gameLost",
                               error: .wrongOutboxValue)
            } else if isIndexOutOfBounds(count: commands.count) {
                updater.update(to: .lost, notificationIdentifer: "gameLost",
                               error: .incompleteOutboxValues)
            }
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

    private func isIndexOutOfBounds(count: Int) -> Bool {
        guard model.commandIndex! >= 0 else {
            fatalError("commandIndex should never be smaller than 0")
        }
        return model.commandIndex! >= count
    }

    // Returns true if the current output equals the expected output.
    private func hasMetWinCondition() -> Bool {
        return model.currentOutput == model.expectedOutput
    }

    // Returns true if all the values currently in current output is
    // equal to the expected output. Return value of `true` does not equate to
    // win condition met, as maybe not all of values required have been put into
    // the `model`.
    private func isOutputValid() -> Bool {
        for (index, value) in model.currentOutput.enumerated() {
            if value != model.expectedOutput[index] {
                return false
            }
        }
        return true
    }
}
