//
//  ToolBarExtensions.swift
//  GrowMacOS
//
//  Created by Macbook Pro on 16/05/2025.
//

import Cocoa

extension NSToolbar.Identifier {
    static let mainToolBar: NSToolbar.Identifier = .init("mainToolBar")
}

extension NSToolbarItem.Identifier {
    static let transcriptToggel = NSToolbarItem.Identifier(rawValue: "transcriptToggel")
    static let transcriptInfo = NSToolbarItem.Identifier(rawValue: "transcriptInfo")
    static let customLabel = NSToolbarItem.Identifier(rawValue: "customLabel")
    static let secondTrackingSeperator = NSToolbarItem.Identifier(rawValue: "secondTrackingSeperator")
}
