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
        do {
            try model.getValueFromMemory(location: memoryIndex)
        } catch ModelError.emptyMemoryLocation {
            return CommandResult(errorMessage: .emptyMemoryLocation)
        } catch {
            fatalError("Should not happen")
        }

        return CommandResult(errorMessage: nil)
    }
}
