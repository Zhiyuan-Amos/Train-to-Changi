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
        case .copyFrom(let index):
            return "copyFrom_\(index)"
        case .copyTo(let index):
            return "copyTo_\(index)"
        case .add(let index):
            return "add_\(index)"
        case .jump:
            return "jump"
        case .jumpTarget:
            return "jumpTarget"
        }
    }

    init(commandString: String) {
        let commandArr = commandString.characters.split{$0 == "_"}.map(String.init)

        switch commandArr[0] {
        case "inbox":
            self = CommandData.inbox
        case "outbox":
            self = CommandData.outbox
        case "copyFrom":
            self = CommandData.copyFrom(memoryIndex: Int(commandArr[1]))
        case "copyTo":
            self = CommandData.copyTo(memoryIndex: Int(commandArr[1]))
        case "add":
            self =  CommandData.add(memoryIndex: Int(commandArr[1]))
        case "jump":
            self = CommandData.jump
        case "jumpTarget":
            self = CommandData.jumpTarget
        default:
            fatalError("Should never happen.")
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
