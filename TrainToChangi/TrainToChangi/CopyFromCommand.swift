//

import Foundation
class CopyFromCommand: Command {
    let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    override func execute() -> CommandResult {
        return model.copyFromMemory(index: memoryIndex)
    }
}
