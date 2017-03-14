//

class LoopCommand: Command {
    let loopTo: Int

    init(loopTo: Int) {
        self.loopTo = loopTo
    }

    override func execute() -> CommandResult {
        // edit pointer value
    }
}
