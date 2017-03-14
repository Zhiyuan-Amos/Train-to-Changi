//

import Foundation
class AddCommand: Command {
    let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    override func execute() -> CommandResult {
        return model.addToPersonValue(from: memoryIndex)
    }
}
