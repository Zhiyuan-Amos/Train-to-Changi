//
// The command that causes the `Person` to add the value of the item located
// at the memory at `memoryIndex` with the value that he is currently holding on.
//

class AddCommand: Command {
    let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    override func execute() -> CommandResult {
        guard let personValue = model.getValueOnPerson() else {
            return CommandResult(errorMessage: .emptyPersonValue)
        }

        guard let memoryValue = model.getValueFromMemoryWithoutTransfer(location: memoryIndex) else {
            return CommandResult(errorMessage: .emptyMemoryLocation)
        }

        do {
            try model.updateValueOnPerson(to: personValue + memoryValue)
        } catch {
            fatalError("Should not happen")
        }

        return CommandResult(errorMessage: nil)
    }
}
