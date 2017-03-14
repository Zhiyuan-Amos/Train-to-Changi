//
// The command that causes the `Person` to put the item that he is currently 
// holding, onto the output conveyor belt.
//

class OutputCommand: Command {
    override func execute() -> CommandResult {
        do {
            try model.putValueIntoOutbox()
        } catch ModelError.emptyPersonValue {
            return CommandResult(errorMessage: .emptyPersonValue)
        } catch {
            fatalError("Should not happen")
        }

        return CommandResult()
    }
}
