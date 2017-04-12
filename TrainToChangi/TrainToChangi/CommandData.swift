//
// Enum of the commands used in the game.
//

enum CommandData {
    case inbox
    case outbox
    case copyFrom(memoryIndex: Int)
    case copyTo(memoryIndex: Int)
    case add(memoryIndex: Int)
    case sub(memoryIndex: Int)
    case jump
    case jumpIfZero
    case jumpIfNegative
    case jumpTarget

    var isJumpCommand: Bool {
        return self == .jump || self == .jumpIfZero || self == .jumpIfNegative
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
        case .sub(let index):
            return "sub_\(index)"
        case .jump:
            return "jump"
        case .jumpIfZero:
            return "jumpIfZero"
        case .jumpIfNegative:
            return "jumpIfNegative"
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
            self = CommandData.copyFrom(memoryIndex: Int(commandArr[1])!)
        case "copyTo":
            self = CommandData.copyTo(memoryIndex: Int(commandArr[1])!)
        case "add":
            self =  CommandData.add(memoryIndex: Int(commandArr[1])!)
        case "sub":
            self =  CommandData.sub(memoryIndex: Int(commandArr[1])!)
        case "jump":
            self = CommandData.jump
        case "jumpIfZero":
            self = CommandData.jumpIfZero
        case "jumpIfNegative":
            self = CommandData.jumpIfNegative
        case "jumpTarget":
            self = CommandData.jumpTarget
        default:
            fatalError("Should never happen, undefined enum.")
        }
    }
}

extension CommandData: Equatable {
}

func == (lhs: CommandData, rhs: CommandData) -> Bool {
    switch (lhs, rhs) {
    case (.inbox, .inbox),
         (.outbox, .outbox),
         (.jump, .jump),
         (.jumpIfZero, .jumpIfZero),
         (.jumpIfNegative, .jumpIfNegative),
         (.jumpTarget, .jumpTarget):
        return true
    case let (.copyFrom(indexOne), .copyFrom(indexTwo)),
         let (.copyTo(indexOne), .copyTo(indexTwo)),
         let (.add(indexOne), .add(indexTwo)),
         let (.sub(indexOne), .sub(indexTwo)):
        return indexOne == indexTwo
    default: return false
    }
}
