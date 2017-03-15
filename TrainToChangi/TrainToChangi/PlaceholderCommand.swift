//
// A placeholder command; upon execution, does nothing. Used by commands
// such as JumpCommand to signify the index to jump to.
//

class PlaceholderCommand: Command {
    override init() {}

    override func execute() -> CommandResult {
        return CommandResult()
    }
}
