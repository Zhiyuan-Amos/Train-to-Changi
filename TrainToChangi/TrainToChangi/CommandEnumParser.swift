//
// Parses [CommandEnum] into [Command].
//

struct CommandEnumParser {
    // Parses [CommandEnum] to [Command].
    func parse(model: Model) -> [Command] {
        let commands = convertCommandEnumToCommand(model: model)
        assignJumpAndPlaceHolderPairing(commands: commands)

        guard areJumpAndPlaceHolderPairingsValid(commands: commands) else {
            fatalError("Model provided the wrong indices for jump command and placeholder command")
        }

        return commands
    }

    // Helper function to convert the `model.userEnteredCommands` of type `CommandEnum` into `[Command]`.
    private func convertCommandEnumToCommand(model: Model) -> [Command] {
        var commands = [Command]()
        let commandEnums = model.userEnteredCommands

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
            case .placeholder:
                commands.append(PlaceholderCommand(model: model))
            }
        }

        return commands
    }

    // Assign the pairings for `JumpCommand` and `PlaceHolderCommand`.
    // This is useful for ensuring that each `JumpCommand` is paired with a `PlaceHolderCommand`
    // i.e one to one mapping (bijection).
    private func assignJumpAndPlaceHolderPairing(commands: [Command]) {
        let jumpCommands = commands.filter { command in command is JumpCommand } as? [JumpCommand]

        for jumpCommand in jumpCommands! {
            if let placeHolderCommand = commands[jumpCommand.targetIndex] as? PlaceholderCommand {
                jumpCommand.placeholder = placeHolderCommand
                placeHolderCommand.jumpCommand = jumpCommand
            }
        }
    }

    // Checks whether each `JumpCommand` is paired with a `PlaceHolderCommand`
    // i.e one to one mapping (bijection).
    private func areJumpAndPlaceHolderPairingsValid(commands: [Command]) -> Bool {
        let jumpCommands = commands.filter { command in command is JumpCommand } as? [JumpCommand]

        for jumpCommand in jumpCommands! {
            guard let placeHolderOne = jumpCommand.placeholder else {
                return false
            }

            guard let placeHolderTwo = commands[jumpCommand.targetIndex] as? PlaceholderCommand else {
                return false
            }

            guard let jumpCommandTwo = placeHolderTwo.jumpCommand else {
                return false
            }

            guard placeHolderOne === placeHolderTwo
                && jumpCommandTwo === jumpCommand else {
                    return false
            }
        }

        return true
    }

    // Helper function for returning `index`.
    private func returnIndex(_ index: Int?) -> Int {
        guard let index = index else {
            fatalError("User should not be allowed to set index to nil")
        }

        return index
    }
}
