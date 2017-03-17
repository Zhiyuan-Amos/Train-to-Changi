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
        let commands = CommandTypeParser().parse(model.currentCommands)

        while model.runState == .running {
            let command = commands[model.commandIndex!]
            let commandResult = command.execute(on: model)

            command is PlaceholderCommand ?
                postExecutionModelUpdate(isIncrementStepCount: false) :
                postExecutionModelUpdate(isIncrementStepCount: true)

            updater.updateRunState(commandResult: commandResult)
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

    // Helper function
    private func postExecutionModelUpdate(isIncrementStepCount: Bool) {
        model.commandIndex! += 1
        if isIncrementStepCount {
            model.numSteps += 1
        }
    }
}
