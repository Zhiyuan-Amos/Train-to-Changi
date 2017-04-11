//
// The command that causes the `Person` to store the item that he is currently holding
// on to the memory located at `memoryIndex`.
//

class CopyToCommand: Command {
    private let model: Model
    fileprivate let memoryIndex: Int
    private var prevValueOnMemory: Int?

    init(model: Model, memoryIndex: Int) {
        self.model = model
        self.memoryIndex = memoryIndex
    }

    func execute() -> CommandResult {
        prevValueOnMemory = model.getValueFromMemory(at: memoryIndex)

        guard let value = model.getValueOnPerson() else {
            return CommandResult(errorMessage: .invalidOperation)
        }

        model.putValueIntoMemory(value, at: memoryIndex)

        return CommandResult()
    }

    func undo() {
        model.putValueIntoMemory(prevValueOnMemory, at: memoryIndex)
    }
}

extension CopyToCommand: MemoryCommand {
    var index: Int {
        return memoryIndex
    }
}
