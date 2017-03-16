//
// The command that causes the `Person` to put the item that he is currently 
// holding, onto the output conveyor belt.
//

class OutboxCommand: Command {
    override init() {}

    override func execute() -> CommandResult {
        guard let value = model.getValueOnPerson() else {
            return CommandResult(errorMessage: .emptyPersonValue)
        }

        model.putValueIntoOutbox(value)

        return CommandResult()
    }
}
