//
//  AppDelegate.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/08/2025.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if (ud.bool(forKey: strViewModeSetFromApp)) {
            if Utility.getDefaultObject(forKey: strDisplayMode) == DisplayModeOptions.System.rawValue {
                NSApp.appearance = nil
            }else if Utility.getDefaultObject(forKey: strDisplayMode) == DisplayModeOptions.Dark.rawValue {
                NSApp.appearance = NSAppearance(named: .darkAqua)
            }else{
                NSApp.appearance = NSAppearance(named: .aqua)
            }
        }
        
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return NSApplication.TerminateReply.terminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

