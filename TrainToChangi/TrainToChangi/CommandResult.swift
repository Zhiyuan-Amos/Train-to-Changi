//
// Enum of the result of command execution
//

enum CommandResult {
    // case where the execution failed. Also captures what kind of error in `error`.
    case failure(error: ExecutionError)

    // case where the execution succeeded. Also captures whether the execution
    // is linear or whether it is a jump.
    case success(isJump: Bool)
}

extension CommandResult: Equatable {
}

func == (lhs: CommandResult, rhs: CommandResult) -> Bool {
    switch (lhs, rhs) {
    case (let .failure(errorOne), let .failure(errorTwo)):
        return errorOne == errorTwo
    case (let .success(isJumpOne), let .success(isJumpTwo)):
        return isJumpOne == isJumpTwo
    default:
        return false
    }
}
