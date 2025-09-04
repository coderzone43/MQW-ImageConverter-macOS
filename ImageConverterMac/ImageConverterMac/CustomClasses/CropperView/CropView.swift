//
//  CropView.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 22/08/2025.
//
import Cocoa

class CropView: NSView {
    private var cropRect: NSRect = NSRect(x: 100, y: 100, width: 300, height: 300)
    private var isResizing = false
    private var isResizingLeft = false
    private var isResizingBottom = false
    private var isDragging = false
    private var dragStartPoint: NSPoint?
    private let resizeImage: NSImage? = NSImage(resource: ImageResource.imgCropLayerTip) // Ensure you have a 20x20 circle image named "imgCropLayerTip" in assets
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Draw semi-transparent overlay
        /*NSColor.black.withAlphaComponent(0.5).set()
        let path = NSBezierPath(rect: bounds)
        path.append(NSBezierPath(rect: cropRect))
        path.addClip()
        path.fill()*/
        
        // Fill inside crop rect with white alpha (adjust alpha as needed, e.g., 0.3 for subtle highlight)
        NSColor.white.withAlphaComponent(0.3).setFill()
        NSBezierPath(rect: cropRect).fill()
        
        // Draw single clear blue dashed path
        let dashedPath = NSBezierPath(rect: cropRect)
        dashedPath.lineWidth = 2.0
        let dashPattern: [CGFloat] = [5.0, 5.0] // Dashed pattern (on, off)
        dashedPath.setLineDash(dashPattern, count: 2, phase: 0.0)
        NSColor.primary1.set() // Clear blue color
        dashedPath.stroke()
        
        // Draw resize image at all four corners
        if let image = resizeImage {
            let imageRectTopRight = NSRect(x: cropRect.maxX - 15, y: cropRect.maxY - 15, width: 20, height: 20)
            let imageRectTopLeft = NSRect(x: cropRect.minX - 5, y: cropRect.maxY - 15, width: 20, height: 20)
            let imageRectBottomLeft = NSRect(x: cropRect.minX - 5, y: cropRect.minY - 5, width: 20, height: 20)
            let imageRectBottomRight = NSRect(x: cropRect.maxX - 15, y: cropRect.minY - 5, width: 20, height: 20)
            image.draw(in: imageRectTopRight)
            image.draw(in: imageRectTopLeft)
            image.draw(in: imageRectBottomLeft)
            image.draw(in: imageRectBottomRight)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        dragStartPoint = location
        
        // Check which corner is clicked for resizing
        let resizeRectSize: CGFloat = 20.0
        let resizeRectTopRight = NSRect(x: cropRect.maxX - 15, y: cropRect.maxY - 15, width: resizeRectSize, height: resizeRectSize)
        let resizeRectTopLeft = NSRect(x: cropRect.minX - 5, y: cropRect.maxY - 15, width: resizeRectSize, height: resizeRectSize)
        let resizeRectBottomLeft = NSRect(x: cropRect.minX - 5, y: cropRect.minY - 5, width: resizeRectSize, height: resizeRectSize)
        let resizeRectBottomRight = NSRect(x: cropRect.maxX - 15, y: cropRect.minY - 5, width: resizeRectSize, height: resizeRectSize)
        
        if resizeRectTopRight.contains(location) {
            isResizing = true
            isResizingLeft = false
            isResizingBottom = false
        } else if resizeRectTopLeft.contains(location) {
            isResizing = true
            isResizingLeft = true
            isResizingBottom = false
        } else if resizeRectBottomLeft.contains(location) {
            isResizing = true
            isResizingLeft = true
            isResizingBottom = true
        } else if resizeRectBottomRight.contains(location) {
            isResizing = true
            isResizingLeft = false
            isResizingBottom = true
        } else if cropRect.contains(location) {
            isDragging = true
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let dragStart = dragStartPoint else { return }
        let currentLocation = convert(event.locationInWindow, from: nil)
        let deltaX = currentLocation.x - dragStart.x
        let deltaY = currentLocation.y - dragStart.y
        
        if isResizing {
            var newOrigin = cropRect.origin
            var newSize = cropRect.size
            
            if isResizingLeft {
                newSize.width = max(50, cropRect.width - deltaX)
                newOrigin.x += deltaX
            } else {
                newSize.width = max(50, cropRect.width + deltaX)
            }
            
            if isResizingBottom {
                newSize.height = max(50, cropRect.height - deltaY)
                newOrigin.y += deltaY
            } else {
                newSize.height = max(50, cropRect.height + deltaY)
            }
            
            cropRect.origin = newOrigin
            cropRect.size = newSize
        } else if isDragging {
            cropRect.origin.x += deltaX
            cropRect.origin.y += deltaY
        }
        
        // Keep cropRect within bounds
        cropRect.origin.x = max(0, min(cropRect.origin.x, bounds.width - cropRect.width))
        cropRect.origin.y = max(0, min(cropRect.origin.y, bounds.height - cropRect.height))
        cropRect.size.width = min(cropRect.size.width, bounds.width - cropRect.origin.x)
        cropRect.size.height = min(cropRect.size.height, bounds.height - cropRect.origin.y)
        
        dragStartPoint = currentLocation
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        isResizing = false
        isDragging = false
        dragStartPoint = nil
        needsDisplay = true
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: 500, height: 500))
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }
}
extension CropView {
    public func setCropRect(_ rect: NSRect) {
        // Clamp the rect to ensure it stays within bounds
        var clampedRect = rect
        clampedRect.origin.x = max(0, min(clampedRect.origin.x, bounds.width - clampedRect.width))
        clampedRect.origin.y = max(0, min(clampedRect.origin.y, bounds.height - clampedRect.height))
        clampedRect.size.width = max(50, min(clampedRect.size.width, bounds.width - clampedRect.origin.x)) // Min width 50
        clampedRect.size.height = max(50, min(clampedRect.size.height, bounds.height - clampedRect.origin.y)) // Min height 50
        cropRect = clampedRect
        needsDisplay = true
    }
}
extension CropView {
    func captureCroppedImage(from imageView: NSImageView) -> NSImage? {
        guard let image = imageView.image else {
            return nil
        }
        let imageSize = image.size
        let viewSize = imageView.bounds.size
        // Convert cropRect to imageView coordinates
        let cropFrameInView = self.convert(cropRect, to: imageView)
        // Ensure crop rect is within view bounds
        let scaledCropRect = cropFrameInView.intersection(CGRect(origin: .zero, size: viewSize))
        if scaledCropRect.isEmpty {
            return nil
        }
        // Calculate fractions in view (0 to 1, origin at bottom-left unless flipped)
        let fracX = scaledCropRect.origin.x / viewSize.width
        var fracY = scaledCropRect.origin.y / viewSize.height
        let fracW = scaledCropRect.width / viewSize.width
        let fracH = scaledCropRect.height / viewSize.height
        // Adjust y if the imageView is flipped (y=0 at top)
        var imageCropY = fracY * imageSize.height
        if imageView.isFlipped {
            imageCropY = (1 - fracY - fracH) * imageSize.height
        }
        // Map to image points (from bottom-left)
        let fromRect = CGRect(
            x: fracX * imageSize.width,
            y: imageCropY,
            width: fracW * imageSize.width,
            height: fracH * imageSize.height
        )
        // Create cropped image at the cropped size in points
        let croppedSize = NSSize(width: scaledCropRect.width, height: scaledCropRect.height)
        let croppedImage = NSImage(size: croppedSize)
        croppedImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: croppedSize),
                   from: fromRect,
                   operation: .sourceOver,
                   fraction: 1.0)
        croppedImage.unlockFocus()
        return croppedImage
    }
}


