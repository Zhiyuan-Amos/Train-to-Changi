//
// The command that causes the command execution pointer to jump to `targetIndex`.
//

class JumpCommand: Command {
    private let model: Model
    let targetIndex: Int
    var placeHolder: PlaceholderCommand?
    private var prevIndex: Int?

    init(model: Model, targetIndex: Int) {
        self.model = model
        self.targetIndex = targetIndex
    }

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
