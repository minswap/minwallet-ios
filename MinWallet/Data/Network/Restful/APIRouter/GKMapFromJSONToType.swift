import Foundation
import ObjectMapper

public
    extension Mapper
{
    func gk_mapArrayOrNull(JSONObject: Any?) -> [N]? {
        guard JSONObject != nil, !(JSONObject is NSNull)
        else { return [] }
        
        return mapArray(JSONObject: JSONObject)
    }
    
    func gk_map(JSONData: Data) -> N? {
        if let JSON = (try? JSONSerialization.jsonObject(with: JSONData, options: [])) as? [String: Any] {
            return map(JSON: JSON)
        }
        
        return nil
    }
}

public
    class GKMapFromJSONToType<T>: TransformType
{
    public typealias Object = T
    public typealias JSON = Any
    
    private let fromJSON: (Any?) -> T?
    
    public init(fromJSON: @escaping (Any?) -> T?) {
        self.fromJSON = fromJSON
    }
    
    open func transformFromJSON(_ value: Any?) -> T? {
        return fromJSON(value)
    }
    
    open func transformToJSON(_ value: T?) -> JSON? {
        return value
    }
}

public let GKMapFromJSONToDouble = GKMapFromJSONToType<Double>(fromJSON: gk_getDoubleForValue)
public let GKMapFromJSONToInt = GKMapFromJSONToType<Int>(fromJSON: gk_getIntForValue)
public let GKMapFromJSONToString = GKMapFromJSONToType<String>(fromJSON: gk_getStringForValue)
public let GKMapFromJSONToBool = GKMapFromJSONToType<Bool>(fromJSON: gk_getBoolForValue)

public
    class GKMapBetweenJSONAndType<J, T>: TransformType
{
    public typealias Object = T
    public typealias JSON = J
    
    private let fromJSON: (Any?) -> T?
    private let toJSON: (T?) -> J?
    
    public init(fromJSON: @escaping (Any?) -> T?, toJSON: @escaping (T?) -> J?) {
        self.fromJSON = fromJSON
        self.toJSON = toJSON
    }
    
    open func transformFromJSON(_ value: Any?) -> T? {
        return fromJSON(value)
    }
    
    open func transformToJSON(_ value: T?) -> J? {
        return toJSON(value)
    }
}


public func gk_getDoubleForValue(_ input: Any?) -> Double? {
    switch input {
    case let value as Int:
        return Double(value)
    case let value as Double:
        return value
    case let value as String:
        return value.gkDoubleValue
    default:
        return nil
    }
}

public func gk_getIntForValue(_ input: Any?) -> Int? {
    switch input {
    case let value as Int:
        return value
    case let value as Double:
        return Int(value)
    case let value as String:
        return value.gkIntValue
    default:
        return nil
    }
}

public func gk_getStringForValue(_ input: Any?) -> String? {
    switch input {
    case let value as Int64:
        return String(value)
    case let value as Int:
        return String(value)
    case let value as Double:
        return String(value)
    case let value as String:
        return value
    default:
        return nil
    }
}

public func gk_getBoolForValue(_ input: Any?) -> Bool? {
    switch input {
    case let value as Bool:
        return value
    case let value as Int:
        return !(value == 0)
    case let value as Double:
        return !(value == 0)
    case let value as String:
        return !(value == "" || value == "0" || value.lowercased() == "false")
    default:
        return nil
    }
}

public func gk_getLatitudeForValue(_ input: Any?) -> Double? {
    guard let jsonString = gk_getStringForValue(input),
        !jsonString.isBlank,
        let latValue = gk_getDoubleForValue(input)
    else {
        return nil
    }
    return max(-90.0, min(latValue, 90.0))
}

public func gk_getLongitudeForValue(_ input: Any?) -> Double? {
    guard let jsonString = gk_getStringForValue(input),
        !jsonString.isBlank,
        let lngValue = gk_getDoubleForValue(input)
    else {
        return nil
    }
    return max(-180.0, min(lngValue, 180.0))
}

extension String {
    public var gkFloatValue: Float {
        return (self as NSString).floatValue
    }
    
    public var gkIntValue: Int {
        return (self as NSString).integerValue
    }
    
    public var gkDoubleValue: Double {
        return (self as NSString).doubleValue
    }
}
