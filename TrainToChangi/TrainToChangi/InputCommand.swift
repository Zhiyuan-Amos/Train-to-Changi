//

class InputCommand: Command {
    override func execute() {
        guard let value = model.inputConveyorBelt.dequeue() else {
            return
        }

        model.person = value
    }
}
