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
    case placeHolder

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
        case .placeHolder:
            return "placeHolder"
        }
    }
}
