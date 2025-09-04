//
//  NSCollectionView.swift
//  MS-AppLauncher
//
//  Created by Ahsan Murtaza on 24/06/2024.
//

import Foundation
import Cocoa

extension NSCollectionView {
    func selectItem(index: Int, section: Int, scrollPosition: NSCollectionView.ScrollPosition = .left) {
        selectItems(at: [IndexPath(item: index, section: section)], scrollPosition: scrollPosition)
    }

    func scrollToTop(animated: Bool) {
            guard let scrollView = enclosingScrollView else { return }

            let targetOffset = NSPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height)

            if animated {
                NSAnimationContext.runAnimationGroup({ context in
                    context.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
                    context.duration = 1
                    scrollView.contentView.animator().setBoundsOrigin(targetOffset)
                }, completionHandler: nil)
            } else {
                scrollView.contentView.setBoundsOrigin(targetOffset)
            }
        }
}

extension NSCollectionView {
    func hideVerticalScroller() {
        enclosingScrollView?.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 2000)
    }
    
    func hideHorizontalScroller() {
        enclosingScrollView?.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 5000, right: 0)
    }
    
    func getNib(name: String) -> NSNib? {
        NSNib(nibNamed: name, bundle: nil)
    }
}

extension NSTableView {
    func hideVerticalScroller() {
        enclosingScrollView?.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 2000)
    }
    
    func hideHorizontalScroller() {
        enclosingScrollView?.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 5000, right: 0)
    }
}
