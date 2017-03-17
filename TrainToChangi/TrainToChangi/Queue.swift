//
// Queue Data Structure: Copied from raywenderlich
//

struct Queue<T> {
    private var array = [T]()

    init() {}

    init(array: [T]) {
        self.array = array
    }

    var count: Int {
        return array.count
    }

    var isEmpty: Bool {
        return array.isEmpty
    }

    mutating func enqueue(_ element: T) {
        array.append(element)
    }

    mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }

    var front: T? {
        return array.first
    }

    var toArray: [T] {
        return array
    }
}
