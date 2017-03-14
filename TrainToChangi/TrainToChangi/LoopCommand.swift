//

class LoopCommand: Command {
    let loopTo: Int

    init(loopTo: Int) {
        self.loopTo = loopTo
    }

    override func execute() -> CommandResult {
        return CommandResult(result: .success)
        //TODO: edit pointer value
    }
}
