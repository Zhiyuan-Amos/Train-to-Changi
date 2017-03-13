//

class AddCommand: Command {
    let memoryIndex: Int

    init(memoryIndex: Int) {
        self.memoryIndex = memoryIndex
    }

    override func execute() {
        // TODO: Signal error
        guard let value = model.memory[memoryIndex], model.person != nil else {
            return
        }

        model.person! += value
    }
}
