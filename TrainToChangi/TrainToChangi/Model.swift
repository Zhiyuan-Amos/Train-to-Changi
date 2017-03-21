//
// Interface for `Model` component of the application.
//

protocol Model: class {

    // MARK - Variables accessed by other components.

    // The Program Counter for player's program. Initially nil.
    var programCounter: Int? { get set }

    // The Game State. I guess we should rename this.
    var runState: RunState { get set }

    // Number of execution steps taken by user to complete the level.
    var numSteps: Int { get set }

    // The Commands that user has added.
    var userEnteredCommands: [CommandEnum] { get }

    // The current inputs left in the inbox area.
    var currentInputs: [Int] { get }

    // The current outputs placed in the outbox area.
    var currentOutputs: [Int] { get }

    // The expected outputs for the user to clear the level.
    var expectedOutputs: [Int] { get }

    // MARK - API for GameViewController.

    // Appends the command to userEnteredCommands.
    func addCommand(commandEnum: CommandEnum)

    // Inserts the command into userEnteredCommands, at specified Index.
    func insertCommand(commandEnum: CommandEnum, atIndex: Int)

    // Removes the command at specified Index from userEnteredCommands.
    func removeCommand(fromIndex: Int) -> CommandEnum

    // MARK - API for Logic. Notifies Scene upon execution.

    // Returns the dequeued value from inbox. If inbox is empty, returns nil.
    func dequeueValueFromInbox() -> Int?

    // Enqueues `value` into the top of inbox.
    func prependValueIntoInbox(_ value: Int)

    // Puts `value` onto outbox.
    func appendValueIntoOutbox(_ value: Int)

    // Takes the last most inserted value out of outbox.
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
