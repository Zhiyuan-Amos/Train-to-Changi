//
// Manages the logic required to update the model when commands are executed.
// It also contains methods pertaining to the game logic.
//
import Foundation
class LogicManager: Logic {
    unowned private let model: Model
    private let gameLogic: GameLogic
    private var iterator: CommandDataListIterator!
    fileprivate(set) var executedCommands: Stack<(Int, Command)>

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
        guard let (index, command) = executedCommands.pop() else {
            fatalError("User should not be allowed to undo")
        }

        gameLogic.stepBack(command)
        iterator.moveIterator(to: index)

        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.endOfCommandExecution,
                                                     object: nil, userInfo: nil))

        if !(command is JumpTarget || command is JumpCommand) {
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.resetGameScene,
                                                         object: model.levelState, userInfo: nil))
        }
    }

    // Executes the next command.
    func stepForward() {
        if iterator == nil {
            iterator = model.makeCommandDataListIterator()
            gameLogic.parser = CommandDataParser(model: model, iterator: iterator)
        }

        let commandData = iterator.current
        guard let currentIndex = iterator.index else {
            fatalError("Iterator not configured rightly.")
        }
        if let executedCommand = gameLogic.stepForward(commandData: commandData) {
            executedCommands.push(currentIndex, executedCommand)
        }

        // If the command executed is JumpCommand, then there's no need to further
        // move the iterator to the next position
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
