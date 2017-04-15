//
// Interface for `Logic` component of the application.
//

protocol Logic {

    // Returns true if there are still commands to be undone
    var canUndo: Bool { get }

    // Runs the game by executing all the commands
    func run()

    // Executes the next command
    func stepForward()

    // Undo the previous executed command
    func stepBack()

    // Resets the game to the state it was at the start
    func resetPlayState()
}
