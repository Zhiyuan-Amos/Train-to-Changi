//
// An enum of errors that can be thrown while the game is executing the commands.
//

enum ExecutionError {
    // Thrown when preconditions to commands are not met
    case invalidOperation

    // Thrown when outbox value is wrong
    case wrongOutboxValue

    // Thrown when there are no more commands to be executed and game is not won
    case incompleteOutboxValues
}
