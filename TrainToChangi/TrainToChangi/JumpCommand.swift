//
// The command that causes the command execution pointer to jump to `targetIndex`.
//

class JumpCommand: Command {
    private let model: Model
    private let targetIndex: Int
    private var prevIndex: Int?

    init(model: Model, targetIndex: Int) {
        self.model = model
        self.targetIndex = targetIndex
    }

    //TODO: Issue with jump command target index if put with more jump commands.
    func execute() -> CommandResult {
        prevIndex = model.commandIndex
        model.commandIndex = targetIndex
        return CommandResult()
    }

    func undo() {
        guard let index = prevIndex else {
            fatalError("JumpCommand must have an index for it to be executed")
        }

        model.commandIndex = index
    }
}
