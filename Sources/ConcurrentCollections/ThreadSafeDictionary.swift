import Foundation

/// A thread-safe, concurrent dictionary leveraging dispatch barriers for thread synchronization.
public final class ThreadSafeDictionary<Key: Hashable, Element>: @unchecked Sendable {
    private let queue: DispatchQueue
    private var storage: [Key: Element]

    public init(label: String = "com.nilkanth.threadSafeDictionary") {
        self.queue = DispatchQueue(label: label, attributes: .concurrent)
        self.storage = [:]
    }

    public subscript(key: Key) -> Element? {
        get {
            queue.sync {
                storage[key]
            }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.storage[key] = newValue
            }
        }
    }

    public var count: Int {
        queue.sync { storage.count }
    }

    public var isEmpty: Bool {
        queue.sync { storage.isEmpty }
    }

    public var values: [Element] {
        queue.sync { Array(storage.values) }
    }

    public var keys: [Key] {
        queue.sync { Array(storage.keys) }
    }

    public func removeValue(forKey key: Key) {
        queue.async(flags: .barrier) { [weak self] in
            self?.storage.removeValue(forKey: key)
        }
    }

    public func removeAll() {
        queue.async(flags: .barrier) { [weak self] in
            self?.storage.removeAll()
        }
    }

    public func filter(_ isIncluded: (Key, Element) throws -> Bool) rethrows -> [Key: Element] {
        try queue.sync {
            var result: [Key: Element] = [:]
            for (key, value) in storage {
                if try isIncluded(key, value) {
                    result[key] = value
                }
            }
            return result
        }
    }
}
