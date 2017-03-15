//
// Interface for `LogicManager` to work with `ModelManager`.
//

protocol RunStateProtocol: class {
    var runState: RunState { get }
    func updateRunState(to newState: RunState)
}
