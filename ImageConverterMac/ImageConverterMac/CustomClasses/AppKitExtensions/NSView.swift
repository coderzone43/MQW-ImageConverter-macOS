//
//  NSView.swift
//  MS-AppLauncher
//
//  Created by Ahsan Murtaza on 24/06/2024.
//

import Cocoa

extension NSView {
    var center: CGPoint {
        get { return CGPoint(x: NSMidX(frame), y: NSMidY(frame)) }
        set {
            setFrameOrigin(CGPoint(x: newValue.x - frame.width / 2.0, y: newValue.y - frame.height / 2.0))
        }
    }
    func addInfiniteScaleAnimation() {
        let scaleUpAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleUpAnimation.speed = 0.5
        scaleUpAnimation.toValue = 1.05
        scaleUpAnimation.duration = 0.5
        scaleUpAnimation.autoreverses = true
        scaleUpAnimation.repeatCount = .infinity
        scaleUpAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        wantsLayer = true
        layer?.add(scaleUpAnimation, forKey: "scaleUpDown")
    }

    func roundSpecificCorners(cornerRadius: CGFloat = 20, maskedCorners: CACornerMask) {
        wantsLayer = true
        layer?.cornerRadius = cornerRadius
        layer?.maskedCorners = maskedCorners
        layer?.borderColor = NSColor.clear.cgColor
        layer?.borderWidth = 0
        layer?.masksToBounds = true
    }

    func setAnchorPoint(anchorPoint: CGPoint) {
        wantsLayer = true
        if let layer = self.layer {
            var newPoint = NSPoint(
                x: self.bounds.size.width * anchorPoint.x,
                y: self.bounds.size.height * anchorPoint.y
            )
            var oldPoint = NSPoint(
                x: self.bounds.size.width * layer.anchorPoint.x,
                y: self.bounds.size.height * layer.anchorPoint.y
            )

            newPoint = newPoint.applying(layer.affineTransform())
            oldPoint = oldPoint.applying(layer.affineTransform())

            var position = layer.position

            position.x -= oldPoint.x
            position.x += newPoint.x

            position.y -= oldPoint.y
            position.y += newPoint.y

            layer.anchorPoint = anchorPoint
            layer.position = position
        }
    }

    func animationSpiral(
        duration: CFTimeInterval,
        repeatCount: Float,
        speed: Float = 1.0,
        timing: CAMediaTimingFunction = CAMediaTimingFunction(name: .linear),
        fromValue: CGFloat = 0.0,
        toValue: CGFloat = 2 * CGFloat.pi
    ) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")

        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.repeatCount = repeatCount
        animation.speed = speed
        animation.timingFunction = timing
        wantsLayer = true
        layer?.add(animation, forKey: "rotationAnimation")
    }

    func stopSpiralAnimation() {
        layer?.removeAnimation(forKey: "rotationAnimation")
    }

    func animationFade() {
        let animation = CATransition()
        animation.duration = 0.1
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        wantsLayer = true
        layer?.add(animation, forKey: nil)
    }
}

extension NSView {
    var parentViewController: NSViewController? {
        var responder: NSResponder? = self.nextResponder
        while responder != nil {
            if let viewController = responder as? NSViewController {
                return viewController
            }
            responder = responder?.nextResponder
        }
        return nil
    }
}

extension NSView {
    @IBInspectable var borderWidthSize: CGFloat {
        get {
            return layer?.borderWidth ?? 0
        }
        set {
            wantsLayer = true
            layer?.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: NSColor? {
        get {
            guard let cgColor = layer?.borderColor else { return nil }
            return NSColor(cgColor: cgColor)
        }
        set {
            wantsLayer = true
            layer?.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable var bdrColor: NSColor? {
        get {
            guard let cgColor = layer?.borderColor else { return nil }
            return NSColor(cgColor: cgColor)
        }
        set {
            wantsLayer = true
            layer?.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable var backgroundColor: NSColor? {
        get {
            guard let layerColor = layer?.backgroundColor else {
                return nil
            }
            return NSColor(cgColor: layerColor)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
    @IBInspectable var bgColor: NSColor? {
        get {
            guard let layerColor = layer?.backgroundColor else {
                return nil
            }
            return NSColor(cgColor: layerColor)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer?.cornerRadius ?? 0
        }
        set {
            wantsLayer = true
            layer?.cornerRadius = newValue
            layer?.masksToBounds = newValue > 0
        }
    }
}

extension NSView {
    func addTapGesture(target: Any, action: Selector) {
        let gesture = NSClickGestureRecognizer(target: target, action: action)
        addGestureRecognizer(gesture)
    }
}

extension NSView {
    func setViewHidden(_ hidden: Bool, duration: TimeInterval = 0.25) {
        if hidden {
            // Fade out
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = duration
                animator().alphaValue = 0
            }, completionHandler: { [weak self] in
                self?.isHidden = true
            })
        } else {
            // Make view visible and fade in
            alphaValue = 0
            isHidden = false
            NSAnimationContext.runAnimationGroup({ [weak self] context in
                context.duration = duration
                self?.animator().alphaValue = 1
            })
        }
    }
}

class DisableInteraction: NSView {

    var userInteractionEnabled: Bool = true
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        if userInteractionEnabled {
            return super.hitTest(point)
        }
        return nil
    }
}

extension NSView {
    var isUserInteractionEnabled: Bool {
        get { alphaValue == 1 }
        set { newValue ? (alphaValue = 1) : (alphaValue = 0.5) }
    }
}

extension NSView {
    class func view<T: NSView>(with owner: AnyObject?,
                               bundle: Bundle = Bundle.main) throws -> T {
        let className = String(describing: self)
        return try self.view(from: className, owner: owner, bundle: bundle)
    }

    class func view<T: NSView>(from nibName: String,
                               owner: AnyObject?,
                               bundle: Bundle = Bundle.main) throws -> T {
        var topLevelObjects: NSArray? = []
        guard bundle.loadNibNamed(NSNib.Name(nibName), owner: owner, topLevelObjects: &topLevelObjects),
            let objects = topLevelObjects else {
                throw NibLoadingError.nibNotFound
        }

        let views = objects.filter { object in object is NSView }

        if views.count > 1 {
            throw NibLoadingError.multipleTopLevelObjectsFound
        }

        guard let view = views.first as? T else {
            throw NibLoadingError.topLevelObjectNotFound
        }
        return view
    }
}

enum NibLoadingError: Error {
    case nibNotFound
    case topLevelObjectNotFound
    case multipleTopLevelObjectsFound
}

extension NSView {
    private static let shimmerAnimationKey = "shimmerAnimation"
    private static let shimmerLayerName = "skeletonShimmerLayer"
    private static let backgroundLayerName = "skeletonBackgroundLayer"
    
    /// Show shimmer and start listening to appearance changes
    func showSkeletonShimmer() {
        if layer?.sublayers?.contains(where: { $0.name == Self.shimmerLayerName }) == true {
            return
        }
        
        wantsLayer = true
        addShimmerLayers()
    }
    
    /// Show skeleton shimmer overlay with automatic colors for dark/light mode
    func addShimmerLayers() {
        // Prevent multiple shimmer layers
        if layer?.sublayers?.contains(where: { $0.name == Self.shimmerLayerName }) == true {
            return
        }
        
        wantsLayer = true
        
        // Determine colors based on appearance
        let isDarkMode = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        
        let backgroundColor: CGColor
        let darkColor: CGColor
        let lightColor: CGColor
        
        if isDarkMode {
            // Dark mode colors: darker background, subtle shimmer
            backgroundColor = NSColor(calibratedWhite: 0.15, alpha: 1.0).cgColor
            darkColor = NSColor(calibratedWhite: 0.25, alpha: 1.0).cgColor
            lightColor = NSColor(calibratedWhite: 0.35, alpha: 1.0).cgColor
        } else {
            // Light mode colors: light background, brighter shimmer
            backgroundColor = NSColor(calibratedWhite: 0.9, alpha: 1.0).cgColor
            darkColor = NSColor(calibratedWhite: 0.85, alpha: 1.0).cgColor
            lightColor = NSColor(calibratedWhite: 0.95, alpha: 1.0).cgColor
        }
        
        // Add background layer
        let bgLayer = CALayer()
        bgLayer.name = Self.backgroundLayerName
        bgLayer.frame = bounds
        bgLayer.backgroundColor = backgroundColor
        bgLayer.cornerRadius = layer?.cornerRadius ?? 0
        layer?.addSublayer(bgLayer)
        
        // Add shimmer gradient layer on top
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = Self.shimmerLayerName
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer?.cornerRadius ?? 0
        gradientLayer.colors = [darkColor, lightColor, darkColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer?.addSublayer(gradientLayer)
        
        // Animate shimmer
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: Self.shimmerAnimationKey)
    }
    
    /// Hide skeleton shimmer overlay and background
    func hideSkeletonShimmer() {
        guard let sublayers = layer?.sublayers else { return }
        for sublayer in sublayers {
            if sublayer.name == Self.shimmerLayerName || sublayer.name == Self.backgroundLayerName {
                sublayer.removeAllAnimations()
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    /// Optional: Call this to update shimmer colors if appearance changes dynamically
    func updateSkeletonShimmerColorsIfNeeded() {
        guard let sublayers = layer?.sublayers else { return }
        
        let isDarkMode = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        
        let backgroundColor: CGColor
        let darkColor: CGColor
        let lightColor: CGColor
        
        if isDarkMode {
            backgroundColor = NSColor(calibratedWhite: 0.15, alpha: 1.0).cgColor
            darkColor = NSColor(calibratedWhite: 0.25, alpha: 1.0).cgColor
            lightColor = NSColor(calibratedWhite: 0.35, alpha: 1.0).cgColor
        } else {
            backgroundColor = NSColor(calibratedWhite: 0.9, alpha: 1.0).cgColor
            darkColor = NSColor(calibratedWhite: 0.85, alpha: 1.0).cgColor
            lightColor = NSColor(calibratedWhite: 0.95, alpha: 1.0).cgColor
        }
        
        for sublayer in sublayers {
            if sublayer.name == Self.backgroundLayerName {
                sublayer.backgroundColor = backgroundColor
            } else if let gradient = sublayer as? CAGradientLayer, sublayer.name == Self.shimmerLayerName {
                gradient.colors = [darkColor, lightColor, darkColor]
            }
        }
    }
}
