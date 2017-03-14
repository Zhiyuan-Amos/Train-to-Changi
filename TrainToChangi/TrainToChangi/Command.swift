//
//
//

class Command {
    var model: Model

    init() {
        fatalError("subclass has to override method")
    }

    func execute() -> CommandResult {
        fatalError("subclass has to override method")
    }
}
