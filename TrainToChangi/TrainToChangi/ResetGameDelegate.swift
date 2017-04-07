// The View Controller implementing this delegate must be able to reset
// the game.
protocol ResetGameDelegate: class {
    // Resets the game.
    func resetGame(isAnimating: Bool)

    // Resets the game if certain UI elements are activated when the game is paused
    // or lost.
    func tryResetGame()
}
