//

import Foundation
class CopyToCommand: Command {
    let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    override func execute() -> CommandResult {
        return model.copyToMemory(index: memoryIndex)
    }
}
