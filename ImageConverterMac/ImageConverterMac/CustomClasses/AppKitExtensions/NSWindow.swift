//
//  NSWindow.swift
//  MS-AppLauncher
//
//  Created by Ahsan Murtaza on 26/06/2024.
//

import Foundation
import Cocoa

extension NSWindow {
    func setupWindowForWebViewScreen() {
        styleMask.insert(.closable)
        styleMask.insert(.miniaturizable)
        styleMask.insert(.resizable)
        let fixSize = NSSize(width: 1200, height: 780)
        minSize = fixSize
        maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        setIsZoomed(false)
        setContentSize(fixSize)
        center()
    }

    func setupWindowForInstrutionsScreen() {
        styleMask.remove(.resizable)
        styleMask.insert(.closable)
        styleMask.insert(.miniaturizable)
    }
}
