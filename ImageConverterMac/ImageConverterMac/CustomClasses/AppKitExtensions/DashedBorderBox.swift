//
//  DashedBorderBox.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 07/08/2025.
//


import Cocoa

@IBDesignable
class DashedBorderBox: NSBox {

    @IBInspectable var dashLength: CGFloat = 5
    @IBInspectable var gapLength: CGFloat = 3
    @IBInspectable var lineWidth: CGFloat = 2
    @IBInspectable var borderClr: NSColor = .systemGray
    @IBInspectable var cornerRds: CGFloat = 8

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        let insetRect = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        let path = CGPath(roundedRect: insetRect, cornerWidth: cornerRds, cornerHeight: cornerRds, transform: nil)

        //let borderRect = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        //let path = CGPath(rect: borderRect, transform: nil)

        context.setLineWidth(lineWidth)
        context.setStrokeColor(borderClr.cgColor)
        context.setLineDash(phase: 0, lengths: [dashLength, gapLength])
        context.addPath(path)
        context.strokePath()
    }

    // Optional: Ensure the boxType doesn’t draw its own border
    override func awakeFromNib() {
        super.awakeFromNib()
        self.boxType = .custom
    }
}
