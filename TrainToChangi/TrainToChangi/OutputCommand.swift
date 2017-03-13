//

class OutputCommand: Command {
    override func execute() {
        guard let value = model.person else {
            return // TODO: notify Error
        }
        model.outputConveyorBelt.append(value)
        model.person = nil
    }
}
