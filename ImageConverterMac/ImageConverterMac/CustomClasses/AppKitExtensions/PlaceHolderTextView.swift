//
//  PlaceHolderTextView.swift
//  GrowMacOS
//
//  Created by Macbook Pro on 18/05/2025.
//

import Foundation
import AppKit

protocol PlaceHolderTextViewDelegate: AnyObject {
  func placeHolderTextView(_ textView: PlaceHolderTextView, didTapSendWithText text: String)
}

class PlaceHolderTextView: NSTextView {
   
  weak var textViewDelegate: PlaceHolderTextViewDelegate?
   
  // MARK: - Placeholder
  @IBInspectable var placeholderString: String = "Placeholder" {
    didSet {
      needsDisplay = true
    }
  }
   
  @IBInspectable var placeholderTextColor: NSColor = .placeholderTextColor {
    didSet {
      needsDisplay = true
    }
  }

  // MARK: - Initializers
  override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
    super.init(frame: frameRect, textContainer: container)
    configure()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }

  private func configure() {
    drawsBackground = true
    postsFrameChangedNotifications = true

    NotificationCenter.default.addObserver(self,
                        selector: #selector(textDidChange(_:)),
                        name: NSText.didChangeNotification,
                        object: self)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
   
  //MARK: - KeyDonw
  override func keyDown(with event: NSEvent) {
      let isEnter = event.keyCode == 36 || event.keyCode == 76 // Return and Enter keys
      let shiftPressed = event.modifierFlags.contains(.shift)

      if isEnter && !shiftPressed {
        // Call send instead of inserting newline
        textViewDelegate?.placeHolderTextView(self, didTapSendWithText: string)
        // Do not call super, so no newline is inserted
      } else {
        // For shift+enter or any other key, default behavior (insert newline)
        super.keyDown(with: event)
      }
    }

  // MARK: - Draw
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
     
    guard string.isEmpty else { return }
     
    let placeholderAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: placeholderTextColor,
      .font: self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
    ]

    let placeholderRect = NSMakeRect(5, 0, bounds.width - 10, bounds.height)
    placeholderString.draw(in: placeholderRect, withAttributes: placeholderAttributes)
  }

  // MARK: - Notifications
  @objc private func textDidChange(_ notification: Notification) {
    needsDisplay = true
  }
}
