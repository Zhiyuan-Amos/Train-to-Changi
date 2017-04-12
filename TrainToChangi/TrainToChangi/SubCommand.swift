//
// The command that causes the `Person` to subtract the value of the item located
// at the memory at `memoryIndex` from the value that he is currently holding on.
//

import Foundation

class SubCommand: Command {
    private let model: Model
    fileprivate let memoryIndex: Int
    private var prevValueOnPerson: Int?

    init(model: Model, memoryIndex: Int) {
        self.model = model
        self.memoryIndex = memoryIndex
    }

    func execute() -> CommandResult {
        guard let personValue = model.getValueOnPerson() else {
            return .failure(error: .invalidOperation)
        }

        prevValueOnPerson = personValue

        guard let memoryValue = model.getValueFromMemory(at: memoryIndex) else {
            return .failure(error: .invalidOperation)
        }

        model.updateValueOnPerson(to: personValue - memoryValue)

        return .success(isJump: false)
    }

    func undo() {
        guard let value = prevValueOnPerson else {
            fatalError("Person must have a prior value to undo this command")
        }

        model.updateValueOnPerson(to: value)
    }

}

extension SubCommand: MemoryCommand {
    var index: Int {
        return memoryIndex
    }
}
