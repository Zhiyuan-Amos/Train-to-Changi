//
// Enum of the commands used in the game.
//

enum CommandType {
    case inbox, outbox, copyFrom(memoryIndex: Int?), copyTo(memoryIndex: Int?),
    add(memoryIndex: Int?), jump(targetIndex: Int?), placeHolder
}
