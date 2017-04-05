//
// The command that causes the iterator to point to the corresponding jumpTarget.
//

class JumpTarget: Command {
    func execute() -> CommandResult {
        return CommandResult()
    }

    func undo() {}
}
