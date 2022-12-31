import Foundation

@propertyWrapper
public struct PlistWrapper {
  private var value: Plist
  public init(path: URL) {
    self.value = Plist(path: path)
  }
  
  public var wrappedValue: Plist {
    get {
      return value
    }
    set {
      self.value = newValue
    }
  }
}

@propertyWrapper
public struct PlistPropertyWrapper<Value> {
    var plist: Plist
    let propertyName: String
    
    public init(plist: Plist, propertyName: String) {
        self.plist = plist
        self.propertyName = propertyName
    }
    
    public var wrappedValue: Value? {
        get {
          let names = propertyName.split(separator: ".")
          var plist = self.plist
          for name in names {
            plist = plist[String(name)]
          }
          return plist.cast()
        }
    }
}
