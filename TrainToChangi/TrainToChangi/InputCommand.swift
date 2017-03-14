//

class InputCommand: Command {
    override func execute() -> CommandResult {
        guard let value = model.inputConveyorBelt.dequeue() else {
            fatalError("Game should have ended by then")
        }

        model.person = value
        return CommandResult(result: .success)
    }
}
