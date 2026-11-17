import os

final class Locked<Value: Sendable>: Sendable {
    private let lock: OSAllocatedUnfairLock<Value?>

    init() {
        lock = OSAllocatedUnfairLock(initialState: nil)
    }

    var value: Value? {
        get { lock.withLock { $0 } }
        set { lock.withLock { $0 = newValue } }
    }
}
