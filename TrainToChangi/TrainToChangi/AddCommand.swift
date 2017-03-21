//
// The command that causes the `Person` to add the value of the item located
// at the memory at `memoryIndex` with the value that he is currently holding on.
//

class AddCommand: Command {
    private let model: Model
    private let memoryIndex: Int
    private var prevValueOnPerson: Int?

    init(model: Model, memoryIndex: Int) {
        self.model = model
        self.memoryIndex = memoryIndex
    }

    func execute() -> CommandResult {
        guard let personValue = model.getValueOnPerson() else {
            return CommandResult(errorMessage: .emptyPersonValue)
        }

        prevValueOnPerson = personValue

        guard let memoryValue = model.getValueFromMemory(at: memoryIndex) else {
            return CommandResult(errorMessage: .emptyMemoryLocation)
        }

        model.updateValueOnPerson(to: personValue + memoryValue)

        return CommandResult()
    }

    func undo() {
        guard let value = prevValueOnPerson else {
            fatalError("Person should have a value before it is able to execute this command")
        }

        model.updateValueOnPerson(to: value)
    }
}
