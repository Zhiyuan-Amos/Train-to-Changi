//

class State {
    let inputConveyorBelt: Queue<Int>
    let outputConveyorBelt: [Int]
    let memoryValues: [Int?]
    let person: Int?
    let pointerIndex: Int

    init(inputConveyorBelt: Queue<Int>, outputConveyorBelt: [Int], person: Int?,
         memoryValues: [Int?], pointerIndex: Int) {
        self.inputConveyorBelt = inputConveyorBelt
        self.outputConveyorBelt = outputConveyorBelt
        self.person = person
        self.memoryValues = memoryValues
        self.pointerIndex = pointerIndex
    }
}
