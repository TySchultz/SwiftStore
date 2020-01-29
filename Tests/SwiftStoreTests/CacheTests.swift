import XCTest
@testable import SwiftStore

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
    let first = MockedTestObject()
    let second = MockedTestObject.modifiedObject(id: "second")

    let store = Cache<String,MockedTestObject>()

    // When
    store.insert(first, forKey: first.id)
    store.insert(second, forKey: second.id)

    // Then
    let firstResult = store[first.id]
    let secondResult = store[second.id]
    XCTAssertEqual(firstResult, first)
    XCTAssertEqual(secondResult, second)
  }

  func testOverwriteValue() {
    // Given
    let arrayFirst = ["first","second","third"]
    let arraySecond = ["first","second","third"]

    let key = "first"
    let store = Cache<String,[String]>()

    // When
    store.insert(arrayFirst, forKey: key)
    store.insert(arraySecond, forKey: key)

    // Then
    let result = store[key]
    XCTAssertEqual(result, arraySecond)
  }

  func testEntryExpired(){
    // Given
    let arrayFirst = ["first","second","third"]

    let key = "first"
    let store = Cache<String,[String]>(entryLifetime: -100)

    // When
    store.insert(arrayFirst, forKey: key)

    // Then
    let result = store[key]
    XCTAssertEqual(result, nil)
  }

  func testEmptyValue() {
    // Given
    let key = "first"
    let store = Cache<String,MockedTestObject>()

    // When
    // Leave store empty

    // Then
    let result = store[key]
    XCTAssertEqual(result, nil)
  }

  func testExpiredCache() {

  }

  func testMultipleSaves() {

  }

  func testRemoveValue() {
    // Given
    let object = MockedTestObject()
    let store = Cache<String,MockedTestObject>()

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

}
