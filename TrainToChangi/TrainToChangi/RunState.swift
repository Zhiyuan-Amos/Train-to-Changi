// Represents the execution state of the Game Scene.
enum RunState {
    // default case when the game begins
    case start

    // case when the game is running commands consecutively. 
    // `isAnimating` is true only if the gameScene is animating.
    case running(isAnimating: Bool)

    // case when the game is only executing the upcoming command.
    // `isAnimating` is true only if the gameScene is animating.
    case stepping(isAnimating: Bool)

    // case when the game is lost. The reason of the game being lost is captured
    // in `error`.
    case lost(error: ExecutionError)

    // case when the game is won.
    case won

    // case when the game is paused, that is no commands are being executed.
    // Note that `start` is a special kind of `paused`.
    case paused
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
