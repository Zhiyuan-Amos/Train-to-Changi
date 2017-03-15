//
// Class contaning the result of executing the command; whether execution is
// successful.
//

struct CommandResult {
    let errorMessage: ExecutionError?
    var isSuccessful: Bool {
        return errorMessage == nil
    }

    init(errorMessage: ExecutionError? = nil) {
        self.errorMessage = errorMessage
    }
}
