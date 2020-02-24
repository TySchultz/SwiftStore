import XCTest
@testable import SwiftStore
import AES256CBC
final class CacheTests: XCTestCase {

  static var allTests = [
    ("testSingleSave", testSingleSave),
  ]


  static func MockedDate() -> Date {
    let dateString       = "2020-01-01T00:00:00"
    let formatter        = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
    return formatter.date(from: dateString) ?? Date()
  }

  struct MockedTestObject: Codable, Equatable {
    var id: String     = "testString"
    var boolTest: Bool = false
    var count: Int     = 7
    var number: Float  = 4.7

    static func modifiedObject(id: String? = nil, boolTest: Bool? = nil, count: Int? = nil, number: Float? = nil) -> MockedTestObject {
      var testObject = MockedTestObject()
      testObject.id       = id ?? testObject.id
      testObject.boolTest = boolTest ?? testObject.boolTest
      testObject.count    = count ?? testObject.count
      testObject.number   = number ?? testObject.number
      return testObject
    }
  }

  // MARK: Basic Operations

  func testSingleSave() {
    // Given
    let test = MockedTestObject()
    let store = Cache<String,MockedTestObject>()

    // When
    store.insert(test, forKey: test.id)

    // Then
    let result = store[test.id]
    XCTAssertEqual(result, test)
  }

  func testSavingMultipleValues() {
    // Given
    let first  = MockedTestObject()
    let second = MockedTestObject.modifiedObject(id: "second")
    let store  = Cache<String,MockedTestObject>()

    // When
    store.insert(first, forKey: first.id)
    store.insert(second, forKey: second.id)

    // Then
    let firstResult  = store[first.id]
    let secondResult = store[second.id]
    XCTAssertEqual(firstResult, first)
    XCTAssertEqual(secondResult, second)
  }

  func testOverwriteValue() {
    // Given
    let first  = MockedTestObject()
    let second = MockedTestObject.modifiedObject(count: 1)
    let store  = Cache<String,MockedTestObject>()

    // When
    store.insert(first, forKey: first.id)

    // Then
    guard let result: MockedTestObject = store[first.id] else {
      XCTFail()
      return
    }
    XCTAssertEqual(result.count, 7)

    // When
    store.insert(second, forKey: second.id)

    // Then
    guard let secondResult: MockedTestObject = store[second.id] else {
      XCTFail()
      return
    }
    XCTAssertEqual(secondResult.count, 1)
  }

  func testEntryExpired(){
    // Given
    let object = MockedTestObject()
    let store  = Cache<String,MockedTestObject>(entryLifetime: -100)

    // When
    store.insert(object, forKey: object.id)

    // Then
    let secondResult = store[object.id]
    XCTAssertEqual(secondResult, nil)
  }

  func testEmptyValue() {
    // Given
    let key   = "first"
    let store = Cache<String,MockedTestObject>()

    // When
    // Leave store empty

    // Then
    let result = store[key]
    XCTAssertEqual(result, nil)
  }

  func testExpiredCache() {
    //TODO: Do this
  }


  // MARK: Removal

  func testRemoveValue() {
    // Given
    let object = MockedTestObject()
    let store  = Cache<String,MockedTestObject>()

    // When
    store.insert(object, forKey: object.id)

    // Then
    let result = store[object.id]
    XCTAssertEqual(result, object)

    // When
    store.removeValue(forKey: object.id)

    // Then
    let emptyResult = store[object.id]
    XCTAssertEqual(emptyResult, nil)
  }

  func testRemoveAll() {
    // Given
    let first  = MockedTestObject()
    let second = MockedTestObject.modifiedObject(id: "second")
    let store  = Cache<String,MockedTestObject>()

    // When
    store.insert(first, forKey: first.id)
    store.insert(second, forKey: second.id)

    // Then
    let firstResult  = store[first.id]
    let secondResult = store[second.id]
    XCTAssertEqual(firstResult, first)
    XCTAssertEqual(secondResult, second)

    // When
    store.removeAll()

    // Then
    let emptyResultFirst  = store[first.id]
    let emptyResultSecond = store[second.id]
    XCTAssertEqual(emptyResultFirst, nil)
    XCTAssertEqual(emptyResultSecond, nil)
  }

  // MARK: Persistance

  func testSaveToDisk() {
    // Given
    let generatedPassword = AES256CBC.generatePassword()
    let test = MockedTestObject()
    let store = Cache<String,MockedTestObject>()

    // When
    store.insert(test, forKey: test.id)
    try! store.saveToDisk(as: "MainCache", password: generatedPassword)

    let newStore = try! Cache<String,MockedTestObject>.loadFromDisk(for: "MainCache", password: generatedPassword)
    // Then
    let result = newStore[test.id]
    XCTAssertEqual(result, test)
  }

  func testSaveToDiskWrongName() {
    // Given
    let generatedPassword = AES256CBC.generatePassword()
    let test = MockedTestObject()
    let store = Cache<String,MockedTestObject>()

    // When
    store.insert(test, forKey: test.id)
    try! store.saveToDisk(as: "MainCache", password: generatedPassword)

    // Then
    do {
      // Cache Initalization should fail
      let _ = try Cache<String,MockedTestObject>.loadFromDisk(for: "WrongCache", password: generatedPassword)
      XCTFail()
    } catch {

    }
    XCTAssert(true)

  }

  func testSaveToDiskWrongPassword() {
    // Given
    let generatedPassword = AES256CBC.generatePassword()
    let test = MockedTestObject()
    let store = Cache<String,MockedTestObject>()

    // When
    store.insert(test, forKey: test.id)
    try! store.saveToDisk(as: "MainCache", password: generatedPassword)

    let newStore = try! Cache<String,MockedTestObject>.loadFromDisk(for: "MainCache", password: AES256CBC.generatePassword())
    // Then
    let result = newStore[test.id]
    XCTAssertEqual(result, nil)
  }

  func testLoadDiskEmpty() {
    // Given

    // When
    do {
      // Cache Initalization should fail
      let _ = try Cache<String,MockedTestObject>.loadFromDisk(for: "Cache",
                                                              password: AES256CBC.generatePassword())
      XCTFail()
    } catch {

    }
    XCTAssert(true)
  }

  func testPerformanceOnSave() {
    // Given
    let range = 0...100
    let objects: [MockedTestObject] = range.map { _ in MockedTestObject() }
    let store = Cache<String, [MockedTestObject]>()
    let now = Date()

    // When
    store.insert(objects, forKey: "key")

      do {
        try store.saveToDisk(as: "MainCache", password: AES256CBC.generatePassword())
      } catch {
        XCTFail()
      }
    let interval = Date().timeIntervalSince(now)
    print("***" , Date().timeIntervalSince(now))
    print("***" , interval / Double(range.count))


    // Then
    let result = store["key"]
    XCTAssertEqual(result, objects)
    XCTAssert(true)
  }

  func testPerformanceMultipleKeys() {
    // Given
    let generatedPassword = AES256CBC.generatePassword()
    let range = 0...1000
    let objects: [MockedTestObject] = range.map { index in
      return MockedTestObject.modifiedObject(id: String(index))
    }
    let store = Cache<String, MockedTestObject>()
    let now = Date()

    // When
    for object in objects {
      store.insert(object, forKey: object.id)
      do {
        try store.saveToDisk(as: "SecondCache", password: generatedPassword)
      } catch {
        XCTFail()
      }
    }

    let interval = Date().timeIntervalSince(now)
    print("***" , Date().timeIntervalSince(now))
    print("***" , interval / Double(range.count))

    // Then
    XCTAssert(true)
  }

  func testPerformanceSavingWithoutEncryption() {
    // Given
    let range = 0...100000
    let objects: [MockedTestObject] = range.map { _ in MockedTestObject() }
    let store = Cache<String, [MockedTestObject]>()
    let now = Date()

    // When
    store.insert(objects, forKey: "key")

    do {
      try store.saveToDisk(as: "MainCache", password: AES256CBC.generatePassword(), encrypted: false)
    } catch {
      XCTFail()
    }

    let interval = Date().timeIntervalSince(now)
    print("***" , Date().timeIntervalSince(now))
    print("***" , interval / Double(range.count))

    // Then
    XCTAssert(true)
  }

//  func testPerformanceManySaves() {
//
//
//    for object in objects {
//      insert
//      ssave
//    }
//  }

}
