//
//  HoverView.swift
//  Groke
//
//  Created by Muhammad Usama Amin on 28/04/2025.
//

import Foundation
import Cocoa

class HoverViewButton: NSButton {

    enum ToolTipVerticalPosition {
        case top
        case bottom
    }
    
    enum ToolTipHorizontalPosition {
        case matchLeading
        case matchtrailing
        case center
    }
    
    typealias HoverCallback = (Bool, HoverViewButton) -> Void
    var onHoverStateChanged: HoverCallback?
    private var trackingArea: NSTrackingArea?
    
    var toolTipVerticalPostion: ToolTipVerticalPosition = .top
    var toolTipHoriizontalPostion: ToolTipHorizontalPosition = .matchLeading
    
    
    var toolTipView: ToolTipView?
    var toolTipText: String?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTrackingArea()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTrackingArea()
    }
    
    private func setupTrackingArea() {
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        if let trackingArea = trackingArea {
            self.addTrackingArea(trackingArea)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        onHoverStateChanged?(true, self)
        showToolTip()
    }
    
    override func mouseExited(with event: NSEvent) {
        onHoverStateChanged?(false, self)
        hideToolTip()
    }
    
    func setToolTip(_ text: String, verticalPosition: ToolTipVerticalPosition = .top, horizontalPosition: ToolTipHorizontalPosition = .matchLeading) {
        toolTipText = text
        toolTipVerticalPostion = verticalPosition
        toolTipHoriizontalPostion = horizontalPosition
    }
    
    func fade(view: NSView, duration: TimeInterval = 0.3) {
        view.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            view.animator().alphaValue = 1.0
        }
    }
    
    func showToolTip() {
        
        guard let text = toolTipText else { return }
        guard let mainView = window?.contentViewController?.view else { return }
        let location = self.convert(self.bounds, to: mainView)
        toolTipView = ToolTipView()
        
        if let view = toolTipView {
            view.toolLabel.stringValue = text.localized()
            view.backgroundColor = .textBackgroundColor
            view.cornerRadius = 6
            let textField = NSTextField()
            textField.font = NSFont(name: "Lato-Regular", size: 12)
            let width = textField.bestWidth(for: text, height: 35) + 6
            let yLocation: CGFloat = toolTipVerticalPostion == .top ? (location.maxY + 10) : ((location.minY) - 29)
            
            let xLocation: CGFloat
            switch toolTipHoriizontalPostion {
            case .matchLeading:
                xLocation = location.minX
            case .matchtrailing:
                xLocation = (location.minX - width) + bounds.width
            case .center:
                xLocation = location.midX - (width / 2)
            }
            toolTipView?.frame = .init(x: xLocation, y: yLocation, width: width, height: 22)
            mainView.addSubview(view)
            fade(view: view)
        }
    }
    
    func hideToolTip() {
        toolTipView?.removeFromSuperview()
        toolTipView = nil
    }
    
    deinit {
        if let trackingArea = trackingArea {
            self.removeTrackingArea(trackingArea)
        }
    }
}

class HoverViewButtonWithImageAndLabel: HoverViewButton {
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var label: NSTextField!
    
    func configure(image: NSImage, text: String) {
        imageView.image = image
        label.stringValue = text
    }
}
