//
// A placeholder command; upon execution, does nothing. Used by commands
// such as JumpCommand to signify the index to jump to.
//

//TODO: Change name
class PlaceholderCommand: Command {
    func execute(on model: Model) -> CommandResult {
        return CommandResult()
    }
}
