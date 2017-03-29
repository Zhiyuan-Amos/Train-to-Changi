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
    func undo(_ command: Command) {
        command.undo()
    }

    // Parses the `commandData` and executes the corresponding command.
    // Returns nil if `commandData` is nil or `commandData` cannot be parsed
    // into a Command e.g `.jumpTarget`. Returns true otherwise.
    func execute(commandData: CommandData?) -> Command? {
        guard let commandData = commandData else {
            model.runState = .lost(error: .incompleteOutboxValues)
            return nil
        }
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
