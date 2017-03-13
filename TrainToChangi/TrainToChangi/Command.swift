//
//
//

class Command {
    var model: Model!

    init() {
        fatalError("subclass has to override method")
    }

    func execute() {
        fatalError("subclass has to override method")
    }
}
