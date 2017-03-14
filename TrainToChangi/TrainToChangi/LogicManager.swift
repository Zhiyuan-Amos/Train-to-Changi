//

import Foundation
class LogicManager {
    private var model: Model

    init(model: Model) {
        self.model = model
    }

    func executeCommands() {
        var i = 0

        while model.gameState == .running {
            let commandResult = model.commands[i].execute()
            if commandResult.result == .fail {
                model.updateGameState(.lost)
                guard let errorMessage = commandResult.errorMessage else {
                    fatalError("Model did not return error message")
                }

                NotificationCenter.default.post(name: Notification.Name(
                    rawValue: "gameLost"), object: errorMessage, userInfo: nil)
                break
            }

            i += 1

            model.storeStationState()
        }
    }

    func undo() {
        if !model.undo() {
            fatalError("User should not be allowed to undo")
        }
        //TODO: notify if undo stack is empty - shift to ModelManager?
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "nothingToUndo"), object: nil, userInfo: nil)

        NotificationCenter.default.post(name: Notification.Name(
            rawValue: "nonEmptyRedoStack"), object: nil, userInfo: nil)
    }

    func redo() {
        if !model.undo() {
            fatalError("User should not be allowed to redo")
        }
        //TODO: notify if redo stack is empty - shift to ModelManager?
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "nothingToRedo"), object: nil, userInfo: nil)

        NotificationCenter.default.post(name: Notification.Name(
            rawValue: "undoStackIsNotEmpty"), object: nil, userInfo: nil)
    }
}
