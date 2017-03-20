//
// Contains the run state of the game.
// Also contains the necessary attributes which will be checked to determine
// the current run state.
//

protocol RunStateDelegate: class {
    var runState: RunState { get set }
    var commandEnums: [CommandEnum] { get }
    var currentInputs: [Int] { get }
    var currentOutputs: [Int] { get }
    var expectedOutputs: [Int] { get }
    var programCounter: Int? { get set }
}
