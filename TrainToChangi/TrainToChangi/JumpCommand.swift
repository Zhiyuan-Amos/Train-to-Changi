//
// The command that causes the command execution pointer to jump to `targetIndex`.
//

class JumpCommand: Command {
    private let targetIndex: Int

    init(targetIndex: Int) {
        self.targetIndex = targetIndex
    }

    func execute(on model: Model) -> CommandResult {
        model.commandIndex = targetIndex
        return CommandResult()
    }
}
