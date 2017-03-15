//
// The command that causes the `Person` to retrieve the first item from the 
// input conveyor belt.
//

class InboxCommand: Command {
    override func execute() -> CommandResult {
        guard let value = model.dequeueValueFromInbox() else {
            return CommandResult(errorMessage: .emptyInbox)
        }

        model.updateValueOnPerson(to: value)

        return CommandResult()
    }
}
