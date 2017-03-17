//
// Parses [CommandType] into [Command].
//

struct CommandTypeParser {
    func parse(_ commandTypes: [CommandType]) -> [Command] {
        var commands = [Command]()

        for commandType in commandTypes {
            switch commandType {
            case .inbox:
                commands.append(InboxCommand())
            case .outbox:
                commands.append(OutboxCommand())
            case .copyFrom(let index):
                let index = returnIndex(index)
                commands.append(CopyFromCommand(memoryIndex: index))
            case .copyTo(let index):
                let index = returnIndex(index)
                commands.append(CopyToCommand(memoryIndex: index))
            case .add(let index):
                let index = returnIndex(index)
                commands.append(AddCommand(memoryIndex: index))
            case .jump(let index):
                let index = returnIndex(index)
                commands.append(JumpCommand(targetIndex: index))
            }
        }

        return commands
    }

    // Helper function for returning `index` if it exists.
    private func returnIndex(_ index: Int?) -> Int {
        guard let index = index else {
            fatalError("User should not be allowed to set index to nil")
        }

        return index
    }
}
