//
// The command that causes the command execution pointer to jump to `targetIndex`.
//

class JumpCommand: Command {
    private let model: Model
    let targetIndex: Int
    var placeHolder: PlaceholderCommand?
    private(set) var programCounterIndex: Int?

    init(model: Model, targetIndex: Int) {
        self.model = model
        self.targetIndex = targetIndex
    }

    func execute() -> CommandResult {
        programCounterIndex = model.programCounter
        model.programCounter = targetIndex
        return CommandResult()
    }

    func undo() {
        guard model.programCounter != nil else {
            fatalError("Program Counter should not be nil when game is running")
        }

        model.programCounter! -= 1
        }

    }
}
