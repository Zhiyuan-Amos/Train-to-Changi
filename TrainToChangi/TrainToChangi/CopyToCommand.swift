//
// The command that causes the `Person` to store the payload that he is currently holding
// on to the memory located at `memoryIndex`.
//

class CopyToCommand: MemoryCommand {
    private unowned let model: Model
    let memoryIndex: Int
    private var prevValueOnMemory: Int?

    init(model: Model, memoryIndex: Int) {
        self.model = model
        self.memoryIndex = memoryIndex
    }

    func execute() -> CommandResult {
        prevValueOnMemory = model.getValueFromMemory(at: memoryIndex)

        guard let value = model.getValueOnPerson() else {
            return .failure(error: .invalidOperation)
        }

        model.putValueIntoMemory(value, at: memoryIndex)

        return .success(isJump: false)
    }

    func undo() {
        model.putValueIntoMemory(prevValueOnMemory, at: memoryIndex)
    }
}
