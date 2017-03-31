//
// The command that causes the `Person` to put the item that he is currently 
// holding, onto the output conveyor belt.
//

class OutboxCommand: Command {
    private let model: Model
    private var prevValueOnPerson: Int?

    init(model: Model) {
        self.model = model
    }

    func execute() -> CommandResult {
        guard let value = model.getValueOnPerson() else {
            return CommandResult(errorMessage: .emptyPersonValue)
        }

        prevValueOnPerson = value
        model.updateValueOnPerson(to: nil)
        model.appendValueIntoOutbox(value)

        return CommandResult()
    }

    func undo() {
        guard let value = prevValueOnPerson else {
            fatalError("Person must have a prior value to undo this command")
        }

        model.popValueFromOutbox()
        model.updateValueOnPerson(to: value)
    }
}
