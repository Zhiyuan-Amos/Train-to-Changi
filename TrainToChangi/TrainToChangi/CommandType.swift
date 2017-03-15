enum CommandType {
    case inbox, outbox, copyFrom(memoryIndex: Int), copyTo(memoryIndex: Int),
    add(memoryIndex: Int), jump(targetIndex: Int)
}
