//
// The command that causes the `Person` to pick up the payload from the memory located
// at `memoryIndex`.
//

class CopyFromCommand: MemoryCommand {
    private unowned let model: Model
    let memoryIndex: Int
    private var prevValueOnPerson: Int?

    init(model: Model, memoryIndex: Int) {
        self.model = model
        self.memoryIndex = memoryIndex
    }

    func execute() -> CommandResult {
        prevValueOnPerson = model.getValueOnPerson()

        guard let value = model.getValueFromMemory(at: memoryIndex) else {
            return .failure(error: .invalidOperation)
        }

        model.updateValueOnPerson(to: value)

        return .success(isJump: false)
    }

    func undo() {
        model.updateValueOnPerson(to: prevValueOnPerson)
    }
}
