//
//  DragDropView.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 07/08/2025.
//


import Cocoa

class DragDropView: NSView {

    var acceptedFileExtensions: [String] = ["pdf", "png", "jpg"] // customize as needed
    var isFileValid = true {
        didSet {
            updateBackgroundColor()
        }
    }
    var onFileDropped: ((URL) -> Void)?
    @IBInspectable var cornerRds: CGFloat = 5 {
        didSet {
            updateCornerRadius()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
        updateBackgroundColor()
        updateCornerRadius()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
        updateBackgroundColor()
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        wantsLayer = true
        layer?.cornerRadius = cornerRds
        layer?.masksToBounds = true
    }

    private func updateBackgroundColor() {
        layer?.backgroundColor = isFileValid ? NSColor.clear.cgColor
                                             : NSColor.systemRed.withAlphaComponent(0.3).cgColor
    }

    // MARK: - Dragging

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if isFileExtensionAcceptable(sender) {
            isFileValid = true
            return .copy
        } else {
            isFileValid = false
            return []
        }
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        isFileValid = true // revert to valid state or default
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return isFileExtensionAcceptable(sender)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let fileURL = getFileURL(from: sender),
              isFileExtensionAcceptable(sender) else {
            return false
        }

        // Notify via callback
        onFileDropped?(fileURL)

        return true
    }

    // MARK: - Helpers

    private func getFileURL(from draggingInfo: NSDraggingInfo) -> URL? {
        let pasteboard = draggingInfo.draggingPasteboard
        if let items = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            return items.first
        }
        return nil
    }

    private func isFileExtensionAcceptable(_ draggingInfo: NSDraggingInfo) -> Bool {
        guard let url = getFileURL(from: draggingInfo) else { return false }
        let ext = url.pathExtension.lowercased()
        return acceptedFileExtensions.contains(ext)
    }
}


