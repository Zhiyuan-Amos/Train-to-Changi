import Foundation

// Contains fields that changes during Level execution.
struct LevelState {
    var inputs: [Int]
    var memoryValues: [Int?]
    var outputs: [Int] = []
    var personValue: Int?

    var runState: RunState = .start
    var numSteps: Int = 0
    private let timeBegan: Date = .init()
    var timeElapsed: TimeInterval {
        return Date().timeIntervalSince(timeBegan)
    }

    var numLost: Int = 0

    init(inputs: [Int], memoryValues: [Int?]) {
        self.inputs = inputs
        self.memoryValues = memoryValues
    }
}
