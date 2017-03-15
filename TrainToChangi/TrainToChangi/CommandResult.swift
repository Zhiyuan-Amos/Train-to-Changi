//
// Class contaning the result of executing the command; whether execution is
// successful.
//

struct CommandResult {
    let errorMessage: Error?
    var isSuccessful: Bool {
        return errorMessage == nil
    }

    init(errorMessage: Error? = nil) {
        self.errorMessage = errorMessage
    }

    /**
     An enum of errors that can be thrown from ModelManager
     */
    enum Error {
        // Thrown when there are no inbox items remaining
        case emptyInbox

        // Thrown when person has no value
        case emptyPersonValue

        // Thrown when memory location to be accessed has no value
        case emptyMemoryLocation

        // Thrown when outbox value is wrong
        case wrongOutboxValue
    }
}
