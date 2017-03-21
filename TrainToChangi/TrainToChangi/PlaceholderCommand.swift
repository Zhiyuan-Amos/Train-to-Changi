//
// A placeholder command; upon execution, does nothing. Used by commands
// such as JumpCommand to signify the index to jump to.
//

class PlaceholderCommand: Command {
    var jumpCommand: JumpCommand?

    func execute() -> CommandResult {
        return CommandResult()
    }

    func undo() {}
}
