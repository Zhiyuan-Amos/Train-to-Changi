//
// Manages the logic required to update the model when commands are executed.
//

import Foundation
class LogicManager {
    private var model: Model

    init(model: Model) {
        self.model = model
    }

    // Executes the list of commands in `model.commands`.
    func executeCommands() {
        var commandIndex = 0

        let commands = model.getCurrentCommands()
        while model.getRunState() == .running {
            let commandResult = commands[commandIndex].execute()
            if let errorMessage = commandResult.errorMessage {
                model.updateRunState(to: .lost)

                NotificationCenter.default.post(name: Notification.Name(
                    rawValue: "gameLost"), object: errorMessage, userInfo: nil)
                break
            }

            commandIndex += 1
        }
    }

    // Reverts the state of the model by one command execution backward.
    func undo() {
        do {
            try model.undo()
        } catch {
            fatalError("User should not be allowed to undo")
        }

        //TODO: notify if undo stack is empty - shift to ModelManager?
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "nothingToUndo"), object: nil, userInfo: nil)

        NotificationCenter.default.post(name: Notification.Name(
            rawValue: "nonEmptyRedoStack"), object: nil, userInfo: nil)
    }

    // Reverts the state of the model by one command execution forward.
    func redo() {
        do {
            try model.redo()
        } catch {
            fatalError("User should not be allowed to redo")
        }

        //TODO: notify if redo stack is empty - shift to ModelManager?
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "nothingToRedo"), object: nil, userInfo: nil)

        NotificationCenter.default.post(name: Notification.Name(
            rawValue: "undoStackIsNotEmpty"), object: nil, userInfo: nil)
    }
}
