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
        return model.addToPersonValue(from: memoryIndex)
    }
}
