//

struct CommandResult {
    let result: Result
    let errorMessage: Error?

    init(result: Result, errorMessage: Error? = nil) {
        self.result = result
        self.errorMessage = errorMessage
    }

    enum Result {
        case success, fail
    }

    enum Error {
        case noPersonValue, noMemoryValue, noInboxValue, wrongOutboxValue
    }
}
