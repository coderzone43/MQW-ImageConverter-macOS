//
//  UserDefaults.swift
//  MS-AppLauncher
//
//  Created by Ahsan Murtaza on 29/08/2024.
//
import Foundation

extension UserDefaults {
    func setObject<T: Codable>(_ object: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(object) {
            self.set(encoded, forKey: key)
        }
    }

    func getObject<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        if let data = self.data(forKey: key),
           let object = try? JSONDecoder().decode(type, from: data) {
            return object
        }
        return nil
    }
}
extension UserDefaults {
    
    /// Generic method to save a struct that conforms to Codable into UserDefaults
    ///
    /// - Parameters:
    ///   - value: Generic Class Type
    ///   - defaultName: Key to which the struct will be saved
    open func setStruct<T: Codable>(_ value: T?, forKey defaultName: String){
        let data = try? JSONEncoder().encode(value)
        set(data, forKey: defaultName)
    }
    
    /// Generic Method to get a saved struct in UserDefaults. If key not found nil will be returned
    ///
    /// - Parameters:
    ///   - type: Generic Class Type
    ///   - defaultName: Key to which the struct is saved
    /// - Returns: A Struct on which this generic method is called
    open func structData<T>(_ type: T.Type, forKey defaultName: String) -> T? where T : Decodable {
        guard let encodedData = data(forKey: defaultName) else {
            return nil
        }
        
        return try? JSONDecoder().decode(type, from: encodedData)
    }
    
    /// Generic method to save a Array of struct that conforms to Codable into UserDefaults
    ///
    /// - Parameters:
    ///   - value: Generic Class Type
    ///   - defaultName: ey to which the Array will be saved
    open func setStructArray<T: Codable>(_ value: [T]?, forKey defaultName: String){
        guard let value = value else {
            set(nil, forKey: defaultName)
            return
        }
        let data = value.map { try? JSONEncoder().encode($0) }
        set(data, forKey: defaultName)
    }
    
    /// Generic Method to get a saved Array of struct in UserDefaults. If key not found nil will be returned
    ///
    /// - Parameters:
    ///   - type: Generic Class Type
    ///   - defaultName: Key to which the Array is saved
    /// - Returns: An Array to Struct on which the generic method is called
    open func structArrayData<T>(_ type: T.Type, forKey defaultName: String) -> [T]? where T : Decodable {
        guard let encodedData = array(forKey: defaultName) as? [Data] else { return nil }
        return encodedData.compactMap({ try? JSONDecoder().decode(type, from: $0)})
    }
}
