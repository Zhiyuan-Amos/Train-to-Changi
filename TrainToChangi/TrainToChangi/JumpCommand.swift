//

class JumpCommand: Command {
    let targetIndex: Int

    init(loopTo: Int) {
        self.targetIndex = loopTo
    }

    override func execute() -> CommandResult {
        return CommandResult(errorMessage: nil)
        //TODO: edit pointer value
    }
}
