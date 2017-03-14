//
// Class contaning the result of executing the command; whether execution is
// successful.
//

struct CommandResult {
    // Execution is successful if errorMessage == nil. Otherwise, an error has occured.
    let errorMessage: Error?

    init(errorMessage: Error? = nil) {
        self.errorMessage = errorMessage
    }

    enum Error {
        case noPersonValue, noMemoryValue, noInboxValue, wrongOutboxValue
    }
}
