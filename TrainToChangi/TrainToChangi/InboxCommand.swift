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
            return CommandResult(errorMessage: .emptyInbox)
        }

        model.updateValueOnPerson(to: value)

        return CommandResult()
    }

    func undo() {
        guard let value = model.getValueOnPerson() else {
            fatalError("Person should have a value when executing InboxCommand")
        }

        model.enqueueValueIntoInboxHead(value)
        model.updateValueOnPerson(to: prevValueOnPerson)
    }
}
