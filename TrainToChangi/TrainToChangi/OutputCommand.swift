//

import Foundation
class OutputCommand: Command {
    override func execute() -> CommandResult {
        guard let value = model.person else {
            return CommandResult(result: .fail, errorMessage: .noPersonValue)
        }

        model.outputConveyorBelt.append(value)
        model.person = nil
        
        return CommandResult(result: .success)
    }
}
