//
// Manages the logic required to update the model when commands are executed.
// It also contains methods pertaining to the game logic.
//
import Foundation
class LogicManager: Logic {
    unowned private let model: Model
    private let gameLogic: GameLogic
    private var iterator: CommandDataListIterator!
    fileprivate(set) var executedCommands: Stack<Command>

    var canUndo: Bool {
        return executedCommands.isEmpty
    }

    init(model: Model) {
        self.model = model
        self.executedCommands = Stack()
        self.gameLogic = GameLogic(model: model)
        gameLogic.gameLogicDelegate = self
    }

    // Executes the list of commands that user has selected.
    // As this method will busy-wait, it is run in background thread.
    func run() {
        let binarySemaphore = DispatchSemaphore(value: 1)
        DispatchQueue.global(qos: .background).async {
            while case .running = self.model.runState {
                // Allows only 1 `executeNextCommand()` to be queued in main thread
                binarySemaphore.wait()

                while self.model.runState != .running(isAnimating: false) {
                    usleep(Constants.Time.oneMillisecond)
                }

                // execution of command must be done on main thread to allow the update
                // of UI buttons during the change of run states.
                DispatchQueue.main.async {
                    self.stepForward()
                    binarySemaphore.signal()
                }
            }
        }
    }

    // Reverts the state of the model by one command execution backward.
    func stepBack() {
        // Since we do not store jump targets as executable commands, there
        // will be no actual undoing done except for moving the iterator
        // to the previous index.
        guard iterator.current != .jumpTarget else {
            iterator.previous()
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.endOfCommandExecution,
                                                         object: nil, userInfo: nil))
            return
        }

        guard let command = executedCommands.pop() else {
            fatalError("User should not be allowed to undo")
        }

        gameLogic.stepBack(command)
        if !(command is JumpCommand) {
            iterator.previous()
        }

        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.endOfCommandExecution,
                                                     object: nil, userInfo: nil))
    }

    // Executes the next command.
    func stepForward() {
        if iterator == nil {
            iterator = model.makeCommandDataListIterator()
            gameLogic.parser = CommandDataParser(model: model, iterator: iterator)
        }

        let commandData = iterator.current
        if let executedCommand = gameLogic.stepForward(commandData: commandData) {
            executedCommands.push(executedCommand)
        }

        if commandData != .jump {
            iterator.next()
        }

        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.endOfCommandExecution,
                                                     object: nil, userInfo: nil))
    }
}

extension LogicManager: GameLogicDelegate {
    var numCommandsExecuted: Int {
        return executedCommands.count
    }
}
