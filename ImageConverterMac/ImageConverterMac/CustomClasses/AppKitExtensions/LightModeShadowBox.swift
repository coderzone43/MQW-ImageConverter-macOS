//
//  LightModeShadowBox.swift
//  PDFConverterMac
//
//  Created by MacBook Pro on 04/08/2025.
//


import AppKit

@IBDesignable
class LightModeShadowBox: NSBox {

    @IBInspectable var shadowOpacity: Float = 0.05
    @IBInspectable var shadowRadius: CGFloat = 10.0
    @IBInspectable var shadowOffsetY: CGFloat = -1.0
    @IBInspectable var shadowColor: NSColor = .black

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateShadow()
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        updateShadow()
    }

    private func updateShadow() {
        wantsLayer = true
        guard let layer = self.layer else { return }

        if effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .aqua {
            // Light mode: show shadow
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOpacity = shadowOpacity
            layer.shadowOffset = CGSize(width: 0, height: shadowOffsetY)
            layer.shadowRadius = shadowRadius
            layer.masksToBounds = false
        } else {
            // Dark mode: remove shadow
            layer.shadowOpacity = 0
        }
    }
}

