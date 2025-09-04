//
//  NSAttributedString.swift
//  GrowMacOS
//
//  Created by Macbook Pro on 20/05/2025.
//

import Foundation

extension NSAttributedString {
    func trimmedTrailingNewlines() -> NSAttributedString {
        let fullString = self.string as NSString
        let trimmedString = fullString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Get the range of the trimmed string inside the original string
        let range = fullString.range(of: trimmedString)
        
        if range.length == 0 {
            return NSAttributedString(string: "")
        } else {
            return self.attributedSubstring(from: range)
        }
    }
}
