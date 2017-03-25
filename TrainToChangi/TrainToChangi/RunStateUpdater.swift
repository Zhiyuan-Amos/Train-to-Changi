//
// Updates the run state of the game.
//

class RunStateUpdater {
    unowned let model: Model

    init(model: Model) {
        self.model = model
    }

    // Updates the run state depending on `model`'s values and
    // the `commandResult` returned from executing the previous command.
    func updateRunState(commandResult: CommandResult) {
        if hasMetWinCondition() {
            model.runState = .won
        } else if !commandResult.isSuccessful {
            model.runState = .lost(error: commandResult.errorMessage!)
        } else if !isOutputValid() {
            model.runState = .lost(error: .wrongOutboxValue)
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
