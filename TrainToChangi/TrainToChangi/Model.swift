protocol Model {
    var gameState: GameState { get }
    var commands: [Command] { get }

    func updateGameState(_ gameState: GameState)
    func storeStationState()
    func copyFromMemory(index: Int) -> CommandResult // CopyFromCommand
    func copyToMemory(index: Int) -> CommandResult // CopyToCommand
    func addToPersonValue(from memory: Int) -> CommandResult // AddCommand
    func dequeueValueFromInbox() -> CommandResult // InputCommand
    func putValueIntoOutbox() -> CommandResult // OutputCommand
    func undo() -> Bool
    func redo() -> Bool
}
