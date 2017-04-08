//
// The command that causes the `Person` to pick up the item from the memory located
// at `memoryIndex`.
//

class CopyFromCommand: Command {
    private let model: Model
    private let memoryIndex: Int
    private var prevValueOnPerson: Int?

    init(model: Model, memoryIndex: Int) {
        self.model = model
        self.memoryIndex = memoryIndex
    }

    func execute() -> CommandResult {
        prevValueOnPerson = model.getValueOnPerson()

        guard let value = model.getValueFromMemory(at: memoryIndex, forUndo: false) else {
            return CommandResult(errorMessage: .emptyMemoryLocation)
        }

        model.updateValueOnPerson(to: value)

        return CommandResult()
    }

    func undo() {
        model.updateValueOnPerson(to: prevValueOnPerson)
    }
}
