//
// The command that causes the `Person` to retrieve the first payload from the 
// input conveyor belt.
//

class InboxCommand: Command {
    private unowned let model: Model
    private var prevValueOnPerson: Int?

    init(model: Model) {
        self.model = model
    }

    func execute() -> CommandResult {
        prevValueOnPerson = model.getValueOnPerson()

        guard let value = model.dequeueValueFromInbox() else {
            return .failure(error: .invalidOperation)
        }

        model.updateValueOnPerson(to: value)

        return .success(isJump: false)
    }

    func undo() {
        guard let value = model.getValueOnPerson() else {
            fatalError("Person must have a value to undo this command")
        }

        model.prependValueIntoInbox(value)
        model.updateValueOnPerson(to: prevValueOnPerson)
    }
}
