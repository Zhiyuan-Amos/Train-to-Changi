//
// Created by Yong Lin Han on 22/3/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

// Manages the LevelState in Model, by initialising the state
// with `LevelData`.
class LevelManager {
    private var levelData: LevelData
    private(set) var level: Level! // use ! to silence xcode use of self in init

    init(levelData: LevelData) {
        self.levelData = levelData
        self.level = initLevel(levelData: levelData)
    }

    // Returns inputs for the current level, and the expected outputs
    // for these inputs.
    // If called on a level with random inputs, every call will re-randomize
    // the inputs.
    func getInputsOutputs() -> ([Int], [Int]) {
        let inputs = levelData.inputs
        let outputs = levelData.algorithm(inputs: inputs)
        return (inputs, outputs)
    }

    private func initLevel(levelData: LevelData) -> Level {
        let levelName = levelData.levelName
        let inputsShownToUser = levelData.inputs
        let availableCommands = levelData.availableCommands
        let memoryLayout = levelData.memoryLayout
        let levelDescriptor = levelData.levelDescription
        let expectedOutputs = levelData.algorithm(inputs: inputsShownToUser)

        let initialState = LevelState(inputs: inputsShownToUser,
                                      memoryValues: levelData.memoryValues)

        return Level(levelName: levelName,
                     initialState: initialState,
                     availableCommands: availableCommands,
                     memoryLayout: memoryLayout,
                     levelDescriptor: levelDescriptor,
                     expectedOutputs: expectedOutputs)
    }
}
