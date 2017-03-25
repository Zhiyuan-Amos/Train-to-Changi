//
// A placeholder (also a type of command); upon execution, does nothing. Used by
// JumpCommand to signify the index to jump to.
//

class JumpTarget: Command {
    init() {}

    func execute() -> CommandResult {
        return CommandResult()
    }

    func undo() {}
}
