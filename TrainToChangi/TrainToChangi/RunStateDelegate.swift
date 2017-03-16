//
// Contains the run state of the game and the setter method for it.
//

protocol RunStateDelegate: class {
    var runState: RunState { get set }
}
