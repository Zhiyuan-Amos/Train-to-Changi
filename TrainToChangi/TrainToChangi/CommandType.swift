//
// Enum of the commands used in the game.
//

enum CommandType {
    case inbox, outbox, copyFrom(memoryIndex: Int?), copyTo(memoryIndex: Int?),
    add(memoryIndex: Int?), jump(targetIndex: Int?), placeHolder

    func isIndexed() -> Bool {
        switch self {
        case .copyFrom, .copyTo, .add, .jump: return true
        case .inbox, .outbox, .placeHolder: return false
        }
    }
}
