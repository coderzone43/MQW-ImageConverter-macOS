//
//  NSFont.swift
//  MS-AppLauncher
//
//  Created by Ahsan Murtaza on 24/06/2024.
//

import Foundation
import Cocoa

enum PlusJakartaSans: String {
    case bold = "Bold"
    case medium = "Medium"
    case regular = "Regular"
    case semiBold = "SemiBold"

    var name: String {
        "PlusJakartaSans-\(rawValue)"
    }
}

extension NSFont {

    static func plusJakartaSansRegular(size: CGFloat) -> NSFont {
        return NSFont(name: "PlusJakartaSans-Regular", size: size) ?? NSFont.systemFont(ofSize: size)
    }

    static func plusJakartaSansBold(size: CGFloat) -> NSFont {
        return NSFont(name: "PlusJakartaSans-Bold", size: size) ?? NSFont.boldSystemFont(ofSize: size)
    }
    static func plusJakartaSansSemiBold(size: CGFloat) -> NSFont {
        return NSFont(name: "PlusJakartaSans-SemiBold", size: size) ?? NSFont.boldSystemFont(ofSize: size)
    }
    static func plusJakartaSansMedium(size: CGFloat) -> NSFont {
        return NSFont(name: "PlusJakartaSans-Medium", size: size) ?? NSFont.boldSystemFont(ofSize: size)
    }

    // Add more custom fonts as needed
}

extension NSFont {
    static func appFont(weight: NSFont.Weight = .regular, ofSize size: CGFloat) -> NSFont {
        let fontName: String?

        switch weight {
        case .bold: fontName = PlusJakartaSans.bold.name
        case .medium: fontName = PlusJakartaSans.medium.name
        case .regular: fontName = PlusJakartaSans.regular.name
        case .semibold: fontName = PlusJakartaSans.semiBold.name
        default: fontName = nil
        }

        if let fontName {
            return .init(name: fontName, size: size)!
        }

        return .systemFont(ofSize: size, weight: weight)
    }
}
