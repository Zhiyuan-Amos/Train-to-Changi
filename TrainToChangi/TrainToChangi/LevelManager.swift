//
// Created by Yong Lin Han on 22/3/17.
// Copyright (c) 2017 nus.cs3217.a0139655u. All rights reserved.
//

class LevelManager {
    private var levelData: LevelData
    private(set) var level: Level

    init(levelData: LevelData) {
        self.levelData = levelData
        self.level = LevelManager.initLevel(levelData: levelData)
    }

    func loadLevel(levelData: LevelData) {
        self.levelData = levelData
        self.level = LevelManager.initLevel(levelData: levelData)
    }

    // Returns random inputs for the current level, and the expected outputs
    // for these inputs.
    func randomizeInputsOutputs() -> ([Int], [Int]) {
        let inputs = levelData.randomInputs
        let outputs = levelData.algorithm(inputs: inputs)
        return (inputs, outputs)
    }

    // This really doesn't have to be static, but xcode complains.
    // Cannot use a instance func before initialising Level attribute.
    // Unless we make Level optional.
    static private func initLevel(levelData: LevelData) -> Level {
        let levelName = levelData.levelName
        let inputsShownToUser = levelData.randomInputs
        let availableCommands = levelData.availableCommands
        let levelDescriptor = levelData.levelDescription
        let expectedOutputs = levelData.algorithm(inputs: inputsShownToUser)

        let initialState = LevelState(inputs: inputsShownToUser,
                                      outputs: [],
                                      memoryValues: levelData.memoryValues,
                                      personValue: nil,
                                      currentCommands: [])

        return Level(levelName: levelName,
                     initialState: initialState,
                     availableCommands: availableCommands,
                     levelDescriptor: levelDescriptor,
                     expectedOutputs: expectedOutputs)
    }
}
