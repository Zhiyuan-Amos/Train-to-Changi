//

import Foundation
class CopyFromCommand: Command {
    let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    override func execute() -> CommandResult {
        guard let value = model.memory[memoryIndex] else {
            return CommandResult(result: .fail, errorMessage: .noMemoryValue)
        }

        model.person = value
        return CommandResult(result: .success)
    }
}
