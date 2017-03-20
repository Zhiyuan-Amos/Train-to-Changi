//
// Contains the run state of the game.
// Also contains the necessary attributes which will be checked to determine
// the current run state.
//

protocol RunStateDelegate: class {
    var runState: RunState { get set }
    var currentCommands: [CommandEnum] { get }
    var currentOutput: [Int] { get }
    var expectedOutput: [Int] { get }
    var commandIndex: Int? { get set }
}
