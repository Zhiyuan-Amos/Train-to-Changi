//
// Manages the logic required to update the model when commands are executed.
// It also contains methods pertaining to the game logic.
//

class LogicManager {
    unowned private let model: Model
    private let updater: RunStateUpdater
    private var executedCommands: [Command]
    private var executedCommandsTailPointer: Int

    init(model: Model) {
        self.model = model
        self.updater = RunStateUpdater(runStateDelegate: model)
        self.executedCommands = [Command]()
        self.executedCommandsTailPointer = executedCommands.count - 1
    }

    // Executes the list of commands in `model.currentCommands`.
    func executeCommands() {
        model.commandIndex = 0
        let commands = CommandEnumParser().parse(model: model)
        // TODO: If 0 commands?
        while model.runState == .running {
            let command = commands[model.commandIndex!]
            let commandResult = command.execute()

            executedCommands.append(command)
            executedCommandsTailPointer += 1

            model.commandIndex! += 1
            updater.updateRunState(commandResult: commandResult)
            if model.runState == .won {
                updateNumStepsTaken()
            }
        }
    }

    // Reverts the state of the model by one command execution backward.
    // Returns true if there are still commands to be undone.
    func undo() -> Bool {
        guard executedCommandsTailPointer >= 0 else {
            fatalError("User should not be allowed to redo")
        }

        let command = executedCommands[executedCommandsTailPointer]
        command.undo()
        executedCommandsTailPointer -= 1

        model.commandIndex! -= 1

        return executedCommandsTailPointer >= 0
    }

    // Reverts the state of the model by one command execution forward.
    // Returns true if there are still commands to be redone.
    func redo() -> Bool {
        guard executedCommandsTailPointer < executedCommands.count - 1 else {
            fatalError("User should not be allowed to redo")
        }

        let command = executedCommands[executedCommandsTailPointer]
        _ = command.execute()
        executedCommandsTailPointer += 1

        model.commandIndex! += 1

        return executedCommandsTailPointer < executedCommands.count - 1
    }

    private func updateNumStepsTaken() {
        let placeHolderCommandsCount = executedCommands.filter { command in command is PlaceholderCommand }.count
        model.numSteps = executedCommands.count - placeHolderCommandsCount
    }
}
