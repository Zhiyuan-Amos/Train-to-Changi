//
// Parses CommandData to Command.
//

class CommandDataParser {
    private unowned let model: Model
    private unowned let iterator: CommandDataListIterator

    init(model: Model, iterator: CommandDataListIterator) {
        self.model = model
        self.iterator = iterator
    }

    // Parses CommandData to Command.
    func parse(commandData: CommandData) -> Command {
        switch commandData {
        case .inbox:
            return InboxCommand(model: model)
        case .outbox:
            return OutboxCommand(model: model)
        case .copyFrom(let index):
            let index = returnIndex(index)
            return CopyFromCommand(model: model, memoryIndex: index)
        case .copyTo(let index):
            let index = returnIndex(index)
            return CopyToCommand(model: model, memoryIndex: index)
        case .add(let index):
            let index = returnIndex(index)
            return AddCommand(model: model, memoryIndex: index)
        case .sub(let index):
            let index = returnIndex(index)
            return SubCommand(model: model, memoryIndex: index)
        case .jump:
            return JumpCommand(iterator: iterator)
        case .jumpIfZero:
            return JumpIfZeroCommand(model: model, iterator: iterator)
        case .jumpIfNegative:
            return JumpIfNegativeCommand(model: model, iterator: iterator)
        case .jumpTarget:
            return JumpTarget()
        }
    }

    // Helper function for returning `index`.
    private func returnIndex(_ index: Int?) -> Int {
        guard let index = index else {
            fatalError("User should not be allowed to set index to nil")
        }

        return index
    }
}
