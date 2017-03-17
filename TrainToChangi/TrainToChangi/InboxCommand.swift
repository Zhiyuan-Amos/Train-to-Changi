//
// The command that causes the `Person` to retrieve the first item from the 
// input conveyor belt.
//

class InboxCommand: Command {
    func execute(on model: Model) -> CommandResult {
        guard let value = model.dequeueValueFromInbox() else {
            return CommandResult(errorMessage: .emptyInbox)
        }

        model.updateValueOnPerson(to: value)

        return CommandResult()
    }
}
