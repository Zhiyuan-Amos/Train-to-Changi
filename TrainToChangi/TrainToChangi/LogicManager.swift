//
// Manages the logic required to update the model when commands are executed.
// It also contains methods pertaining to the game logic.
//
import Foundation
//TODO: Refactor into GameLogic.
class LogicManager: Logic {
    unowned private let model: Model
    private var iterator: CommandDataListIterator!
    private let parser: CommandDataParser
    private let updater: RunStateUpdater
    private var executedCommands: Stack<Command>

    init(model: Model) {
        self.model = model
        self.parser = CommandDataParser(model: model)
        self.updater = RunStateUpdater(model: model)
        self.executedCommands = Stack()
    }

    // Executes the list of commands that user has selected.
    func executeCommands() {
        DispatchQueue.global(qos: .background).async {
            while case .running = self.model.runState {
                guard self.model.runState == .running(isAnimating: false) else {
                    continue
                }

                self.executeNextCommand()
            }
        }
    }

    // Reverts the state of the model by one command execution backward.
    // Returns true if there's still commands to be undone.
    func undo() -> Bool {
        guard let command = executedCommands.pop() else {
            fatalError("User should not be allowed to undo")
        }

        command.undo()
        iterator.previous()

        return !executedCommands.isEmpty
    }

    // Executes the next command.
    func executeNextCommand() {
        if iterator == nil {
            iterator = model.makeCommandDataListIterator()
            parser.iterator = iterator
        }

        guard let commandData = iterator.next() else {
            model.runState = .lost(error: .incompleteOutboxValues)
            return
        }

        guard let command = parser.parse(commandData: commandData) else {
            return
        }

        let commandResult = command.execute()
        executedCommands.push(command)

        updater.updateRunState(commandResult: commandResult)
        if model.runState == .won {
            updateNumStepsTaken()
        }
    }

    private func updateNumStepsTaken() {
        model.numSteps = executedCommands.count
    }
}
