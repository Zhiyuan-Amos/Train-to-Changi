//
// The command that causes the `Person` to retrieve the first item from the 
// input conveyor belt.
//

class InputCommand: Command {
    override func execute() -> CommandResult {
        return model.dequeueValueFromInbox()
    }
}
