//
// Enum of the commands used in the game.
//

enum CommandData {
    case inbox
    case outbox
    case copyFrom(memoryIndex: Int?)
    case copyTo(memoryIndex: Int?)
    case add(memoryIndex: Int?)
    case jump(targetIndex: Int?)
    case placeholder

    func toString() -> String {
        switch self {
        case .inbox:
            return "inbox"
        case .outbox:
            return "outbox"
        case .copyFrom(let memoryIndex):
            return "copyFrom_\(memoryIndex)"
        case .copyTo(let memoryIndex):
            return "copyTo_\(memoryIndex)"
        case .add(let memoryIndex):
            return "add_\(memoryIndex)"
        case .jump(let targetIndex):
            return "jump_\(targetIndex)"
        case .placeholder:
            return "placeholder"
        }
    }

    var isJumpCommand: Bool {
        switch self {
        case .jump(_): return true
        default: return false
        }
    }

    static func convertFromString(commandString: String) -> CommandData? {
        let commandArr = commandString.characters.split { $0 == "_" }.map(String.init)

        switch commandArr[0] {
            case "inbox":
                return CommandData.inbox
            case "outbox":
                return CommandData.outbox
            case "placeholder":
                return CommandData.placeholder
            case "copyFrom":
                return CommandData.copyFrom(memoryIndex: Int(commandArr[1]))
            case "copyTo":
                return CommandData.copyTo(memoryIndex: Int(commandArr[1]))
            case "add":
                return CommandData.add(memoryIndex: Int(commandArr[1]))
            case "jump":
                return CommandData.jump(targetIndex: Int(commandArr[1]))
            default:
                return nil
        }
    }
}
