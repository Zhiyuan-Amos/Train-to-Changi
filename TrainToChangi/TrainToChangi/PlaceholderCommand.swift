//
// A placeholder (also a type of command); upon execution, does nothing. Used by
// JumpCommand to signify the index to jump to.
// Representation invariant: `jumpCommand.placeHolder` must be a reference to self.
//

//TODO: Change name and link with JumpCommand
class PlaceholderCommand: Command {
    private let model: Model
    weak var jumpCommand: JumpCommand?

    init(model: Model) {
        self.model = model
    }

    func execute() -> CommandResult {
        return CommandResult()
    }

    func undo() {
        guard let jumpCommand = jumpCommand, let index = jumpCommand.programCounterIndex else {
            fatalError("JumpCommandPlaceholder should have a paired JumpCommand, " +
                "and the JumpCommand should have an index.")
        }

        model.programCounter = index
    }

    private func _checkRep() {
        guard let jumpCommand = jumpCommand else {
            fatalError("jumpCommand cannot be nil during execution")
        }

        guard jumpCommand.placeholder === self else {
            fatalError("Bijection requirement unmet")
        }
    }

}
