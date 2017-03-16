//
// The command that causes the `Person` to pick up the item from the memory located
// at `memoryIndex`.
//

class CopyFromCommand: Command {
    let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    override func execute() -> CommandResult {
        guard let value = model.getValueFromMemory(at: memoryIndex) else {
            return CommandResult(errorMessage: .emptyMemoryLocation)
        }

        model.updateValueOnPerson(to: value)

        return CommandResult()
    }
}
