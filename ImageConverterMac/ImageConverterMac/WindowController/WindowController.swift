//
//  WindowController.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/08/2025.
//

import Cocoa

class WindowController: NSWindowController {
    
    static var instance: WindowController?
    var mainContentSplitItem: NSSplitViewItem!
    
    @discardableResult
    class func shared() -> WindowController {
        if let existing = instance {
            return existing
        }
        let controller = NSStoryboard(name: "Main", bundle: nil)
            .instantiateController(withIdentifier: "WindowController") as! WindowController
        instance = controller
        return controller
    }
    
    lazy var sideViewController: SideMenuVC = {
        let viewController = SideMenuVC()
        return viewController
    }()
    
    lazy var homeViewController: HomeVC = {
        let viewController = HomeVC()
        return viewController
    }()

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        mainContentSplitItem = NSSplitViewItem(viewController: homeViewController)
        mainContentSplitItem?.minimumThickness = 800
        
        let sideBarItem = NSSplitViewItem(sidebarWithViewController: sideViewController)
        sideBarItem.maximumThickness = 220
        sideBarItem.minimumThickness = 220
        sideBarItem.canCollapse = false
        
        sideViewController.delegate = homeViewController
        
        splitMainViewController.addSplitViewItem(sideBarItem)
        splitMainViewController.addSplitViewItem(mainContentSplitItem)
        
        window?.minSize = .init(width: 1025, height: 790)
        window?.setContentSize(.init(width: 1025, height: 790))
        
        //window?.toolbar = nil
        //window?.toolbarStyle = .unified
        window?.contentViewController = splitMainViewController
        window?.styleMask = [.titled,.closable,.miniaturizable,.fullSizeContentView,.resizable]
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        
        //window?.title = "Transcriptions"
        window?.titleVisibility = .hidden
    }

}
