//

struct CommandResult {
    let errorMessage: Error?

    init(errorMessage: Error? = nil) {
        self.errorMessage = errorMessage
    }

    enum Error {
        case noPersonValue, noMemoryValue, noInboxValue, wrongOutboxValue
    }
}
