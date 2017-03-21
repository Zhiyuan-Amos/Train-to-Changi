//
// Interface for `LogicManager` to work with `ModelManager`.
//
protocol Model: class, RunStateDelegate {
    var numSteps: Int { get set }

    // Returns the first value from inbox. If inbox is empty, returns nil.
    func dequeueValueFromInbox() -> Int?
    // Prepends `value` into inbox.
    func prependValueIntoInbox(_ value: Int)

    // Appends `value` onto outbox.
    func appendValueIntoOutbox(_ value: Int)
    // Removes the last most inserted value out of outbox.
    func popValueFromOutbox()

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
