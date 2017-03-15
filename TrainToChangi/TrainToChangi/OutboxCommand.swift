//
// The command that causes the `Person` to put the item that he is currently 
// holding, onto the output conveyor belt.
//

class OutboxCommand: Command {
    override func execute() -> CommandResult {
        guard let value = model.getValueOnPerson() else {
            return CommandResult(errorMessage: .emptyPersonValue)
        }
        
        guard model.putValueIntoOutbox(value) else {
            return CommandResult(errorMessage: .wrongOutboxValue)
        }

        return CommandResult()
    }
}
