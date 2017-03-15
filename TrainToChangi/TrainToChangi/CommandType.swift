enum CommandType {
    case inbox, outbox, copyFrom(index: Int), copyTo(index: Int), add(index: Int),
    jump(index: Int)
}
