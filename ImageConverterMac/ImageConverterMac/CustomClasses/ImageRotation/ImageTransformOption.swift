//
//  ImageTransformOption.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 18/08/2025.
//


import Cocoa

enum ImageTransformOption {
    case rotate90
    case flipHorizontal
    case flipVertical
    case custom(angle: CGFloat) // slider rotation
}

class ImageTransformer {
    
    /// Always transform starting from the original image
    static func transform(originalImage: NSImage, option: ImageTransformOption) -> NSImage? {
        var angle: CGFloat = 0
        var flipH = false
        var flipV = false
        
        switch option {
        case .rotate90:
            angle = 90
        case .flipHorizontal:
            flipH = true
        case .flipVertical:
            flipV = true
        case .custom(let customAngle):
            angle = customAngle
        }
        
        return applyTransform(to: originalImage, angle: angle, flipH: flipH, flipV: flipV)
    }
    
    /// Core transformation logic
    private static func applyTransform(to image: NSImage,
                                       angle: CGFloat,
                                       flipH: Bool,
                                       flipV: Bool) -> NSImage? {
        
        let originalSize = image.size
        let radians = angle * (.pi / 180)
        
        // 🔹 Compute rotated bounding box
        let rotatedWidth = abs(originalSize.width * cos(radians)) + abs(originalSize.height * sin(radians))
        let rotatedHeight = abs(originalSize.width * sin(radians)) + abs(originalSize.height * cos(radians))
        let newSize = NSSize(width: rotatedWidth, height: rotatedHeight)
        
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            newImage.unlockFocus()
            return nil
        }
        
        ctx.saveGState()
        
        // Move origin to center of new canvas
        ctx.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        ctx.rotate(by: radians)
        
        // Flip handling
        var transform = CGAffineTransform.identity
        if flipH { transform = transform.scaledBy(x: -1, y: 1) }
        if flipV { transform = transform.scaledBy(x: 1, y: -1) }
        ctx.concatenate(transform)
        
        // Draw original image centered
        let drawRect = CGRect(x: -originalSize.width / 2,
                              y: -originalSize.height / 2,
                              width: originalSize.width,
                              height: originalSize.height)
        
        image.draw(in: drawRect,
                   from: .zero,
                   operation: .copy,
                   fraction: 1.0,
                   respectFlipped: true,
                   hints: nil)
        
        ctx.restoreGState()
        
        newImage.unlockFocus()
        return newImage
    }
}


