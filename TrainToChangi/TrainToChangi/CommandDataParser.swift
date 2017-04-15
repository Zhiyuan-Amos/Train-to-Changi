//
// Parses `CommandData` enum to `Command`.
//

class CommandDataParser {
    private unowned let model: Model
    private unowned let programCounter: CommandDataListCounter

    init(model: Model, programCounter: CommandDataListCounter) {
        self.model = model
        self.programCounter = programCounter
    }

    // Parses `commandData` to `Command`.
    func parse(commandData: CommandData) -> Command {
        switch commandData {
        case .inbox:
            return InboxCommand(model: model)
        case .outbox:
            return OutboxCommand(model: model)
        case .copyFrom(let index):
            return CopyFromCommand(model: model, memoryIndex: index)
        case .copyTo(let index):
            return CopyToCommand(model: model, memoryIndex: index)
        case .add(let index):
            return AddCommand(model: model, memoryIndex: index)
        case .sub(let index):
            return SubCommand(model: model, memoryIndex: index)
        case .jump:
            return JumpCommand(programCounter: programCounter)
        case .jumpIfZero:
            return JumpIfZeroCommand(model: model, programCounter: programCounter)
        case .jumpIfNegative:
            return JumpIfNegativeCommand(model: model, programCounter: programCounter)
        case .jumpTarget:
            return JumpTarget()
        }
    }
}
