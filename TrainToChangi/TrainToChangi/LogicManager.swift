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
    private var isExecutionAllowed: Bool

    init(model: Model) {
        self.model = model
        self.parser = CommandDataParser(model: model)
        self.updater = RunStateUpdater(model: model)
        self.executedCommands = Stack() //TODO: Change to array
        self.isExecutionAllowed = true

        NotificationCenter.default.addObserver(
            self, selector: #selector(catchNotification(notification:)),
            name: Constants.NotificationNames.animationEnded, object: nil)
    }

    @objc fileprivate func catchNotification(notification: Notification) {
        isExecutionAllowed = true
    }

    // Executes the list of commands that user has selected.
    func executeCommands() {
        DispatchQueue.global(qos: .background).async {
            while self.model.runState == .running {
                guard self.isExecutionAllowed else {
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
        iterator.previous() // TODO: Think of how to update visuals
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
        //TODO: clean up
        switch commandData {
        case .inbox, .outbox:
            isExecutionAllowed = false
        default:
            break
        }

        let command = parser.parse(commandData: commandData)
        let commandResult = command.execute()

        executedCommands.push(command)

        updater.updateRunState(commandResult: commandResult)
        if model.runState == .won {
            updateNumStepsTaken()
        }
    }

    private func updateNumStepsTaken() {
        let jumpTargetCount = executedCommands.filter { command in command is JumpTarget }.count
        model.numSteps = executedCommands.count - jumpTargetCount
    }
}
