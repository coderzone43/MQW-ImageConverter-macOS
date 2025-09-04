//
//  NSTextField.swift
//  MS-AppLauncher
//
//  Created by Ahsan Murtaza on 24/06/2024.
//

import Cocoa

class PaddingTextFieldCell: NSTextFieldCell {

    private static var padding = CGSize(width: 0, height: 15.0)

    override func titleRect(forBounds rect: NSRect) -> NSRect {
        return rect.insetBy(
            dx: PaddingTextFieldCell.padding.width,
            dy: PaddingTextFieldCell.padding.height
        )
    }
    override func edit(
        withFrame rect: NSRect,
        in controlView: NSView,
        editor textObj: NSText,
        delegate: Any?,
        event: NSEvent?
    ) {
        let insetRect = rect.insetBy(
            dx: PaddingTextFieldCell.padding.width,
            dy: PaddingTextFieldCell.padding.height
        )
        super.edit(
            withFrame: insetRect,
            in: controlView,
            editor: textObj,
            delegate: delegate,
            event: event
        )
    }
    override func select(
        withFrame rect: NSRect,
        in controlView: NSView,
        editor textObj: NSText,
        delegate: Any?,
        start selStart: Int,
        length selLength: Int
    ) {
        let insetRect = rect.insetBy(
            dx: PaddingTextFieldCell.padding.width,
            dy: PaddingTextFieldCell.padding.height
        )
        super.select(
            withFrame: insetRect,
            in: controlView,
            editor: textObj,
            delegate: delegate,
            start: selStart,
            length: selLength
        )
    }
    override func drawInterior(
        withFrame cellFrame: NSRect,
        in controlView: NSView
    ) {
        let insetRect = cellFrame.insetBy(
            dx: PaddingTextFieldCell.padding.width,
            dy: PaddingTextFieldCell.padding.height
        )
        super.drawInterior(withFrame: insetRect, in: controlView)
    }
}

extension NSTextField {
    func setPlaceholderFont(_ font: NSFont) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.placeholderTextColor
        ]
        let attributedPlaceholder = NSAttributedString(
            string: self.placeholderString ?? "",
            attributes: attributes
        )
        self.placeholderAttributedString = attributedPlaceholder
    }
}

extension NSTextField {
    func adjustFontSizeToFit() {
        decreaseFontIfNeeded()
    }

    func decreaseFontIfNeeded() {
        guard let text = self.stringValue as NSString? else { return }

        let font = self.font ?? NSFont.systemFont(ofSize: font?.pointSize ?? NSFont.systemFontSize)
        var fontSize = font.pointSize
        let textSize = text.size(withAttributes: [.font: font])

        if textSize.width > 89 {
            fontSize -= 1
            self.font = font.withSize(fontSize)
            decreaseFontIfNeeded()
        }
    }

    func removeFocusRing() {
        focusRingType = .none
    }
}

extension NSTextField {
    func createImage() -> NSImage? {
        // Ensure the text field is properly laid out
        self.layoutSubtreeIfNeeded()

        // Create a bitmap representation of the text field
        guard let bitmapRep = self.bitmapImageRepForCachingDisplay(in: self.bounds) else {
            return nil
        }

        // Cache the display of the text field into the bitmap representation
        self.cacheDisplay(in: self.bounds, to: bitmapRep)

        // Create an NSImage from the bitmap representation
        let image = NSImage(size: self.bounds.size)
        image.addRepresentation(bitmapRep)

        return image
    }


}

extension NSImage {
    func pngData() -> Data? {
        guard let tiffData = tiffRepresentation,
              let bitmapImageRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }

        return bitmapImageRep.representation(using: .png, properties: [:])
    }
}

extension NSTextField {
    func bestHeight(for text: String, width: CGFloat) -> CGFloat {
        stringValue = text
        let height = cell!.cellSize(forBounds: NSRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)).height
        return height
    }
    func bestWidth(for text: String, height: CGFloat) -> CGFloat {
        stringValue = text
        let width = cell!.cellSize(forBounds: NSRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: height)).width
        return width
    }
    
    func addLineSpacing(_ spacing: CGFloat, textAlignment: NSTextAlignment = .left) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        paragraphStyle.alignment = textAlignment
        
        let mutableString = NSMutableAttributedString(attributedString: self.attributedStringValue)
        mutableString.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: mutableString.length))
        self.attributedStringValue = mutableString
    }
}
