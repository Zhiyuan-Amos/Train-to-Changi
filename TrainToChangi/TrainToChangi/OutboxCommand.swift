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
            return .failure(error: .invalidOperation)
        }

        prevValueOnPerson = value
        model.updateValueOnPerson(to: nil)
        model.appendValueIntoOutbox(value)

        return .success(isJump: false)
    }

    func undo() {
        guard let value = prevValueOnPerson else {
            fatalError("Person must have a prior value to undo this command")
        }

        model.popValueFromOutbox()
        model.updateValueOnPerson(to: value)
    }
}
