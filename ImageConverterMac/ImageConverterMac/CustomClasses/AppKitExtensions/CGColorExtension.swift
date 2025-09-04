//
//  CGColorExtension.swift
//  MS-AppLauncher
//
//  Created by Macbook Pro on 31/12/2024.
//

import AppKit

extension CGColor {
    var nsColor: NSColor? { .init(cgColor: self) }
}
