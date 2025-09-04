//
//  NSTextView.swift
//  AiInteriorMac
//
//  Created by MacBook Pro on 26/05/2025.
//

import Foundation
import AppKit

extension NSTextView {
    func scrollToBottom() {
        if let layoutManager = self.layoutManager,
           let textContainer = self.textContainer {

            let glyphRange = layoutManager.glyphRange(for: textContainer)
            let rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

            let bottomPoint = NSPoint(x: 0, y: rect.origin.y + rect.size.height)
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 1 // Duration of the animation
                self.scroll(bottomPoint)
            }, completionHandler: nil)
        }
    }
}
