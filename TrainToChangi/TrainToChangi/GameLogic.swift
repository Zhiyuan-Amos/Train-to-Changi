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
    // Returns nil if `commandData` is nil. Returns the executed command otherwise.
    // Updates `model.runState` accordingly as well.
    func stepForward(commandData: CommandData?) -> Command? {
        // If there's no `commandData` and game hasn't been won, it implies
        // that there are no commands left to be executed i.e game lost.
        guard let commandData = commandData else {
            model.runState = .lost(error: .incompleteOutboxValues)
            return nil
        }

        let command = parser.parse(commandData: commandData)
        let commandResult = command.execute()
        updater.updateRunState(commandResult: commandResult)
        if model.runState == .won {
            model.numSteps = gameLogicDelegate.numCommandsExecuted
        }

        return command
    }
}
