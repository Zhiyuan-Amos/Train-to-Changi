//

struct CommandResult {
    let result: Result
    let errorMessage: Error?
    let returnValue: Int?
    
    init(result: Result, errorMessage: Error? = nil, returnValue: Int? = nil) {
        self.result = result
        self.errorMessage = errorMessage
        self.returnValue = returnValue
    }
    
    enum Result {
        case success, fail
    }
    
    enum Error {
        case noPersonValue, noMemoryValue
    }
}
