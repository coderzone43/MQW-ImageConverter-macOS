//
//  DownloadedPopupVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 11/08/2025.
//

import Cocoa

class DownloadedPopupVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var lblPopupMsg: NSTextField!
    
    var strMsg = "Downloaded!"
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    //MARK: Setup View
    func setupView() {
        lblPopupMsg.stringValue = strMsg
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.dismiss(nil)
        }
    }
    
    //MARK: Utility Methods
    
    //MARK: Button Action
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}
