//
// Interface for `Model` component of the application.
//

protocol Model: class {

    // MARK - Variables accessed by other components.

    // The gameplay run state.
    var runState: RunState { get set }

    // Number of execution steps taken by user to complete the level.
    var numSteps: Int { get set }

    // The Commands that user has added.
    var userEnteredCommands: [CommandData] { get }

    // The current inputs left in the inbox area.
    var currentInputs: [Int] { get }

    // The current outputs placed in the outbox area.
    var currentOutputs: [Int] { get }

    // The expected outputs for the user to clear the level.
    var expectedOutputs: [Int] { get }

    // The current level loaded in Model.
    var currentLevel: Level { get }

    // MARK - API for GameViewController.

    // Appends the command to userEnteredCommands.
    func addCommand(commandEnum: CommandData)

    // Inserts the command into userEnteredCommands, at specified Index.
    // If the command is .jump, adds a corresponding .jumpTarget.
    func insertCommand(commandEnum: CommandData, atIndex: Int)

    // Removes the command at specified Index from userEnteredCommands.
    // If the command is .jump or .jumpTarget, removes the corresponding
    // command in the pair.
    func removeCommand(fromIndex: Int) -> CommandData

    // Moves the command at `fromIndex` to `toIndex`.
    // When reordering, use this instead of removing and inserting since
    // they have special behavior for .jump
    func moveCommand(fromIndex: Int, toIndex: Int)

    // Removes all commands from userEnteredCommands.
    func clearAllCommands()

    // Reinitialises Model play state.
    func resetPlayState()

    // MARK - API for Logic.

    // Makes an iterator for `Logic` that returns `CommandData` in order.
    func makeCommandDataListIterator() -> CommandDataListIterator

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
