//
// The command that causes the iterator to point to the corresponding jumpTarget.
//

class JumpCommand: Command {
    private let iterator: CommandDataListIterator
    private var executionIndex: Int?

    init(iterator: CommandDataListIterator) {
        self.iterator = iterator
    }

    func execute() -> CommandResult {
        guard let index = iterator.index else {
            fatalError("Misconfiguration: The corresponding jump CommandData must"
                + " belong to an index in the list")
        }
        self.executionIndex = index

        iterator.jump()
        return CommandResult()
    }

    func undo() {
        guard let index = executionIndex else {
            fatalError("Missing assignment of executionIndex in execute()")
        }

        iterator.moveIterator(to: index)
    }
}
