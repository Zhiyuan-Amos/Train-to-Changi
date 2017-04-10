//
// The command that causes the `Person` to retrieve the first item from the 
// input conveyor belt.
//

class InboxCommand: Command {
    private let model: Model
    private var prevValueOnPerson: Int?

    init(model: Model) {
        self.model = model
    }

    func execute() -> CommandResult {
        prevValueOnPerson = model.getValueOnPerson()

        guard let value = model.dequeueValueFromInbox() else {
            return CommandResult(errorMessage: .invalidOperation)
        }

        model.updateValueOnPerson(to: value)

        return CommandResult()
    }

    func undo() {
        guard let value = model.getValueOnPerson() else {
            fatalError("Person must have a value to undo this command")
        }

        model.prependValueIntoInbox(value)
        model.updateValueOnPerson(to: prevValueOnPerson)
    }
}
