// Stores the stuff that changes during Level execution
struct LevelState {
    var inputs: [Int]
    var memoryValues: [Int?]

    var outputs: [Int] = []
    var personValue: Int?
    var runState: RunState = .start
    var numSteps: Int = 0

    init(inputs: [Int], memoryValues: [Int?]) {
        self.inputs = inputs
        self.memoryValues = memoryValues
    }
}
