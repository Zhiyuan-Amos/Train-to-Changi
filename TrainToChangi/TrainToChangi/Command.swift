//
// Protocol following the Command-pattern. All commands must
// conform to this protocol. This is a protocol and not an abstract class
// because Swift does not support abstract classes. In trying to make this into an abstract
// class (for e.g, by making inherited methods to execute fatal error i.e forcing subclasses
// to override them), there will be occasions where the subclass may forgot to override
// the method, causing it to throw error in run time. By using a protocol, there will be
// a compile-time error, which is more visible for the developer to rectify.
//

protocol Command {
    func execute() -> CommandResult
    func undo()
}

protocol MemoryCommand {
    var index: Int { get }
}
