//
// Enum of the commands used in the game.
//

enum CommandData {
    case inbox
    case outbox
    case copyFrom(memoryIndex: Int?)
    case copyTo(memoryIndex: Int?)
    case add(memoryIndex: Int?)
    case jump
    case jumpTarget

    var isJumpCommand: Bool {
        return self == .jump
    }

    func toString() -> String {
        switch self {
        case .inbox:
            return "inbox"
        case .outbox:
            return "outbox"
        case .copyFrom(_):
            return "copyFrom"
        case .copyTo(_):
            return "copyTo"
        case .add(_):
            return "add"
        case .jump:
            return "jump"
        case .jumpTarget:
            return "jumpTarget"
        }
    }
}

extension CommandData: Equatable {
}

func == (lhs: CommandData, rhs: CommandData) -> Bool {
    switch (lhs, rhs) {
    case (.inbox, .inbox):
        return true
    case (.outbox, .outbox):
        return true
    case (let .copyFrom(indexOne), let .copyFrom(indexTwo)):
        return indexOne == indexTwo
    case (let .copyTo(indexOne), let .copyTo(indexTwo)):
        return indexOne == indexTwo
    case (let .add(indexOne), let .add(indexTwo)):
        return indexOne == indexTwo
    case (.jump, .jump):
        return true
    case (.jumpTarget, .jumpTarget):
        return true
    default: return false
    }
}
