//

class InputCommand: Command {
    override func execute() -> CommandResult {
        return model.dequeueValueFromInbox()
    }
}
