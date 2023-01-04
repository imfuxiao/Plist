import Foundation
@testable import Plist
import XCTest

final class PlistTests: XCTestCase {
  func testDict() throws {
    let plist = Plist(["name": "Plist", "version": 1.1, "status": "deploy"])
    XCTAssertEqual(plist.name.string, "Plist")
    XCTAssertEqual(plist.version.double, 1.1)
  }

  func testArray() throws {
    let plist = Plist([1, 2, 3, 4, 5, 6])
    XCTAssertEqual(plist[0].int, 1)
    XCTAssertEqual(plist.0.int, 1)
    XCTAssertEqual(plist[5].int, 6)
    XCTAssertEqual(plist.5.int, 6)
  }

  func testDictFile() throws {
    let url = Bundle.module.url(forResource: "testDict", withExtension: "plist", subdirectory: "Resources")!
    let plist = Plist(path: url)

    guard case .dictionary = plist else {
      XCTAssert(false, "plist init testDict.plist error")
      return
    }
    XCTAssertEqual(plist.a.string, "+")
    XCTAssertEqual(plist.n.string, ".")
    XCTAssertEqual(plist.z.string, "#撤销上屏")
    XCTAssertEqual(plist.x.a.string, "=")
    XCTAssertEqual(plist.x.num.int, 234)
  }

  func testArrayFile() throws {
    let url = Bundle.module.url(forResource: "testArray", withExtension: "plist", subdirectory: "Resources")!
    let plist = Plist(path: url)

    guard case .array = plist else {
      XCTAssert(false, "plist init testArray.plist error")
      return
    }
    XCTAssertEqual(plist[0].string, "+")
  }
  
  func testWriteDictFile() throws {
    let url = Bundle.module.url(forResource: "testDict", withExtension: "plist", subdirectory: "Resources")!
    let plist = Plist(path: url)
    
    guard case .dictionary = plist else {
      XCTAssert(false, "plist init testDict.plist error")
      return
    }
    
    let catchDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    print(catchDirectory.description)
    let writeUrl = catchDirectory.appending(component: "test.plist", directoryHint: .notDirectory)
    try plist.write(path: writeUrl)
  }
  
  func testPlistWrapper() throws {
    @PlistWrapper(path: Bundle.module.url(forResource: "testDict", withExtension: "plist", subdirectory: "Resources")!)
    var plist: Plist
    XCTAssertEqual(plist.a.string, "+")
    
    @PlistPropertyWrapper(plist: plist, propertyName: "a")
    var a: String?
    XCTAssertEqual(a, "+")

    @PlistPropertyWrapper(plist: plist, propertyName: "num")
    var num1: Int?
    XCTAssertEqual(num1, 123)
    
    @PlistPropertyWrapper(plist: plist, propertyName: "x.num")
    var num2: Int?
    XCTAssertEqual(num2, 234)
  }
}
