//
// The command that causes the iterator to point to the corresponding jumpTarget.
//

class JumpCommand: Command {
    private unowned let iterator: CommandDataListIterator

    init(iterator: CommandDataListIterator) {
        self.iterator = iterator
    }

    func execute() -> CommandResult {
        iterator.jump()
        return CommandResult()
    }

    func undo() {}
}
