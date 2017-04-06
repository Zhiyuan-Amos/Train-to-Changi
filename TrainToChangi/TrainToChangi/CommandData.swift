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
            if let index = index {
                return "copyFrom_\(index)"
            }
            return "copyFrom_\(index)"
        case .copyTo(let index):
            if let index = index {
                return "copyTo_\(index)"
            }
            return "copyTo_\(index)"
        case .add(let index):
            if let index = index {
                return "add_\(index)"
            }
            return "add_\(index)"
        case .jump:
            return "jump"
        case .jumpTarget:
            return "jumpTarget"
        }
    }

    internal func toFilePath() -> String {
        switch self {
        case .inbox:
            return "inbox"
        case .outbox:
            return "outbox"
        case .copyFrom(let index):
            return "copyFrom"
        case .copyTo(let index):
            return "copyTo"
        case .add(let index):
            return "add"
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
         (.jumpTarget, .jumpTarget):
        return true
    case let (.copyFrom(indexOne), .copyFrom(indexTwo)),
         let (.copyTo(indexOne), .copyTo(indexTwo)),
         let (.add(indexOne), .add(indexTwo)):
        return indexOne == indexTwo
    default: return false
    }
}
