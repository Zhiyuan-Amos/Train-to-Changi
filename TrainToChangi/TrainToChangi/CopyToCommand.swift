//

import Foundation
class CopyToCommand: Command {
    let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    override func execute() -> CommandResult {
        guard let value = model.person else {
            return CommandResult(result: .fail, errorMessage: .noPersonValue)
        }

        model.memory[memoryIndex] = value
        return CommandResult(result: .success)
    }
}
