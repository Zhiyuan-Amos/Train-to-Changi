//
// Parses [CommandType] into [Command].
//

struct CommandTypeParser {
    unowned let sequencer: Sequencer

    init(sequencer: Sequencer) {
        self.sequencer = sequencer
    }

    func parse(_ commandTypes: [CommandType]) -> [Command] {
        var commands = [Command]()

        for commandType in commandTypes {
            switch commandType {
            case .inbox:
                commands.append(InboxCommand())
            case .outbox:
                commands.append(OutboxCommand())
            case .copyFrom(let index):
                commands.append(CopyFromCommand(memoryIndex: index))
            case .copyTo(let index):
                commands.append(CopyToCommand(memoryIndex: index))
            case .add(let index):
                commands.append(AddCommand(memoryIndex: index))
            case .jump(let index):
                commands.append(JumpCommand(targetIndex: index, sequencer: sequencer))
            }
        }

        return commands
    }
}
