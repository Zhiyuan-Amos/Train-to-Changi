//
// The command that causes the command execution pointer to jump to `targetIndex`.
// Representation invariant: `placeHolder.jumpCommand` must be a reference to self.
//

class JumpCommand: Command {
    private let model: Model
    weak var placeholder: PlaceholderCommand?
    //TODO: Remove indexes?
    // Yes, please :)
    let targetIndex: Int
    private(set) var programCounterIndex: Int?

    init(model: Model) {
        self.model = model
        self.targetIndex = -123456789
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
        guard let placeholder = placeholder else {
            fatalError("placeholder cannot be nil during execution")
        }
        guard placeholder.jumpCommand === self else {
            fatalError("Bijection requirement unmet")
        }
    }

}
