//
// Updates the run state of the game and notifies the view.
//

import Foundation
struct RunStateUpdater {
    unowned let runStateDelegate: RunStateDelegate

    init(runStateDelegate: RunStateDelegate) {
        self.runStateDelegate = runStateDelegate
    }

    // Updates the run state depending on `runStateDelegate`'s values and
    // the `commandResult` returned from executing the previous command.
    func updateRunState(commandResult: CommandResult) {
        if hasMetWinCondition() {
            runStateDelegate.runState = .won
        } else if !commandResult.isSuccessful {
            runStateDelegate.runState = .lost(error: commandResult.errorMessage!)
        } else if !isOutputValid() {
            runStateDelegate.runState = .lost(error: .wrongOutboxValue)
        } else if isIndexOutOfBounds() {
            runStateDelegate.runState = .lost(error: .incompleteOutboxValues)
        }
    }

    // Returns true if the current output equals the expected output.
    private func hasMetWinCondition() -> Bool {
        return runStateDelegate.currentOutput == runStateDelegate.expectedOutput
    }

    // Returns true if all the values currently in current output is
    // equal to the expected output. Return value of `true` does not equate to
    // win condition met, as maybe not all of values required have been put into
    // the `model`.
    private func isOutputValid() -> Bool {
        for (index, value) in runStateDelegate.currentOutput.enumerated() {
            if value != runStateDelegate.expectedOutput[index] {
                return false
            }
        }
        return true
    }

    private func isIndexOutOfBounds() -> Bool {
        guard runStateDelegate.commandIndex! >= 0 else {
            fatalError("commandIndex should never be smaller than 0")
        }
        return runStateDelegate.commandIndex! >= runStateDelegate.currentCommands.count
    }
}
