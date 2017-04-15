//
// The command that causes the `programCounter` to point to the corresponding `jumpTarget`
// if the value of the payload that `Person` is currently holding is negative.
//
class JumpIfNegativeCommand: Command {
    private unowned let programCounter: CommandDataListCounter
    private unowned let model: Model

    init(model: Model, programCounter: CommandDataListCounter) {
        self.programCounter = programCounter
        self.model = model
    }

    func execute() -> CommandResult {
        guard let personValue = model.getValueOnPerson() else {
            return .failure(error: .invalidOperation)
        }
        if personValue < 0 {
            programCounter.jump()
            return .success(isJump: true)
        }
        return .success(isJump: false)
    }

    func undo() {}
}
