//
// Class contaning the result of executing the command; whether execution is
// successful.
//

struct CommandResult {
    // Execution is successful if errorMessage == nil. Otherwise, an error has occured.
    let errorMessage: ModelError?

    init(errorMessage: ModelError? = nil) {
        self.errorMessage = errorMessage
    }
}
