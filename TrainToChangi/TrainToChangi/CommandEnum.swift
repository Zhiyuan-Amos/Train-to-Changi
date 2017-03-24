//
// Enum of the commands used in the game.
//

enum CommandEnum {
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
        case .copyFrom(_):
            return "copyFrom"
        case .copyTo(_):
            return "copyTo"
        case .add(_):
            return "add"
        case .jump(_):
            return "jump"
        case .placeholder:
            return "jumptarget"
        }
    }

    static func convertFromString(commandString: String) -> CommandEnum? {
        let commandArr = commandString.characters.split { $0 == "_" }.map(String.init)

        switch commandArr[0] {
            case "inbox":
                return CommandEnum.inbox
            case "outbox":
                return CommandEnum.outbox
            case "placeholder":
                return CommandEnum.placeholder
            case "copyFrom":
                return CommandEnum.copyFrom(memoryIndex: Int(commandArr[1]))
            case "copyTo":
                return CommandEnum.copyTo(memoryIndex: Int(commandArr[1]))
            case "add":
                return CommandEnum.add(memoryIndex: Int(commandArr[1]))
            case "jump":
                return CommandEnum.jump(targetIndex: Int(commandArr[1]))
            default:
                return nil
        }
    }
}
