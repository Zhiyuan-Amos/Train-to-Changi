//

class ModelState {
    let inputConveyorBelt: Queue<Int>
    let outputConveyorBelt: [Int]
    let memory: [Int?]
    let person: Int?
    let commandIndex: Int?

    init(inputConveyorBelt: Queue<Int>, outputConveyorBelt: [Int], person: Int?,
         memory: [Int?], commandIndex: Int?) {
        self.inputConveyorBelt = inputConveyorBelt
        self.outputConveyorBelt = outputConveyorBelt
        self.person = person
        self.memory = memory
        self.commandIndex = commandIndex
    }
}
