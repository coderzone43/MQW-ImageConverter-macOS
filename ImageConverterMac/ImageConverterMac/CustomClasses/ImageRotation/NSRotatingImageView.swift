//
//  NSRotatingImageView.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 18/08/2025.
//


import Cocoa

class NSRotatingImageView: NSImageView {
    
    /// rotation angle in degrees
    var rotationAngle: CGFloat = 0 {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let image = image else { return }
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        let bounds = self.bounds
        let imageSize = image.size
        
        ctx.saveGState()
        
        // Move origin to center of the view
        ctx.translateBy(x: bounds.midX, y: bounds.midY)
        ctx.rotate(by: rotationAngle * (.pi / 180))
        
        // 🔹 Calculate aspect fit rect
        let scale = min(bounds.width / imageSize.width,
                        bounds.height / imageSize.height)
        
        let drawWidth = imageSize.width * scale
        let drawHeight = imageSize.height * scale
        
        let drawRect = CGRect(x: -drawWidth / 2,
                              y: -drawHeight / 2,
                              width: drawWidth,
                              height: drawHeight)
        
        image.draw(in: drawRect,
                   from: .zero,
                   operation: .sourceOver,
                   fraction: 1.0,
                   respectFlipped: true,
                   hints: nil)
        
        ctx.restoreGState()
    }
}
