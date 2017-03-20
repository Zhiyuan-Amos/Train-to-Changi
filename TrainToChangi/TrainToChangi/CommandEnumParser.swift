//
// Parses [CommandEnum] into [Command].
//

struct CommandEnumParser {
    // Parses [CommandEnum] to [Command].
    func parse(model: Model) -> [Command] {
        var commands = [Command]()
        let commandEnums = model.currentCommands

        for commandEnum in commandEnums {
            switch commandEnum {
            case .inbox:
                commands.append(InboxCommand(model: model))
            case .outbox:
                commands.append(OutboxCommand(model: model))
            case .copyFrom(let index):
                let index = returnIndex(index)
                commands.append(CopyFromCommand(model: model, memoryIndex: index))
            case .copyTo(let index):
                let index = returnIndex(index)
                commands.append(CopyToCommand(model: model, memoryIndex: index))
            case .add(let index):
                let index = returnIndex(index)
                commands.append(AddCommand(model: model, memoryIndex: index))
            case .jump(let index):
                let index = returnIndex(index)
                commands.append(JumpCommand(model: model, targetIndex: index))
            case .placeHolder:
                commands.append(PlaceholderCommand())
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
