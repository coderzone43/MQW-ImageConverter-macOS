//
//  NumberRangeFormatter.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/09/2025.
//
import Cocoa

class NumberRangeFormatter: Formatter {
    let minValue = 1
    let maxValue = 9999
    
    override func string(for obj: Any?) -> String? {
        if let intVal = obj as? Int {
            return "\(intVal)"
        }
        return obj as? String
    }
    
    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        // ✅ Allow empty string so user can leave field blank
        if string.isEmpty {
            obj?.pointee = nil
            return true
        }
        
        // Validate number
        if let intVal = Int(string), intVal >= minValue && intVal <= maxValue {
            obj?.pointee = intVal as AnyObject
            return true
        }
        
        error?.pointee = "Please enter a number between \(minValue) and \(maxValue)" as NSString
        return false
    }
    
    override func isPartialStringValid(
        _ partialString: String,
        newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        // ✅ Allow empty while editing
        if partialString.isEmpty { return true }
        
        // Only digits allowed
        let digitSet = CharacterSet.decimalDigits
        if !digitSet.isSuperset(of: CharacterSet(charactersIn: partialString)) {
            return false
        }
        
        // Allow numbers up to 9999 while typing
        if let intVal = Int(partialString), intVal <= maxValue {
            return true
        }
        
        return false
    }
}
