enum RunState {
    case running(isAnimating: Bool)
    case lost(error: ExecutionError)
    case won
    case paused
    case stepping
}

extension RunState: Equatable {
}

func == (lhs: RunState, rhs: RunState) -> Bool {
    switch (lhs, rhs) {
    case (let .lost(errorOne), let .lost(errorTwo)):
        return errorOne == errorTwo
    case (let .running(isAnimatingOne), let .running(isAnimatingTwo)):
        return isAnimatingOne == isAnimatingTwo
    case (.won, .won):
        return true
    case (.paused, .paused):
        return true
    case (.stepping, .stepping):
        return true
    default:
        return false
    }
}
