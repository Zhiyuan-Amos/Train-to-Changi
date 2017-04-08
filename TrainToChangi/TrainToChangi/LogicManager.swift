//
// Manages the logic required to update the model when commands are executed.
// It also contains methods pertaining to the game logic.
//
import Foundation
class LogicManager: Logic {
    unowned private let model: Model
    private let gameLogic: GameLogic
    private var iterator: CommandDataListIterator!
    // Contains the index of the command inside `model.currentInputs` and the corresponding `Command`.
    fileprivate(set) var executedCommands: Stack<(Int, Command)>

    var canUndo: Bool {
        return executedCommands.isEmpty
    }

    init(model: Model) {
        self.model = model
        self.executedCommands = Stack()
        self.gameLogic = GameLogic(model: model)
        self.gameLogic.gameLogicDelegate = self
    }

    // Executes the list of commands that user has selected.
    // As this method will busy-wait, it is run in background thread.
    func run() {
        let binarySemaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .background).async {
            while case .running = self.model.runState {
                // execution of command must be done on main thread to allow the update
                // of UI buttons during the change of run states.
                DispatchQueue.main.async {
                    self.stepForward()
                    binarySemaphore.signal()
                }

                // Allows only 1 `self.stepForward()` to be queued in main thread.
                // This ensures that `self.stepForward()` is done executing before
                // checking for while loop condition.
                binarySemaphore.wait()

                // Busy wait while the game scene is animating.
                while self.model.runState == .running(isAnimating: true)
                    || self.model.runState == .stepping(isAnimating: true) {
                        usleep(Constants.Time.oneMillisecond)
                }
            }

            // If the while loop above is broken because user pressed the
            // stepBack or stepForward button, toggle the runState to .paused.
            DispatchQueue.main.async {
                if self.model.runState == .stepping(isAnimating: false) {
                    self.model.runState = .paused
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

        // The undoing of JumpCommand or JumpTarget does not require update in scene.
        if !(command is JumpCommand || command is JumpTarget) {
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.resetGameScene,
                                                         object: model.levelState, userInfo: nil))
        }
    }

    // Executes the next command.
    func stepForward() {
        print("")
        createIteratorIfNil()

        // as we only store the current index after execution of command, jumpCommand
        // will alter the index, thus we have to store the value of the previous index
        let currentIndex = iterator.index
        print(currentIndex)
        guard let executedCommand = gameLogic.stepForward(commandData: iterator.current) else {
            return
        }
        if case .lost = model.runState {
            return
        }

        executedCommands.push(currentIndex!, executedCommand)

        // If the command executed is JumpCommand , then there's no need to further
        // move the iterator to the next position since the execution has already moved
        // the iterator's position.
        if !(executedCommand is JumpCommand) {
            iterator.next()
        }

        // Commands with animations will automatically toggle `model.runState`
        // from `.stepping(isAnimating: true)` to `.paused` after animation ends.
        // However, `.stepping(isAnimating: false)` does not have animation,
        // thus nothing will notify it to change it to .paused. Thus, we have to
        // manually toggle it here.
        if model.runState == .stepping(isAnimating: false) {
            model.runState = .paused
        }

        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.endOfCommandExecution,
                                                     object: nil, userInfo: nil))
    }

    func resetPlayState() {
        executedCommands = Stack()
        iterator = nil
    }

    private func createIteratorIfNil() {
        if iterator == nil {
            iterator = model.makeCommandDataListIterator()
            gameLogic.parser = CommandDataParser(model: model, iterator: iterator)
        }
    }
}

extension LogicManager: GameLogicDelegate {
    var numCommandsExecuted: Int {
        return executedCommands.count
    }
}
