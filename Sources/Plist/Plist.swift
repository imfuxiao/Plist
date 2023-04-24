import Foundation

enum PlistError: Error {
  case invalidType // 无效的类型
}

@dynamicMemberLookup
public enum Plist {
  indirect case dictionary(NSDictionary)
  indirect case array(NSArray)
  indirect case value(Any)
  case none

  public init(_ dict: NSDictionary) {
    self = .dictionary(dict)
  }

  public init(_ array: NSArray) {
    self = .array(array)
  }

  public init(_ value: Any) {
    self = Plist.wrap(value)
  }

  /// wraps a given object to a Plist
  static func wrap(_ obj: Any?) -> Plist {
    if let dict = obj as? NSDictionary {
      return .dictionary(dict)
    }

    if let array = obj as? NSArray {
      return .array(array)
    }

    if let value = obj {
      return .value(value)
    }

    return .none
  }
}

public extension Plist {
  /// 尝试转换为T类型
  func cast<T>() -> T? {
    switch self {
    case let .value(value):
      return value as? T
    default:
      return nil
    }
  }

  var string: String? {
    return cast()
  }

  var int: Int? {
    return cast()
  }

  var double: Double? {
    return cast()
  }

  var float: Float? {
    return cast()
  }

  var date: Date? {
    return cast()
  }

  var data: Data? {
    return cast()
  }

  var number: NSNumber? {
    return cast()
  }

  var bool: Bool? {
    return cast()
  }

  var value: Any? {
    switch self {
    case let .value(value):
      return value
    case let .dictionary(dict):
      return dict
    case let .array(array):
      return array
    case .none:
      return nil
    }
  }

  var array: NSArray? {
    switch self {
    case let .array(array):
      return array
    default:
      return nil
    }
  }

  var dict: NSDictionary? {
    switch self {
    case let .dictionary(dict):
      return dict
    default:
      return nil
    }
  }
}

// MARK: initialize from a path

public extension Plist {
  init(path: URL) {
    guard let rawData = try? Data(contentsOf: path) else {
      self = .none
      return
    }
    self.init(data: rawData)
  }

  init(data rawData: Data) {
    if let dict = try?
      PropertyListSerialization.propertyList(from: rawData, format: nil) as? NSDictionary
    {
      self = .dictionary(dict)
      return
    }

    if let array = try?
      PropertyListSerialization.propertyList(from: rawData, format: nil) as? NSArray
    {
      self = .array(array)
      return
    }

    self = .none
  }

  func toData() throws -> Data {
    var plist: Any
    switch self {
    case let .dictionary(dict):
      plist = dict
    case let .array(array):
      plist = array
    default:
      throw PlistError.invalidType
    }
    return try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: .zero)
  }

  func write(path: URL) throws {
    try toData().write(to: path)
  }
}

public extension Plist {
  subscript(dynamicMember member: String) -> Plist {
    if let index = Int(member) {
      return self[index]
    }
    return self[member]
  }

  subscript(key: String) -> Plist {
    switch self {
    case let .dictionary(dict):
      let v = dict.object(forKey: key)
      return Plist.wrap(v)
    default:
      return .none
    }
  }

  subscript(index: Int) -> Plist {
    switch self {
    case let .array(array):
      if index >= 0, index < array.count {
        return Plist.wrap(array[index])
      }
      return .none
    default:
      return .none
    }
  }
}

extension Plist: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .dictionary(dict):
      return "(dict: \(dict)"
    case let .array(array):
      return "(array: \(array)"
    case let .value(value):
      return "(value: \(value)"
    case .none:
      return "(none)"
    }
  }
}
