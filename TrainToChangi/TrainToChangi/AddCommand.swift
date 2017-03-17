//
// The command that causes the `Person` to add the value of the item located
// at the memory at `memoryIndex` with the value that he is currently holding on.
//

class AddCommand: Command {
    private let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    func execute(on model: Model) -> CommandResult {
        guard let personValue = model.getValueOnPerson() else {
            return CommandResult(errorMessage: .emptyPersonValue)
        }

        guard let memoryValue = model.getValueFromMemory(at: memoryIndex) else {
            return CommandResult(errorMessage: .emptyMemoryLocation)
        }

        model.updateValueOnPerson(to: personValue + memoryValue)

        return CommandResult()
    }
}
