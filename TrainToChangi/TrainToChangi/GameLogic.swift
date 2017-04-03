protocol GameLogicDelegate: class {
    var numCommandsExecuted: Int { get }
}

class GameLogic {
    unowned private let model: Model
    var parser: CommandDataParser!
    private let updater: RunStateUpdater
    weak var gameLogicDelegate: GameLogicDelegate!

    init(model: Model) {
        self.model = model
        self.updater = RunStateUpdater(model: model)
    }

    // Reverts the state of the model by one command execution backward.
    func stepBack(_ command: Command) {
        command.undo()
    }

    // Parses the `commandData` and executes the corresponding command.
    // Returns nil if `commandData` is nil or `commandData` cannot be parsed
    // into a Command e.g `.jumpTarget`. Returns the executed command otherwise.
    // Updates `model.runState` accordingly as well.
    func stepForward(commandData: CommandData?) -> Command? {
        // If there's no `commandData` and game hasn't been won, it implies
        // that there are no commands left to be executed i.e game lost.
        guard let commandData = commandData else {
            model.runState = .lost(error: .incompleteOutboxValues)
            return nil
        }

        // Commands with animations will automatically toggle `model.runState`
        // from `.stepping` to `.paused`. However, `.jump` and `.jumpTarget` does not have
        // animation, thus we have to manually toggle it back to `.paused`.
        if (commandData == .jump || commandData == .jumpTarget) && model.runState == .stepping {
            model.runState = .paused
        }

        // Only `.jumpTarget` returns nil as it isn't a command.
        guard let command = parser.parse(commandData: commandData) else {
            return nil
        }

        let commandResult = command.execute()
        updater.updateRunState(commandResult: commandResult)
        if model.runState == .won {
            model.numSteps = gameLogicDelegate.numCommandsExecuted
        }

        return command
    }
}
