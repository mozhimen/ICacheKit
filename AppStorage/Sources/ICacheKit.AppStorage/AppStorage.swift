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
                let key = mirror.children.first { $0.label == keyPath.propertyName }?.label ?? keyPath.propertyName
                _key = key
                return key
            }()
            _storage = switch _defaultValue{
            case is Int:
                AppStorage(wrappedValue: _defaultValue as! Int, key) as? AppStorage<Value>
            case is String:
                AppStorage(wrappedValue: _defaultValue as! String, key) as? AppStorage<Value>
            case is Bool:
                AppStorage(wrappedValue: _defaultValue as! Bool, key) as? AppStorage<Value>
            case is Double:
                AppStorage(wrappedValue: _defaultValue as! Double, key) as? AppStorage<Value>
            case is URL:
                AppStorage(wrappedValue: _defaultValue as! URL, key) as? AppStorage<Value>
            case is Data:
                AppStorage(wrappedValue: _defaultValue as! Data, key) as? AppStorage<Value>
            default:
                fatalError()
            }
        }
        return _storage!
    }
}
