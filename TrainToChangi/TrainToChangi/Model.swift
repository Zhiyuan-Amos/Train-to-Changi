//
// Interface for `LogicManager` to work with `ModelManager`.
//
protocol Model {
    func getCurrentCommands() -> [Command]

    func undo() throws
    func redo() throws

    func getRunState() -> RunState
    func updateRunState(to newState: RunState)

    // Returns the dequeued value from inbox. If inbox is empty, returns nil.
    func dequeueValueFromInbox() -> Int?
    // Puts `value` onto outbox. Returns true if outbox value is the expected value.
    func putValueIntoOutbox(_ value: Int) -> Bool

    // Returns the value that the person is holding on to.
    // Returns nil if the person isn't holding onto any value.
    func getValueOnPerson() -> Int?
    // Updates the value of the person to `newValue`.
    func updateValueOnPerson(to newValue: Int?)

    // Returns the value that is stored in the memory located at `index`
    // If the memory location is empty, returns nil.
    func getValueFromMemory(at index: Int) -> Int?
    // Put `value` into memory located at `index`.
    func putValueIntoMemory(_ value: Int, at index: Int)
}
