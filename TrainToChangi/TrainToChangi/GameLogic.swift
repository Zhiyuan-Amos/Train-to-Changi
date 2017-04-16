//
// Parses `CommandData` and does the execution and undoing of commands.
//

class GameLogic {
    unowned private let model: Model
    var parser: CommandDataParser!

    init(model: Model) {
        self.model = model
    }

    // Reverts the state of the model by one command execution backward.
    func stepBack(_ command: Command) {
        command.undo()
    }

    // Parses `commandData` and executes the corresponding command.
    // Returns nil if `commandData` is nil. Returns the executed command otherwise.
    func stepForward(commandData: CommandData?) -> (Command?, CommandResult?) {
        // If there's no `commandData` and game hasn't been won, it implies
        // that there are no commands left to be executed i.e game lost.
        guard let commandData = commandData else {
            return (nil, .failure(error: .incompleteOutboxValues))
        }

        let command = parser.parse(commandData: commandData)
        let commandResult = command.execute()

        return (command, commandResult)
    }
}
