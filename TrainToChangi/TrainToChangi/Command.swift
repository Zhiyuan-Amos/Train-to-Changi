//
// Abstract class following the Command-pattern. All commands must
// inherit from this class.
//

class Command {
    unowned private(set) var model: Model

    init() {
        fatalError("subclass has to override method")
    }

    func execute() -> CommandResult {
        fatalError("subclass has to override method")
    }

    func setModel(_ model: Model) {
        self.model = model
    }
}
