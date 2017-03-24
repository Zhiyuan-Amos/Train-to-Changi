//
// Created by Yong Lin Han on 22/3/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

class LevelManager {
    private var levelData: LevelData
    private(set) var level: Level! // use ! to silence xcode use of self in init

    init(levelData: LevelData) {
        self.levelData = levelData
        self.level = initLevel(levelData: levelData)
    }

    // Returns random inputs for the current level, and the expected outputs
    // for these inputs.
    func randomizeInputsOutputs() -> ([Int], [Int]) {
        let inputs = levelData.randomInputs
        let outputs = levelData.algorithm(inputs: inputs)
        return (inputs, outputs)
    }

    private func initLevel(levelData: LevelData) -> Level {
        let levelName = levelData.levelName
        let inputsShownToUser = levelData.randomInputs
        let availableCommands = levelData.availableCommands
        let levelDescriptor = levelData.levelDescription
        let expectedOutputs = levelData.algorithm(inputs: inputsShownToUser)

        let initialState = LevelState(inputs: inputsShownToUser,
                                      memoryValues: levelData.memoryValues)

        return Level(levelName: levelName,
                     initialState: initialState,
                     availableCommands: availableCommands,
                     levelDescriptor: levelDescriptor,
                     expectedOutputs: expectedOutputs)
    }
}
