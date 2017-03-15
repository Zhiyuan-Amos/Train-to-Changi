//
// The command that causes the command execution pointer to jump to `targetIndex`.
//

class JumpCommand: Command {
    let targetIndex: Int

    init(targetIndex: Int) {
        self.targetIndex = targetIndex
    }

    override func execute() -> CommandResult {
        return CommandResult()
        //TODO: edit pointer value
    }
}
