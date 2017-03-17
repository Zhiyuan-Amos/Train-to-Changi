//
// Abstract class following the Command-pattern. All commands must
// inherit from this class.
//

protocol Command {
    func execute(on model: Model) -> CommandResult
}
