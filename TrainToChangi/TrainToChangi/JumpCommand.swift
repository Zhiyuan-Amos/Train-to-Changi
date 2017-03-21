//
// The command that causes the command execution pointer to jump to `targetIndex`.
// Representation invariant: `placeHolder.jumpCommand` must be a reference to self.
//

class JumpCommand: Command {
    private let model: Model
    weak var placeHolder: PlaceholderCommand?
    //TODO: Remove indexes?
    let targetIndex: Int
    private(set) var programCounterIndex: Int?

    init(model: Model, targetIndex: Int) {
        self.model = model
        self.targetIndex = targetIndex
    }

    func execute() -> CommandResult {
        _checkRep()

        programCounterIndex = model.programCounter
        model.programCounter = targetIndex

        _checkRep()
        return CommandResult()
    }

    func undo() {
        _checkRep()

        guard model.programCounter != nil else {
            fatalError("Program Counter should not be nil when game is running")
        }

        model.programCounter! -= 1
        _checkRep()
    }

    private func _checkRep() {
        guard let placeHolder = placeHolder else {
            fatalError("placeHolder cannot be nil during execution")
        }

        guard placeHolder.jumpCommand === self else {
            fatalError("Bijection requirement unmet")
        }
    }
}
