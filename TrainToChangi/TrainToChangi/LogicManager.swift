//
// Manages the logic required to update the model when commands are executed.
// It also contains methods pertaining to the game logic.
//
import Foundation
class LogicManager: Logic, GameLogicDelegate {
    unowned private let model: Model
    private let gameLogic: GameLogic
    private var iterator: CommandDataListIterator!
    private var executedCommands: Stack<Command>

    var numCommandsExecuted: Int {
        return executedCommands.count
    }

    init(model: Model) {
        self.model = model
        self.executedCommands = Stack()
        self.gameLogic = GameLogic(model: model)
        gameLogic.gameLogicDelegate = self
    }

    // Executes the list of commands that user has selected.
    // As this method will busy-wait, it is run in background thread. 
    func executeCommands() {
        DispatchQueue.global(qos: .background).async {
            while case .running = self.model.runState {
                guard self.model.runState == .running(isAnimating: false) else {
                    usleep(100000)
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

        gameLogic.undo(command)
        iterator.previous()

        return !executedCommands.isEmpty
    }

    // Executes the next command.
    func executeNextCommand() {
        if iterator == nil {
            iterator = model.makeCommandDataListIterator()
            gameLogic.parser = CommandDataParser(model: model, iterator: iterator)
        }

        guard let executedCommand = gameLogic.execute(commandData: iterator.next()) else {
            return
        }

        executedCommands.push(executedCommand)
    }
}
