//
// The command that causes the command execution pointer to jump to `targetIndex`.
//

class JumpCommand: Command {
    let targetIndex: Int

    init(loopTo: Int) {
        self.targetIndex = loopTo
    }

    override func execute() -> CommandResult {
        return CommandResult()
        //TODO: edit pointer value
    }
}
