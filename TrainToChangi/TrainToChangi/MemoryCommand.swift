//
// `MemoryCommand` is a special type of command containing the index of the memory
// location that the command executes on.
//

protocol MemoryCommand: Command {
    var memoryIndex: Int { get }
}
