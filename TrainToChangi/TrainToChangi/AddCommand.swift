//

import Foundation
class AddCommand: Command {
    let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    override func execute() -> CommandResult {
        guard let value = model.memory[memoryIndex] else {
            return CommandResult(result: .fail, errorMessage: .noMemoryValue)
        }

        guard model.person != nil else {
            return CommandResult(result: .fail, errorMessage: .noPersonValue)
        }

        model.person! += value
        return CommandResult(result: .success)
    }
}
