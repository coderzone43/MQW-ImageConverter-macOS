//
//  ToolTipView.swift
//  ChatGPT
//
//  Created by Muhammad Usama Amin on 13/05/2025.
//

import Foundation
import AppKit
class ToolTipView: NSView {
    
    @IBOutlet weak var toolLabel: NSTextField!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        loadXib()
    }
    
    
    private func loadXib(){
        var topLevelObjects: NSArray?
        let nib = NSNib(nibNamed: "ToolTipView", bundle: nil)
        nib?.instantiate(withOwner: self, topLevelObjects: &topLevelObjects)
        guard let view = topLevelObjects?.first(where: { $0 is NSView }) as? NSView else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
