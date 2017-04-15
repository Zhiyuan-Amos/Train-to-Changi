//
// The command that causes the `programCounter` to point to the corresponding `jumpTarget`.
//

class JumpCommand: Command {
    private unowned let programCounter: CommandDataListCounter

    init(programCounter: CommandDataListCounter) {
        self.programCounter = programCounter
    }

    func execute() -> CommandResult {
        programCounter.jump()
        return .success(isJump: true)
    }

    func undo() {}
}
