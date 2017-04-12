//
// Class contaning the result of executing the command; whether execution is
// successful.
//

enum CommandResult {
    case failure(error: ExecutionError)
    case success(isJump: Bool)
}
