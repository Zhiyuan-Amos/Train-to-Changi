//
// The command that causes the command execution pointer to jump to `targetIndex`.
//

class JumpCommand: Command {
    let targetIndex: Int
    let sequencer: Sequencer

    init(targetIndex: Int, sequencer: Sequencer) {
        self.targetIndex = targetIndex
        self.sequencer = sequencer
    }

    override func execute() -> CommandResult {
        sequencer.commandIndex = targetIndex
        return CommandResult()
    }
}
