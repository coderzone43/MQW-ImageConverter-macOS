//
//  SignatureImageView.swift
//  SmartPrinter-MacOS
//
//  Created by MacBook Pro on 04/08/2025.
//

import Foundation
import AppKit

class SignatureImageView: NSView {
    
    var onDelete: (() -> Void)?
    var onBorderVisibilityChanged: ((Bool) -> Void)?
    var isLocked: Bool = false
    let imageView = NSImageView()
    let deleteButton = NSButton()
    let resizeButton = NSButton()
    
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
        // Configure image view
        imageView.imageScaling = .scaleProportionallyUpOrDown // Equivalent to .scaleAspectFit
        imageView.wantsLayer = true
        imageView.layer?.backgroundColor = NSColor.clear.cgColor // Assuming bgColor was meant to be backgroundColor
        addSubview(imageView)
        
        // Configure delete button
        deleteButton.title = ""
        deleteButton.image = NSImage(named: "imgCloseWM") // Ensure image exists in asset catalog
        deleteButton.isBordered = false
        deleteButton.addTapGesture(target: self, action: #selector(removeSignature))
        
        addSubview(deleteButton)
        
        // Configure resize button
        resizeButton.title = ""
        resizeButton.image = NSImage(named: "imgExpandWM") // Ensure image exists in asset catalog
        resizeButton.isBordered = false
        addSubview(resizeButton)
        
        // Configure drag gesture
        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        addGestureRecognizer(panGesture)
        
        // Configure resize gesture
        let resizeGesture = NSPanGestureRecognizer(target: self, action: #selector(handleResize(_:)))
        resizeButton.addGestureRecognizer(resizeGesture)
        
        // Configure click gesture for selection
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(updateImageViewOnSelection))
        imageView.addGestureRecognizer(clickGesture)
    }
    
    override func layout() {
        super.layout()
        
        imageView.frame = bounds
        
        let buttonSize: CGFloat = 50
        deleteButton.frame = NSRect(x: -24, y: -22, width: buttonSize, height: buttonSize)
        //NSRect(x: -20, y: bounds.height - buttonSize + 20, width: buttonSize, height: buttonSize)
        resizeButton.frame = NSRect(x: bounds.width - buttonSize + 20, y: bounds.height - buttonSize + 20, width: buttonSize, height: buttonSize)
    }
    
    @objc private func updateImageViewOnSelection() {
        if isLocked{return}
        isSelected = true
        layout()
    }
    
    @objc private func removeSignature() {
        if isLocked{return}
        onDelete?()
        removeFromSuperview()
    }
    @objc func removeViewSignature(){
        if isLocked{return}
        removeFromSuperview()
        onDelete = nil
    }
    @objc private func handleDrag(_ gesture: NSPanGestureRecognizer) {
        if isLocked{return}
        deleteButton.isHidden = false
        resizeButton.isHidden = false
        isSelected = true
        guard let superview = superview else { return }
        
        let translation = gesture.translation(in: superview)
        var newOrigin = NSPoint(x: frame.origin.x + translation.x, y: frame.origin.y + translation.y)
        
        // Constrain movement within superview bounds
        let minX: CGFloat = 0
        let maxX = superview.bounds.width - bounds.width
        let minY: CGFloat = 0
        let maxY = superview.bounds.height - bounds.height
        newOrigin.x = max(minX, min(newOrigin.x, maxX))
        newOrigin.y = max(minY, min(newOrigin.y, maxY))
        
        frame.origin = newOrigin
        gesture.setTranslation(.zero, in: superview)
    }
    
    @objc private func handleResize(_ gesture: NSPanGestureRecognizer) {
        if isLocked{return}
        guard let superview = superview else { return }
        let translation = gesture.translation(in: superview)
        
        let minWidth: CGFloat = 50
        let minHeight: CGFloat = 50
        let maxWidth = superview.bounds.width - frame.origin.x
        let maxHeight = superview.bounds.height - frame.origin.y
        
        let newWidth = max(minWidth, min(frame.width + translation.x, maxWidth))
        let newHeight = max(minHeight, min(frame.height + translation.y, maxHeight))
        
        frame.size = NSSize(width: newWidth, height: newHeight)
        gesture.setTranslation(.zero, in: superview)
        layout()
    }
    
    private func toggleBorderVisibility() {
        if isLocked{return}
        if isSelected {
            imageView.wantsLayer = true
            imageView.layer?.borderWidth = 1
            imageView.layer?.borderColor = NSColor.primary1.cgColor
            resizeButton.isHidden = false
            deleteButton.isHidden = false
        } else {
            imageView.layer?.borderWidth = 0
            imageView.layer?.borderColor = NSColor.clear.cgColor
            deleteButton.isHidden = true
            resizeButton.isHidden = true
        }
        onBorderVisibilityChanged?(isSelected)
    }
}
