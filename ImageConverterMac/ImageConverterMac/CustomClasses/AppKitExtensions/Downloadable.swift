//
//  Downloadable.swift
//  Mather
//
//  Created by Macbook Pro on 28/11/2024.
//

import Cocoa

protocol Downloadable {
    func downloadImage(for window: NSWindow, image: NSImage)
}

extension Downloadable {
    func downloadImage(for window: NSWindow, image: NSImage) {
        guard let jpegData = image.pngData() else { return }
        DispatchQueue.main.async {
            let panel = NSSavePanel()
            panel.canCreateDirectories = false
            panel.allowedContentTypes = [.png]
            panel.nameFieldStringValue = appName + String(Date().timeIntervalSinceReferenceDate) + ".png"
            panel.beginSheetModal(for: window) { result in
                if result == .OK {
                    if let destinationURL = panel.url {
                        do {
                            try jpegData.write(to: destinationURL)
                        } catch {
                            DispatchQueue.main.async {
                                //_ = Utility.dialogOK(question: "Error!", text: "Failed to download photo. Try Again.")
                            }
                            print("Failed to create jpg File: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}
