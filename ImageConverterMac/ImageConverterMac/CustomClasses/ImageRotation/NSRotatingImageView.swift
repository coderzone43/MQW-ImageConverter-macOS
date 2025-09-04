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
            
            let ctx = NSGraphicsContext.current?.cgContext
            let bounds = self.bounds
            
            ctx?.saveGState()
            
            // move origin to center of the view
            ctx?.translateBy(x: bounds.midX, y: bounds.midY)
            ctx?.rotate(by: rotationAngle * (.pi / 180))
            
            // after rotating, draw the image stretched to fill bounds
            let drawRect = CGRect(x: -bounds.width / 2,
                                  y: -bounds.height / 2,
                                  width: bounds.width,
                                  height: bounds.height)
            image.draw(in: drawRect)
            
            ctx?.restoreGState()
        }
}
