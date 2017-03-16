//
// Stack Data Structure: Copied from raywenderlich
//

struct Stack<T> {
    fileprivate var array = [T]()

    var isEmpty: Bool {
        return array.isEmpty
    }

    var count: Int {
        return array.count
    }

    mutating func push(_ element: T) {
        array.append(element)
    }

    mutating func pop() -> T? {
        return array.popLast()
    }

    var top: T? {
        return array.last
    }
}

extension Stack: Sequence {
    func makeIterator() -> AnyIterator<T> {
        var curr = self
        return AnyIterator {_ -> T? in
            return curr.pop()
        }
    }
}
