//
// Manages the logic required to update the model when commands are executed.
// It also contains methods pertaining to the game logic.
//

//TODO: Refactor into GameLogic.
class LogicManager: Logic {
    unowned private let model: Model
    private let updater: RunStateUpdater
    private var executedCommands: Stack<Command>
    private var commands: [Command]!
    private var isFirstExecution: Bool

    init(model: Model) {
        self.model = model
        self.updater = RunStateUpdater(runStateDelegate: model)
        self.executedCommands = Stack()
        self.isFirstExecution = true
    }

    // Executes the list of commands in `model.currentCommands`.
    func executeCommands() {
        if model.runState == .stopped {
            isFirstExecution = true
        }

        model.runState = .running

        if isFirstExecution {
            initVariablesForExecution()
        }

        while model.runState == .running {
            executeNextCommand()
        }
    }

    // Reverts the state of the model by one command execution backward.
    // Returns true if there's still commands to be undone.
    func undo() -> Bool {
        guard let command = executedCommands.pop() else {
            fatalError("User should not be allowed to undo")
        }

        command.undo()

        model.programCounter! -= 1

        return !executedCommands.isEmpty
    }

    // Executes the next command.
    func executeNextCommand() {
        if isFirstExecution {
            initVariablesForExecution()
        }
        
        let command = commands[model.programCounter!]
        let commandResult = command.execute()

        executedCommands.push(command)
        model.programCounter! += 1
        updater.updateRunState(commandResult: commandResult)
        if model.runState == .won {
            updateNumStepsTaken()
        }
    }

    // Initialises the necessary variables for command execution to begin.
    private func initVariablesForExecution() {
        guard model.userEnteredCommands.count > 0 else {
            model.runState = .lost(error: .incompleteOutboxValues)
            return
        }
        model.programCounter = 0
        commands = CommandEnumParser().parse(model: model)
        isFirstExecution = false
    }

    private func updateNumStepsTaken() {
        let placeHolderCommandsCount = executedCommands.filter { command in command is PlaceholderCommand }.count
        model.numSteps = executedCommands.count - placeHolderCommandsCount
    }
}
