//
// The command that causes the `Person` to retrieve the first item from the 
// input conveyor belt.
//

class InputCommand: Command {
    override func execute() -> CommandResult {
        do {
            try model.dequeueValueFromInbox()
        } catch ModelError.emptyStack {
            return CommandResult(errorMessage: .emptyStack)
        } catch {
            fatalError("Should not happen")
        }

        return CommandResult(errorMessage: nil)
    }
}
