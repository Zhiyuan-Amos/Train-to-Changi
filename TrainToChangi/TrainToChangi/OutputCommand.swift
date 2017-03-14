//

import Foundation
class OutputCommand: Command {
    override func execute() -> CommandResult {
        return model.putValueIntoOutbox()
    }
}
