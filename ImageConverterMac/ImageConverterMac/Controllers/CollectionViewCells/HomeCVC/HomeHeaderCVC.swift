//
//  HomeHeaderCVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/08/2025.
//

import Cocoa

class HomeHeaderCVC: NSView,NSCollectionViewElement {
    
    let titleLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Test")
        label.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        label.alignment = .left
        label.bgColor = NSColor.appClear
        label.textColor = .black1
        label.isBezeled = false
        label.drawsBackground = false // Ensure no background covers it
        label.isEditable = false
        label.isSelectable = false
        return label
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            //titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    
    func configure(with title: String) {
        titleLabel.stringValue = title
    }
    
    func setLabelPosition(top: Bool) {
        if !top {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10)
            ])
        }
    }
}
