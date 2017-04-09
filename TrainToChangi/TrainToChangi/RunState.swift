// Represents the execution state of the Game Scene.
enum RunState {
    case start
    case running(isAnimating: Bool)
    case lost(error: ExecutionError)
    case won
    case paused
    case stepping(isAnimating: Bool)
}

extension RunState: Equatable {
}

func == (lhs: RunState, rhs: RunState) -> Bool {
    switch (lhs, rhs) {
    case (let .lost(errorOne), let .lost(errorTwo)):
        return errorOne == errorTwo
    case (let .running(isAnimatingOne), let .running(isAnimatingTwo)),
         (let .stepping(isAnimatingOne), let .stepping(isAnimatingTwo)):
        return isAnimatingOne == isAnimatingTwo
    case (.won, .won), (.paused, .paused), (.start, .start):
        return true
    default:
        return false
    }
}
