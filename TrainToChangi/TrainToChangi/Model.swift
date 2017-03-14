//
// Interface for `LogicManager` to work with `ModelManager`.
//
protocol Model {
    func undo() throws
    func redo() throws

    func getRunState() -> RunState
    func updateRunState(to newState: RunState)

    func getCurrentCommands() -> [Command]

    func dequeueValueFromInbox() throws
    func putValueIntoOutbox() throws

    func getValueOnPerson() -> Int?
    func updateValueOnPerson(to newValue: Int?) throws
    func getValueFromMemoryWithoutTransfer(location: Int) -> Int?

    func putValueIntoMemory(location: Int) throws
    func getValueFromMemory(location: Int) throws
}
