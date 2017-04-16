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
    
    var canUndo: Bool {
        return executedCommands.isEmpty
    }
    
    init(model: Model) {
        self.model = model
        self.executedCommands = Stack()
        self.gameLogic = GameLogic(model: model)
        self.updater = RunStateUpdater(model: model)
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
        programCounter.moveCounter(to: index)
        
        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.endOfCommandExecution,
                                                     object: nil, userInfo: nil))
        
        // The undoing of JumpCommand or JumpTarget does not require update in scene.
        if !(command is JumpCommand || command is JumpTarget || command is JumpIfNegativeCommand
            || command is JumpIfZeroCommand) {
            NotificationCenter.default.post(Notification(name: Constants.NotificationNames.resetGameScene,
                                                         object: model.levelState, userInfo: nil))
        }
    }
    
    // Executes the next command.
    func stepForward() {
        createIteratorIfNil()
        
        // as we only store the current index after execution of command, jumpCommand
        // will alter the index, thus we have to store the value of the previous index
        let currentIndex = programCounter.index
        let tuple = gameLogic.stepForward(commandData: programCounter.current)
        updater.updateRunState(commandResult: tuple.1!, numCommandsExecuted: executedCommands.count)
        if case .lost = model.runState {
            model.incrementNumLost()
            return
        }
        guard let index = currentIndex, let command = tuple.0, let commandResult = tuple.1 else {
            fatalError("Misconfiguration of iterator and game logic")
        }
        postSceneNotifications(command)
        executedCommands.push(index, command)
        
        // If the command executed is JumpCommand , then there's no need to further
        // move the iterator to the next position since the execution has already moved
        // the iterator's position.
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
        
        NotificationCenter.default.post(Notification(name: Constants.NotificationNames.endOfCommandExecution,
                                                     object: nil, userInfo: nil))
    }
    
    func resetPlayState() {
        executedCommands = Stack()
        programCounter = nil
    }
    
    private func createIteratorIfNil() {
        if programCounter == nil {
            programCounter = model.makeCommandDataListCounter()
            gameLogic.parser = CommandDataParser(model: model, programCounter: programCounter)
        }
    }
    
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
}
