//
// Class contaning the result of executing the command; whether execution is
// successful.
//

struct CommandResult {
    let errorMessage: ModelError?
    var isSuccessful: Bool {
        return errorMessage == nil
    }

    init(errorMessage: ModelError? = nil) {
        self.errorMessage = errorMessage
    }
}
