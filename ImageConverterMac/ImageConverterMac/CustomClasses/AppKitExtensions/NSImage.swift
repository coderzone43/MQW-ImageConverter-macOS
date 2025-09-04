//
//  NSImage.swift
//  MS-AppLauncher
//
//  Created by Ahsan Murtaza on 11/06/2024.
//

import Foundation
import Cocoa

extension NSImage {
    var jpegData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.7])
    }
    
    func resized(to targetSize: NSSize) -> NSImage {
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        self.draw(
            in: NSRect(
                origin: .zero,
                size: targetSize
            ),
            from: NSRect(origin: .zero, size: self.size),
            operation: .copy,
            fraction: 1.0
        )
        newImage.unlockFocus()
        newImage.size = targetSize
        return newImage
    }
    
    func tintedImage(with color: NSColor) -> NSImage {
        let newImage = copy() as! NSImage
        newImage.lockFocus()

        color.set()
        let imageRect = NSRect(origin: .zero, size: newImage.size)
        imageRect.fill(using: .sourceAtop)

        newImage.unlockFocus()
        newImage.isTemplate = false // because it's now colored

        return newImage
    }
}
