enum RunState {
    case running
    case lost(error: ExecutionError)
    case won
    case paused
    case stopped
}

extension RunState: Equatable {
}

func == (lhs: RunState, rhs: RunState) -> Bool {
    switch (lhs, rhs) {
    case (let .lost(errorOne), let .lost(errorTwo)):
        return errorOne == errorTwo
    default:
        return false
    }
}
