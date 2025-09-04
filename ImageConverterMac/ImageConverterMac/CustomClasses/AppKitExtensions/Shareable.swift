//
//  Shareable.swift
//  Mather
//
//  Created by Macbook Pro on 28/11/2024.
//

import Cocoa

protocol Shareable {
    func share(sender: NSView, items: [Any])
}

extension Shareable {
    func share(sender: NSView, items: [Any]) {
        if let jpegData = (items.first as? NSImage)?.pngData() {
            do {
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentDirectory.appendingPathComponent(appName + String(Date().timeIntervalSinceReferenceDate)).appendingPathExtension("jpg")
                    try jpegData.write(to: fileURL)
                    
                    let sharingPicker:NSSharingServicePicker = NSSharingServicePicker.init(items: [fileURL])
                    sharingPicker.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
                    
                    print("PDF file created at: \(fileURL.path)")
                }
            } catch {
                DispatchQueue.main.async {
                    //Utility.dialogWithOK(question: "Error!", text: "Failed to share Photo, Try Again.")
                    Utility.dialogWithMsg(message: "Failed to share Photo, Try Again.", window: sender.window ?? NSWindow())
                }
                print("Failed to share Photo, Error: \(error.localizedDescription)")
            }
        } else {
            let sharingPicker:NSSharingServicePicker = NSSharingServicePicker.init(items: items)
            sharingPicker.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
        }
    }
}
