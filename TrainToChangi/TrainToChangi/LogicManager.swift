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
                    usleep(Constants.Logic.oneMillisecond)
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
        guard let command = executedCommands.pop() else {
            fatalError("User should not be allowed to undo")
        }

        gameLogic.stepBack(command)
        iterator.previous()
    }

    // Executes the next command.
    func stepForward() {
        if iterator == nil {
            iterator = model.makeCommandDataListIterator()
            gameLogic.parser = CommandDataParser(model: model, iterator: iterator)
        }

        guard let executedCommand = gameLogic.stepForward(commandData: iterator.next()) else {
            return
        }

        executedCommands.push(executedCommand)
    }
}

extension LogicManager: GameLogicDelegate {
    var numCommandsExecuted: Int {
        return executedCommands.count
    }
}
