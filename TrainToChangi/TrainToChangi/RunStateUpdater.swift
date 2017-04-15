//
// Updates the run state of the game after execution of a command.
//

class RunStateUpdater {
    unowned let model: Model

    init(model: Model) {
        self.model = model
    }

    // Updates the run state depending on `model`'s values using
    // the `commandResult` returned from executing the current command.
    func updateRunState(commandResult: CommandResult, numCommandsExecuted: Int) {
        if hasMetWinCondition() {
            model.runState = .won
            model.numSteps = numCommandsExecuted
        } else if commandResult == .failure(error: .invalidOperation) {
            model.runState = .lost(error: .invalidOperation)
        } else if commandResult == .failure(error: .incompleteOutboxValues) {
            model.runState = .lost(error: .incompleteOutboxValues)
        } else if !isOutputValid() {
            model.runState = .lost(error: .wrongOutboxValue)
        }

        if case .lost = model.runState {
            model.incrementNumLost()
        }
    }

    // Returns true if the current output equals the expected output.
    private func hasMetWinCondition() -> Bool {
        return model.currentInputs.isEmpty
            && model.currentOutputs == model.expectedOutputs
    }

    // Returns true if all the values currently in current output is
    // equal to the expected output. Return value of `true` does not equate to
    // win condition met, as maybe not all of values required have been put into
    // the `model`.
    private func isOutputValid() -> Bool {
        for (index, value) in model.currentOutputs.enumerated() {
            if value != model.expectedOutputs[index] {
                return false
            }
        }
        return true
    }
}
