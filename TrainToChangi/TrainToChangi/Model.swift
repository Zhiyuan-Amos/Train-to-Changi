//
// Interface for `LogicManager` to work with `ModelManager`.
//
protocol Model {

    func undo() throws
    func redo() throws
    func getRunState() -> RunState
    func updateRunState(to newState: RunState)

    func getCurrentCommands() -> [Command]
    func insertCommand(atIndex: Int, command: Command) throws
    func removeCommand(fromIndex: Int) throws
    func dequeueValueFromInbox() throws
    func putValueIntoOutbox() throws
    func getValueOnPerson() -> Int?
    func updateValueOnPerson(to newValue: Int?) throws

    func putValueIntoMemory(location: Int, value: Int) throws
    func getValueFromMemory(location: Int) throws
}
