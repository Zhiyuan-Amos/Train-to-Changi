// Stores the stuff that changes during Level execution
struct LevelState {
    var inputs: [Int]
    var memoryValues: [Int?]

    var outputs: [Int] = []
    var personValue: Int?
    var runState: RunState = .paused
    var numSteps: Int = 0
    var programCounter: Int?

    init(inputs: [Int], memoryValues: [Int?]) {
        self.inputs = inputs
        self.memoryValues = memoryValues
    }
}
