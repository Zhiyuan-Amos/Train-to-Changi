//
// Each jump command will have its corresponding `JumpTarget` as an indicator
// of where the program counter will jump to. As such, this command does nothing.
//

class JumpTarget: Command {
    func execute() -> CommandResult {
        return .success(isJump: false)
    }

    func undo() {}
}
