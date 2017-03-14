//

import Foundation
class LogicManager {
    var model: Model
    var modelState: [ModelState]
    private var gameStatePointer: Int

    init(model: Model) {
        self.model = model
        self.modelState = [ModelState]()
        self.gameStatePointer = 0

        // Stores initial game state
        let state = ModelState(inputConveyorBelt: model.inputConveyorBelt,
                               outputConveyorBelt: model.outputConveyorBelt,
                               person: model.person, memory: model.memory,
                               commandIndex: nil)
        modelState.append(state)
    }

    func executeCommands(commands: [Command]) {
        var i = 0

        while GameState.running {
            let commandResult = commands[i].execute()
            i += 1
            
            // Stores current game state
            let state = ModelState(inputConveyorBelt: model.inputConveyorBelt,
                                   outputConveyorBelt: model.outputConveyorBelt,
                                   person: model.person, memory: model.memory,
                                   commandIndex: i)
            modelState.append(state)
            gameStatePointer = modelState.count - 1
        }
    }

    func undo() {
        gameStatePointer -= 1
        let previousState = modelState[gameStatePointer]
        revertGameState(previousState)

        if gameStatePointer == 0 {
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "nothingToUndo"), object: nil, userInfo: nil)
        }
        NotificationCenter.default.post(name: Notification.Name(
            rawValue: "nonEmptyRedoStack"), object: nil, userInfo: nil)
    }

    func redo() {
        gameStatePointer += 1
        let nextState = modelState[gameStatePointer]
        revertGameState(nextState)

        if gameStatePointer == modelState.count - 1 {
            NotificationCenter.default.post(name: Notification.Name(
                rawValue: "nothingToRedo"), object: nil, userInfo: nil)
        }
        NotificationCenter.default.post(name: Notification.Name(
            rawValue: "undoStackIsNotEmpty"), object: nil, userInfo: nil)
    }

    private func revertGameState(_ state: ModelState) {
        model.inputConveyorBelt = state.inputConveyorBelt
        model.outputConveyorBelt = state.outputConveyorBelt
        model.person = state.person
    }
}
