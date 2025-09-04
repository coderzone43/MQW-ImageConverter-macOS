//
//  QuickLookPreview.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 04/09/2025.
//


import Cocoa
import Quartz

class QuickLookPreview: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    
    static let shared = QuickLookPreview()
    
    private var fileURL: URL?
    
    func preview(file url: URL) {
        self.fileURL = url
        
        if let panel = QLPreviewPanel.shared() {
            panel.dataSource = self
            panel.delegate = self
            panel.makeKeyAndOrderFront(nil)
        }
    }
    
    // MARK: - QLPreviewPanelDataSource
    
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return fileURL == nil ? 0 : 1
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return fileURL as NSURL?
    }
    
    // MARK: - Optional: Allow ESC to close
    
    func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        if event.type == .keyDown, event.keyCode == 53 { // ESC key
            panel.orderOut(nil)
            return true
        }
        return false
    }
}
