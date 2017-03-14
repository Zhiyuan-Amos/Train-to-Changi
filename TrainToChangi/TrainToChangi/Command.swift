//
// Abstract class following the Command-pattern. All commands must
// inherit from this class.
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
