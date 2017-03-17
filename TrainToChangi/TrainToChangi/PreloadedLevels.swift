struct PreloadedLevels {
    // Struct is not meant to be initialised
    private init() {}

    static let allLevels = [levelOne]

    static let levelOne = Level(stationName: levelOneStationName,
                                initialState: levelOneInitialState,
                                commandTypes: levelOneCommandTypes,
                                levelDescriptor: levelOneLevelDescriptor,
                                algorithm: levelOneAlgo)

    static let levelOneStationName = "Introduction"
    static let levelOneInitialState = StationState(inputValues: [1, 2, 3],
                                                   output: [], memoryValues: [nil, nil])
    static let levelOneCommandTypes: [CommandType] = [.inbox, .outbox]
    static let levelOneLevelDescriptor = "Drag commands into this area to build a program.\n\n" +
        "Your program should tell your worker to grab each thing from the INBOX, " +
        "and drop it into the OUTBOX."
    static func levelOneAlgo(values: [Int]) -> [Int] {
        var sum = 0
        for value in values {
            sum += value
        }

        return [sum]
    }

}
