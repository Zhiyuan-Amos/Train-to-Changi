struct PreloadedLevels {
    // Struct is not meant to be initialised
    private init() {}

    static let allLevels = [levelOne]

    static let levelOne = Level(levelName: levelOneStationName,
                                initialState: levelOneInitialState,
                                availableCommands: levelOneCommandEnum,
                                levelDescriptor: levelOneLevelDescriptor,
                                algorithm: levelOneAlgo)

    static let levelOneStationName = "Introduction"
    static let levelOneInitialState = LevelState(inputs: [1, 2, 3],
    static let levelOneCommandTypes: [CommandEnum] = [.outbox, .jump(targetIndex: nil), .inbox,
                                                      .add(memoryIndex: nil), .copyTo(memoryIndex: nil),
                                                      .copyFrom(memoryIndex: nil)]

    static let levelOneLevelDescriptor = "Drag commands into this area to build a program.\n\n" +
        "Your program should tell your worker to grab each thing from the INBOX, " +
        "and drop it into the OUTBOX."
    static func levelOneAlgo(values: [Int]) -> [Int] {
        return values
    }

}
