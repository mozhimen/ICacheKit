// The Swift Programming Language
// https://docs.swift.org/swift-book
/// 自动使用变量名作为 UserDefaults 的 Key
import SwiftUI
import SUtilKit_SwiftUI


@propertyWrapper
public struct CacheKAppStorage<Value> {
    private let _defaultValue: Value
    private var _key: String?
    private var _storage: AppStorage<Value>?
    
    //=============================================================>
    
    public init(wrappedValue defaultValue: Value) {
        self.init(wrappedValue: defaultValue, nil)
    }
    
    init(wrappedValue defaultValue: Value, _ key: String?) {
        self._defaultValue = defaultValue
        self._key = key
    }
    
    //=============================================================>
    
    public var wrappedValue: Value {
        get { fatalError("NamedAppStorage should only be used with ObservableObject properties") }
        set { fatalError("NamedAppStorage should only be used with ObservableObject properties") }
    }
    
    //=============================================================>
    
    public static subscript<T: ObservableObject>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].ensureStorage(for: instance, keyPath: wrappedKeyPath).wrappedValue
        }
        set {
            instance[keyPath: storageKeyPath].ensureStorage(for: instance, keyPath: wrappedKeyPath).wrappedValue = newValue
        }
    }
    
    private mutating func ensureStorage<T: ObservableObject>(for instance: T, keyPath: ReferenceWritableKeyPath<T, Value>) -> AppStorage<Value> {
        if _storage == nil {
            let key = _key ?? {
                let mirror = Mirror(reflecting: instance)
                let propertyName = String("\(keyPath)".split(separator: ".").last!)
                return propertyName
            }()
            _key = key
            _storage = createAppStorage(for: _defaultValue, key: _key!)
        }
        return _storage!
    }
    
    private func createAppStorage(for value: Value, key: String) -> AppStorage<Value> {
        switch value {
        case let int as Int:
            return AppStorage(wrappedValue: int, key) as! AppStorage<Value>
        case let string as String:
            return AppStorage(wrappedValue: string, key) as! AppStorage<Value>
        case let bool as Bool:
            return AppStorage(wrappedValue: bool, key) as! AppStorage<Value>
        case let double as Double:
            return AppStorage(wrappedValue: double, key) as! AppStorage<Value>
        case let url as URL:
            return AppStorage(wrappedValue: url, key) as! AppStorage<Value>
        case let data as Data:
            return AppStorage(wrappedValue: data, key) as! AppStorage<Value>
        default:
            fatalError("Unsupported type for AppStorage")
        }
    }
}


