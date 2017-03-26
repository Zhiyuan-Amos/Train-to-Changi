//
// The command that causes the command execution pointer to jump to `targetIndex`.
// Representation invariant: `placeHolder.jumpCommand` must be a reference to self.
//

class JumpCommand: Command {
    private let iterator: CommandDataListIterator
    private var jumpFromIndex: Int?

    init(iterator: CommandDataListIterator) {
        self.iterator = iterator
    }

    func execute() -> CommandResult {
        jumpFromIndex = iterator.jump()
        return CommandResult()
    }

    func undo() {
        guard let jumpFromIndex = jumpFromIndex else {
            fatalError("Not a conditional jump: Must have jumped from an index")
        }
        iterator.moveIterator(to: jumpFromIndex)
    }
}
