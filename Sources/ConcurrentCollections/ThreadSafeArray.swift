import Foundation

/// A thread-safe, concurrent array utilizing a barrier dispatch queue for thread synchronization.
public final class ThreadSafeArray<Element>: @unchecked Sendable {
    private var storage: [Element]
    private let queue: DispatchQueue

    public init(label: String = "com.nilkanth.threadSafeArray") {
        self.storage = []
        self.queue = DispatchQueue(label: label, attributes: .concurrent)
    }

    public var count: Int {
        queue.sync { storage.count }
    }

    public var isEmpty: Bool {
        queue.sync { storage.isEmpty }
    }

    public var first: Element? {
        queue.sync { storage.first }
    }

    public var last: Element? {
        queue.sync { storage.last }
    }

    public var allElements: [Element] {
        queue.sync { Array(storage) }
    }

    public subscript(index: Int) -> Element? {
        get {
            queue.sync {
                guard index >= 0 && index < storage.count else { return nil }
                return storage[index]
            }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                guard let self = self, let newValue = newValue else { return }
                if index >= 0 && index < self.storage.count {
                    self.storage[index] = newValue
                } else if index == self.storage.count {
                    self.storage.append(newValue)
                }
            }
        }
    }

    public func append(_ element: Element) {
        queue.async(flags: .barrier) { [weak self] in
            self?.storage.append(element)
        }
    }

    @discardableResult
    public func remove(at index: Int) -> Element? {
        var removed: Element?
        queue.sync(flags: .barrier) {
            if index >= 0 && index < storage.count {
                removed = storage.remove(at: index)
            }
        }
        return removed
    }

    public func removeAll() {
        queue.async(flags: .barrier) { [weak self] in
            self?.storage.removeAll()
        }
    }

    public func filter(_ isIncluded: (Element) -> Bool) -> [Element] {
        queue.sync {
            storage.filter(isIncluded)
        }
    }
}
