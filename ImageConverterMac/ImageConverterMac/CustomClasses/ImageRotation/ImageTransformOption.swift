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
        
        let imageSize = image.size
        let radians = angle * (.pi / 180)
        
        let newImage = NSImage(size: imageSize)
        newImage.lockFocus()
        
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            newImage.unlockFocus()
            return nil
        }
        
        // Move origin to image center
        ctx.translateBy(x: imageSize.width / 2, y: imageSize.height / 2)
        ctx.rotate(by: radians)
        
        // Flip handling
        var transform = CGAffineTransform.identity
        if flipH { transform = transform.scaledBy(x: -1, y: 1) }
        if flipV { transform = transform.scaledBy(x: 1, y: -1) }
        ctx.concatenate(transform)
        
        // ✅ Draw full image, no scaling, no canvas change
        image.draw(in: NSRect(x: -imageSize.width / 2,
                              y: -imageSize.height / 2,
                              width: imageSize.width,
                              height: imageSize.height),
                   from: .zero,
                   operation: .copy,
                   fraction: 1.0)
        
        newImage.unlockFocus()
        return newImage
    }
}

