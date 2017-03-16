//
// An enum of errors that can be thrown while the game is executing the commands.
//

enum ExecutionError {
    // Thrown when there are no inbox items remaining
    case emptyInbox

    // Thrown when person has no value
    case emptyPersonValue

    // Thrown when memory location to be accessed has no value
    case emptyMemoryLocation

    // Thrown when outbox value is wrong
    case wrongOutboxValue

    // Thrown when there are no more commands to be executed and game is not won
    case incompleteOutboxValues
}
