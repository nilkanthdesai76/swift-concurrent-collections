import XCTest
@testable import ConcurrentCollections

final class ConcurrentCollectionsTests: XCTestCase {
    func testThreadSafeDictionaryBasics() {
        let dict = ThreadSafeDictionary<String, Int>()
        dict["one"] = 1
        dict["two"] = 2
        dict["three"] = 3

        XCTAssertEqual(dict.count, 3)
        XCTAssertEqual(dict["two"], 2)

        let filtered = dict.filter { $1 > 1 }
        XCTAssertEqual(filtered.count, 2)

        dict.removeValue(forKey: "one")
        // Allow barrier async to execute
        let exp = expectation(description: "Wait for removal")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertNil(dict["one"])
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testThreadSafeArrayBasics() {
        let array = ThreadSafeArray<Int>()
        for i in 1...5 {
            array.append(i)
        }

        let exp = expectation(description: "Wait for array appends")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertEqual(array.count, 5)
            XCTAssertEqual(array.first, 1)
            XCTAssertEqual(array[2], 3)
            XCTAssertNil(array[99]) // Out of bounds safety

            let evens = array.filter { $0 % 2 == 0 }
            XCTAssertEqual(evens, [2, 4])
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.5)
    }

    func testAtomicPropertyWrapper() {
        @Atomic var counter: Int = 0

        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            $counter.mutate { $0 += 1 }
        }

        XCTAssertEqual(counter, 100)
    }

    func testMultipleEqualityOperator() {
        let value = 5
        let allFives = [5, 5, 5]
        let mixed = [5, 4, 5]

        XCTAssertTrue(value && allFives)
        XCTAssertFalse(value && mixed)

        let nilVal: Int? = nil
        let nilArr: [Int]? = nil
        XCTAssertTrue(nilVal && nilArr)
    }
}
