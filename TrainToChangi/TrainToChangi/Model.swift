//

protocol Model {
    var inputConveyorBelt: Queue<Int> { get set }
    var outputConveyorBelt: [Int] { get set }
    var memory: [Int?] { get set }
    var person: Int? { get set }
}
