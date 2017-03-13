//

import Foundation
class LogicManager {
    var model: Model
    var undoStack: Stack<State>
    var redoStack: Stack<Command>

    init(model: Model) {
        self.model = model
        self.undoStack = Stack()
        self.redoStack = Stack()
    }

    func executeCommands(commands: [Command]) {
        var pointer = 0
        // while game state not lost and and game not ended
        let state = State(inputConveyorBelt: model.inputConveyorBelt,
                          outputConveyorBelt: model.outputConveyorBelt,
                          person: model.person, memoryValues: model.memory,
                          pointerIndex: pointer)
        undoStack.push(state)
        commands[pointer].execute()
        pointer += 1
    }

    func undo() {
        guard let state = undoStack.pop() else {
            return
        }

        revertGameState(state)

        if undoStack.isEmpty {
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "undoStackIsEmpty"), object: nil, userInfo: nil)
        }
    }

    func redo() {
        guard let command = redoStack.pop() else {
            return
        }

        command.execute()

        if redoStack.isEmpty {
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "redoStackIsEmpty"), object: nil, userInfo: nil)
        }
    }

    private func revertGameState(_ state: State) {
        model.inputConveyorBelt = state.inputConveyorBelt
        model.outputConveyorBelt = state.outputConveyorBelt
        model.person = state.person
    }
}
