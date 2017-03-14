//
// The command that causes the `Person` to store the item that he is currently holding
// on to the memory located at `memoryIndex`.
//

class CopyToCommand: Command {
    let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    override func execute() -> CommandResult {
        do {
            try model.putValueIntoMemory(location: memoryIndex)
        } catch ModelError.emptyPersonValue {
            return CommandResult(errorMessage: .emptyPersonValue)
        } catch {
            fatalError("Should not happen")
        }

        return CommandResult(errorMessage: nil)
    }
}
