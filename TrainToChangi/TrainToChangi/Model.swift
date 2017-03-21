//
// Interface for `LogicManager` to work with `ModelManager`.
//


protocol Model {

    // Returns the current commands that the user has drag-and-dropped
    func getCurrentCommands() -> [CommandEnum]
    
    func getCurrentInput() -> [Int]

    func getCurrentOutput() -> [Int]

    func getExpectedOutput() -> [Int]

    func getCommandIndex() -> Int?
    func setCommandIndex(to newIndex: Int?)

    func getNumSteps() -> Int

    func insertCommand(atIndex: Int, commandEnum: CommandEnum)
    func removeCommand(fromIndex: Int)

    // Returns the dequeued value from inbox. If inbox is empty, returns nil.
    func dequeueValueFromInbox() -> Int?

    // Enqueues `value` into the top of inbox.
    func insertValueIntoInbox(_ value: Int, at index: Int)

    // Puts `value` onto outbox.
    func putValueIntoOutbox(_ value: Int)

    // Takes the last most inserted value out of outbox.
    func takeValueOutOfOutbox()

    // Returns the value that the person is holding on to.
    // Returns nil if the person isn't holding onto any value.
    func getValueOnPerson() -> Int?

    // Updates the value of the person to `newValue`.
    func updateValueOnPerson(to newValue: Int?)

    // Returns the value that is stored in the memory located at `index`
    // If the memory location is empty, returns nil.
    func getValueFromMemory(at index: Int) -> Int?

    // Put `value` into memory located at `index`.
    func putValueIntoMemory(_ value: Int?, at index: Int)
}
