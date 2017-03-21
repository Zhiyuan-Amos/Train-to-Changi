//
// A placeholder command; upon execution, does nothing. Used by commands
// such as JumpCommand to signify the index to jump to.
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
}
