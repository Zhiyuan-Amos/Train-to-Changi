//
// A placeholder command; upon execution, does nothing. Used by commands
// such as JumpCommand to signify the index to jump to.
//

//TODO: Change name and link with JumpCommand
class PlaceholderCommand: Command {
    func execute() -> CommandResult {
        return CommandResult()
    }

    func undo() {}
}
