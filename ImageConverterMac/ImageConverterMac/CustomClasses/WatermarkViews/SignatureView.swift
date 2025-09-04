//
//  SignatureView.swift
//  SmartPrinter-MacOS
//
//  Created by MacBook Pro on 04/08/2025.
//

import Foundation
import AppKit

class SignatureView: NSView, NSTextFieldDelegate {
    
    var onDelete: (() -> Void)?
    var isLocked: Bool = false
    var onBorderVisibilityChanged: ((Bool) -> Void)?
    var onSelectionOfTextField: ((String) -> Void)?
    
    var isBold: Bool = false {
        didSet {
            var fontDescriptor = NSFontDescriptor(name: fontNameString, size: fontSize)
            if isBold {
                fontDescriptor = fontDescriptor.withSymbolicTraits(.bold)
                label.font = NSFont(descriptor: fontDescriptor, size: fontSize)
            } else {
                label.font = NSFont(name: fontNameString, size: fontSize)
            }
        }
    }
    
    var isItalic: Bool = false {
        didSet {
            var fontDescriptor = NSFontDescriptor(name: fontNameString, size: fontSize)
            if isItalic {
                fontDescriptor = fontDescriptor.withSymbolicTraits(.italic)
                label.font = NSFont(descriptor: fontDescriptor, size: fontSize)
            } else {
                label.font = NSFont(name: fontNameString, size: fontSize)
            }
        }
    }
    
    var isUnderlined: Bool = false {
        didSet {
            if isUnderlined {
                let attributes: [NSAttributedString.Key: Any] = [
                    .underlineStyle: NSUnderlineStyle.single.rawValue,.font : NSFont(name: fontNameString, size: fontSize),.accessibilityAlignment:label.alignment
                ]
                let attributedText = NSAttributedString(string: label.stringValue, attributes: attributes)
                label.attributedStringValue = attributedText
            } else {
                let plainText = NSAttributedString(string: label.stringValue)
                label.stringValue = plainText.string
            }
        }
    }
    
    var fontSize: CGFloat = 18
    var fontNameString: String = "AcademyEngravedLetPlain"
    
    let label = NSTextField()
    let resizeButton = NSButton()
    let deleteButton = NSButton()
    let editButton = NSButton()
    let textField = NSTextField()
    
    var isSelected: Bool = false {
        didSet {
            toggleBorderVisibility()
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configure label (NSTextField used as label)
        label.isEditable = false
        label.isSelectable = false
        label.isBezeled = false
        label.drawsBackground = false
        label.alignment = .center
        label.wantsLayer = true
        label.font = NSFont(name: fontNameString, size: fontSize)
        addSubview(label)
        
        // Configure pan gesture for dragging
        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        addGestureRecognizer(panGesture)
        
        // Configure pan gesture for resizing
        let resizeGesture = NSPanGestureRecognizer(target: self, action: #selector(handleResize(_:)))
        resizeButton.addGestureRecognizer(resizeGesture)
        
        // Configure single-click gesture for text editing
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(editLabelText))
        label.addGestureRecognizer(clickGesture)
        
        // Configure double-click gesture for popup
        //let doubleClickGesture = NSClickGestureRecognizer(target: self, action: #selector(addTextField))
        //editButton.addGestureRecognizer(doubleClickGesture)
        
        // Configure rotate gesture for popup
        let rotateGesture = NSPanGestureRecognizer(target: self, action: #selector(handleRotate(_:)))
        editButton.addGestureRecognizer(rotateGesture)
        
        deleteButton.addTapGesture(target: self, action: #selector(removeSignature))
        
        // Configure resize button
        resizeButton.title = ""
        resizeButton.image = NSImage(named: "imgExpandWM")
        resizeButton.isBordered = false
        resizeButton.image?.size = NSSize(width: 24, height: 24)
        addSubview(resizeButton)
        
        editButton.title = ""
        editButton.image = NSImage(named: "imgRotateWM")
        editButton.isBordered = false
        editButton.image?.size = NSSize(width: 24, height: 24)
        //addSubview(editButton)
        
        // Configure delete button
        deleteButton.title = ""
        deleteButton.image = NSImage(named: "imgCloseWM")
        deleteButton.isBordered = false
        deleteButton.image?.size = NSSize(width: 24, height: 24)
        addSubview(deleteButton)
    }
    
    override func layout() {
        super.layout()
        
        label.frame = NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
//        label.frame = NSRect(
//                    x: (bounds.width - label.intrinsicContentSize.width) / 2,
//                    y: (bounds.height - label.intrinsicContentSize.height) / 2,
//                    width: label.intrinsicContentSize.width,
//                    height: label.intrinsicContentSize.height
//                ).insetBy(dx: -10, dy: -10)
        
        let buttonSize: CGFloat = 50
        editButton.frame = NSRect(x: -22, y: bounds.height - buttonSize + 22, width: buttonSize, height: buttonSize)
        resizeButton.frame = NSRect(x: bounds.width - buttonSize + 22, y: bounds.height - buttonSize + 22, width: buttonSize, height: buttonSize)
        
        deleteButton.frame = NSRect(x: -24, y: -22, width: buttonSize, height: buttonSize)
    }
    
    @objc private func handleDoubleTap() {
//        if isLocked{return}
        isSelected = true
        layout()
    }
    
    @objc private func editLabelText() {
//        if isLocked{return}
        isSelected = true
        onSelectionOfTextField?(label.stringValue)
        layout()
    }
    
    @objc private func addTextField() {
        if isLocked{return}
        textField.frame = NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        textField.alignment = .center
        textField.stringValue = label.stringValue
        textField.font = NSFont(name: fontNameString, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        textField.isBordered = false
        textField.delegate = self
        textField.lineBreakMode = .byTruncatingTail
        addSubview(textField)
        label.isHidden = true
        textField.becomeFirstResponder()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if isLocked{return}
        if let textField = obj.object as? NSTextField {
            label.stringValue = textField.stringValue
            textField.removeFromSuperview()
            label.isHidden = false
        }
    }
    
    @objc private func handleDrag(_ gesture: NSPanGestureRecognizer) {
        if isLocked{return}
        deleteButton.isHidden = false
        resizeButton.isHidden = false
        editButton.isHidden = false
        isSelected = true
        textField.becomeFirstResponder()
        guard let superview = superview else { return }
        
        let translation = gesture.translation(in: superview)
        var newOrigin = NSPoint(x: frame.origin.x + translation.x, y: frame.origin.y + translation.y)
        
        let minX: CGFloat = 0
        let maxX = superview.bounds.width - bounds.width
        let minY: CGFloat = 0
        let maxY = superview.bounds.height - bounds.height
        newOrigin.x = max(minX, min(newOrigin.x, maxX))
        newOrigin.y = max(minY, min(newOrigin.y, maxY))
        
        frame.origin = newOrigin
        gesture.setTranslation(.zero, in: superview)
    }
    @objc private func handleRotate(_ gesture: NSPanGestureRecognizer) {
        
    }
    @objc private func handleResize(_ gesture: NSPanGestureRecognizer) {
        if isLocked{return}
        textField.becomeFirstResponder()
        guard let superview = superview else { return }
        let translation = gesture.translation(in: superview)
        
        let minWidth: CGFloat = 85
        let minHeight: CGFloat = 90
        let maxWidth = superview.bounds.width - frame.origin.x
        let maxHeight = superview.bounds.height - frame.origin.y
        
        let newWidth = max(minWidth, min(frame.width + translation.x, maxWidth))
        let newHeight = max(minHeight, min(frame.height + translation.y, maxHeight))
        
        frame.size = NSSize(width: newWidth, height: newHeight)
        gesture.setTranslation(.zero, in: superview)
        layout()
    }
    
    @objc private func removeSignature() {
        onDelete?()
        removeFromSuperview()
    }
    @objc func removeViewSignature(){
        removeFromSuperview()
        onDelete = nil
    }
    private func toggleBorderVisibility() {
        if isLocked{return}
        textField.becomeFirstResponder()
        if isSelected {
            wantsLayer = true
            label.layer?.borderWidth = 1
            label.layer?.borderColor = NSColor.primary1.cgColor
            resizeButton.isHidden = false
            deleteButton.isHidden = false
            editButton.isHidden = false
        } else {
            label.layer?.borderWidth = 0
            label.layer?.borderColor = NSColor.clear.cgColor
            deleteButton.isHidden = true
            resizeButton.isHidden = true
            editButton.isHidden = true
        }
        onBorderVisibilityChanged?(isSelected)
    }
}
