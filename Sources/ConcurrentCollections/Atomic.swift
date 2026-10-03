import Foundation

/// A property wrapper that ensures atomic thread-safe access to an underlying value.
@propertyWrapper
public final class Atomic<Value>: @unchecked Sendable {
    private var value: Value
    private let lock = NSLock()

    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    public var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            value = newValue
            lock.unlock()
        }
    }

    /// Mutates the wrapped value atomically within a closure.
    @discardableResult
    public func mutate<Result>(_ mutation: (inout Value) throws -> Result) rethrows -> Result {
        lock.lock()
        defer { lock.unlock() }
        return try mutation(&value)
    }
}

// MARK: - Multiple Equality Helper

/// Evaluates if an optional value matches all elements in an array.
public func && <T: Equatable>(lhs: T?, rhs: [T]?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return !r.contains(where: { $0 != l })
    case (nil, nil):
        return true
    default:
        return false
    }
}
