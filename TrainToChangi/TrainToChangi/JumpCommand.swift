//
// The command that causes the command execution pointer to jump to `targetIndex`.
// Representation invariant: `placeHolder.jumpCommand` must be a reference to self.
//

class JumpCommand: Command {
    private let iterator: CommandDataListIterator

    init(iterator: CommandDataListIterator) {
        self.iterator = iterator
    }

    func execute() -> CommandResult {
        iterator.jump()
        return CommandResult()
    }

    func undo() {}
}
