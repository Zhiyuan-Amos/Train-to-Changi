//
// Interface for `LogicManager` to work with `ModelManager`.
//
protocol Model: class, RunStateDelegate, Sequencer {
    var currentCommands: [CommandType] { get }
    var currentOutput: [Int] { get }
    var expectedOutput: [Int] { get }
    var numSteps: Int { get set }

    // Reverts to the previous state. Returns true if operation is successful.
    func undo() -> Bool

    // Reverts to the next state. Returns true if operation is successful.
    func redo() -> Bool

    // Returns the dequeued value from inbox. If inbox is empty, returns nil.
    func dequeueValueFromInbox() -> Int?

    // Puts `value` onto outbox.
    func putValueIntoOutbox(_ value: Int)

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
