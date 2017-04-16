//
// Manages the logic required to update the model when commands are executed.
// It also contains methods pertaining to the game logic.
//
import Foundation
class LogicManager: Logic {
    unowned private let model: Model
    private let gameLogic: GameLogic
    private let updater: RunStateUpdater
    private var programCounter: CommandDataListCounter!
    // Contains the index of the command inside `model.currentInputs` and the corresponding `Command`.
    private var executedCommands: Stack<(Int, Command)>
    private var binarySemaphore: DispatchSemaphore

    var canUndo: Bool {
        return executedCommands.isEmpty
    }

    init(model: Model) {
        self.model = model
        self.executedCommands = Stack()
        self.gameLogic = GameLogic(model: model)
        self.updater = RunStateUpdater(model: model)
        self.binarySemaphore = DispatchSemaphore(value: 0)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAnimationEnd(notification:)),
            name: Constants.NotificationNames.animationEnded, object: nil)
    }

    // Executes the list of commands that user has selected.
    // As this method will busy-wait, it is run in background thread.
    func run() {
        DispatchQueue.global(qos: .background).async {
            while case .running = self.model.runState {
                // execution of command must be done on main thread as it will need
                // to update UI.
                self.executeCommandInMainThread()

                // Allows only 1 `self.stepForward()` to be queued in main thread.
                // This ensures that `self.stepForward()` is done executing before
                // checking for while loop condition.
                self.binarySemaphore.wait()

                // After the command has finished execution, the UI will animate.
                // As such, waits for animation to end before executing the next command.
                self.busyWaitWhileAnimating()
            }
        }
    }

    // Helper function - executes command in main thread and signals `binarySemaphore` when done.
    private func executeCommandInMainThread() {
        DispatchQueue.main.async {
            self.stepForward()
            self.binarySemaphore.signal()
        }
    }

    // Helper function - sleeps current thread while game UI is animating
    private func busyWaitWhileAnimating() {
        if self.model.runState == .running(isAnimating: true)
            || self.model.runState == .stepping(isAnimating: true) {
                binarySemaphore.wait()
        }
    }

    // Reverts the state of the model by one command execution backward.
    func stepBack() {
        guard let (index, command) = executedCommands.pop() else {
            fatalError("User should not be allowed to undo")
        }

        gameLogic.stepBack(command)
        programCounter.moveCounter(to: index)

        // The undo-ing of jump related commands do not require update in scene.
        if !(command is JumpCommand || command is JumpTarget
            || command is JumpIfNegativeCommand || command is JumpIfZeroCommand) {
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.resetGameScene,
                                                         object: model.levelState, userInfo: nil))
        }
    }

    // Executes the next command.
    func stepForward() {
        createCounterIfNil()

        // as jump related commands may alter the index after execution,
        // thus we have to store the value of the current index which will be used later
        let currentIndex = programCounter.index

        let commandAndResult = execute()

        guard let index = currentIndex, let command = commandAndResult.0,
            let commandResult = commandAndResult.1 else {
            return
        }

        postExecutionUpdate(index: index, command: command, commandResult: commandResult)
    }

    // Helper function - executes the next command and updates the run state accordingly.
    // Returns the executed command and the command result, if any.
    private func execute() -> (Command?, CommandResult?) {
        let commandAndResult = gameLogic.stepForward(commandData: programCounter.current)
        guard let commandResult = commandAndResult.1 else {
            fatalError("Misconfiguration of game logic")
        }
        updater.updateRunState(commandResult: commandResult, numCommandsExecuted: executedCommands.count)
        if case .lost = model.runState {
            return (nil, nil)
        }

        return commandAndResult
    }

    // Helper function - executes necessary miscellaneous updates after command execution.
    private func postExecutionUpdate(index: Int, command: Command, commandResult: CommandResult) {
        postSceneNotifications(command)
        executedCommands.push(index, command)

        // If the command executed is jump related commands, then there's no need to further
        // move the programCounter to the next position since the execution has already moved
        // the programCounter's position.
        if commandResult == .success(isJump: false) {
            programCounter.next()
        }

        // Commands with animations will automatically toggle `model.runState`
        // from `.stepping(isAnimating: true)` to `.paused` after animation ends.
        // However, `.stepping(isAnimating: false)` does not have animation,
        // thus nothing will notify it to change it to .paused. Thus, we have to
        // manually toggle it here.
        if model.runState == .stepping(isAnimating: false) {
            model.runState = .paused
        }
    }

    // Resets the current play state
    func resetPlayState() {
        executedCommands = Stack()
        programCounter = nil
        binarySemaphore = DispatchSemaphore(value: 0)
    }

    // Helper function - Creates `programCounter` and passes it to the classes that require
    // it.
    private func createCounterIfNil() {
        if programCounter == nil {
            programCounter = model.makeCommandDataListCounter()
            gameLogic.parser = CommandDataParser(model: model, programCounter: programCounter)
        }
    }

    // MARK - Notification
    private func postSceneNotifications(_ command: Command) {
        let layout = model.currentLevel.memoryLayout
        switch command {
        case is InboxCommand:
            notifySceneToMove(to: .inbox)
        case is OutboxCommand:
            notifySceneToMove(to: .outbox)
        case let command as CopyFromCommand:
            notifySceneToMove(to: .memory(layout: layout, index: command.memoryIndex, action: .get))
        case let command as CopyToCommand:
            notifySceneToMove(to: .memory(layout: layout, index: command.memoryIndex, action: .put))
        case let command as AddCommand:
            guard let expected = model.getValueOnPerson() else {
                fatalError("Error in executing AddCommand")
            }
            notifySceneToMove(to: .memory(
                layout: layout, index: command.memoryIndex, action: .compute(expected: expected)))
        case let command as SubCommand:
            guard let expected = model.getValueOnPerson() else {
                fatalError("Error in executing SubCommand")
            }
            notifySceneToMove(to: .memory(
                layout: layout, index: command.memoryIndex, action: .compute(expected: expected)))
        default:
            break
        }
    }

    private func notifySceneToMove(to dest: WalkDestination) {
        NotificationCenter.default.post(Notification(
            name: Constants.NotificationNames.movePersonInScene,
            object: nil, userInfo: ["destination": dest]))
    }

    @objc fileprivate func handleAnimationEnd(notification: Notification) {
        binarySemaphore.signal()
    }
}
