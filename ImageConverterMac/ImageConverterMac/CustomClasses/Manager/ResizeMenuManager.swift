//
//  ResizeMenuManager.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 25/08/2025.
//


import Cocoa

protocol ResizeMenuManagerDelegate: AnyObject {
    func didSelectFinalDimensions(width: CGFloat, height: CGFloat, title: String, fromFirstMenu: Bool)
    func showSecondMenu(_ secondMenu: NSMenu)
    func titleForFirstMenuBeforeShowinfgSecondMenu(title:String)
}

class ResizeMenuManager {
    
    weak var delegate: ResizeMenuManagerDelegate?
    
    // First & second NSMenu
    var firstMenu: NSMenu!
    var secondMenu: NSMenu!
    
    var selectedWidth: CGFloat = 0
    var selectedHeight: CGFloat = 0
    
    init() {
        setupMenus()
    }
    
    private func setupMenus() {
        firstMenu = NSMenu()
        secondMenu = NSMenu()
        addFirstMenuItems()
    }
    
    // Returns tuple: (secondMenu to show?, showSecondMenu flag)
    @objc func firstMenuSelected(_ sender: NSMenuItem) {
        if let size = sender.representedObject as? (CGFloat, CGFloat) {
            // Pixel size selected → no second menu
            selectedWidth = size.0
            selectedHeight = size.1
            delegate?.didSelectFinalDimensions(width: selectedWidth, height: selectedHeight, title: sender.title, fromFirstMenu: true)
        } else {
            // Platform selected → show second menu
            let platform = sender.title
            delegate?.titleForFirstMenuBeforeShowinfgSecondMenu(title: platform)
            populateSecondMenu(for: platform)
            delegate?.showSecondMenu(secondMenu)
        }
    }
    
    @objc func secondMenuSelected(_ sender: NSMenuItem) {
        if let (width, height) = sender.representedObject as? (CGFloat, CGFloat) {
            selectedWidth = width
            selectedHeight = height
            delegate?.didSelectFinalDimensions(width: selectedWidth, height: selectedHeight, title: sender.title, fromFirstMenu: false)
        }
    }
    
    private func addFirstMenuItems() {
        let firstMenuData: [(String, (CGFloat, CGFloat)?)] = [
            //("Custom", nil),
            ("320 x 240 (pixels)", (320, 240)),
            ("640 x 480 (pixels)", (640, 480)),
            ("800 x 600 (pixels)", (800, 600)),
            ("1024 x 768 (pixels)", (1024, 768)),
            ("1280 x 1024 (pixels)", (1280, 1024)),
            ("1280 x 720 (pixels) HD", (1280, 720)),
            ("1920 x 1080 (pixels) Full HD", (1920, 1080)),
            ("Facebook", nil),
            ("Instagram", nil),
            ("X (Twitter)", nil),
            ("Youtube", nil),
            ("Pinterest", nil),
            ("Linkedin", nil)
        ]
        
        for (title, size) in firstMenuData {
            let item = NSMenuItem(title: title, action: #selector(firstMenuItemSelected(_:)), keyEquivalent: "")
            item.target = self  // <-- important
            item.representedObject = size
            firstMenu.addItem(item)
        }
    }
    
    @objc private func firstMenuItemSelected(_ sender: NSMenuItem) {
        firstMenuSelected(sender)
    }
    
    // MARK: - Populate Second Menu
    func populateSecondMenu(for platform: String) {
        secondMenu.removeAllItems()
        
        var items: [(String, CGFloat, CGFloat)] = []
        
        switch platform {
        case "Facebook":
            items = [
                ("Page cover 820 × 312", 820, 312),
                ("Story 1080 × 1920", 1080, 1920),
                ("Profile image 180 × 180", 180, 180),
                ("Group cover 1640 × 859", 1640, 859),
                ("Post 1200 x 900", 1200, 900)
            ]
        case "Instagram":
            items = [
                ("Story 1080 x 1920", 1080, 1920),
                ("Square 1080 x 1080", 1080, 1080),
                ("Portrait 1080 x 1350", 1080, 1350),
                ("Landscape 1080 x 566", 1080, 566)
            ]
        case "X (Twitter)":
            items = [
                ("Post 1200 x 670", 1200, 670),
                ("Header 1500 × 500", 1500, 500),
                ("Profile image 400 × 400", 400, 400),
                ("Share image 1200 × 675", 1200, 675)
            ]
        case "Youtube":
            items = [
                ("Thumbnail 1280 x 720", 1280, 720),
                ("Channel art 2560 × 1440", 2560, 1440),
                ("Channel icon 800 × 800", 800, 800)
            ]
        case "Pinterest":
            items = [
                ("Pin 735 x 1102", 735, 1102),
                ("Pin 800 × 1200", 800, 1200),
                ("Board cover 222 × 150", 222, 150),
                ("Small thumbnail 55 × 55", 55, 55),
                ("Big Thumbnail 222 × 150", 222, 150)
            ]
        case "Linkedin":
            items = [
                ("Personal background 1584 × 396", 1584, 396),
                ("Company background 1536 × 768", 1536, 768),
                ("Company hero 1128 × 376", 1128, 376),
                ("Square image 1140 × 736", 1140, 736),
                ("LinkedIn image 1200 × 628", 1200, 628),
                ("Company banner 646 × 220", 646, 220),
                ("Profile image 400 × 400", 400, 400),
                ("Company logo 300 × 300", 300, 300),
                ("Square logo 60 × 60", 60, 60)
            ]
        default:
            break
        }
        
        for itemData in items {
            let item = NSMenuItem(title: itemData.0, action: #selector(secondMenuSelected(_:)), keyEquivalent: "")
            item.representedObject = (itemData.1, itemData.2)
            item.target = self
            secondMenu.addItem(item)
        }
    }
}
