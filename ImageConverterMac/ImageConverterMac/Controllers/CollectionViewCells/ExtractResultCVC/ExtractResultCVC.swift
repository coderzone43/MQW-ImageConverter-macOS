//
//  ExtractResultCVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 20/08/2025.
//

import Cocoa

class ExtractResultCVC: NSCollectionViewItem {

    @IBOutlet weak var imgText: NSImageView!
    @IBOutlet weak var lblImgName: NSTextField!
    @IBOutlet weak var lblText: NSTextField!
    @IBOutlet weak var btnCopy: NSButton!
    @IBOutlet weak var btnDownload: NSButton!
    
    var actionCopy: (() -> Void)?
    var actionDownload: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func btnCopyAction(_ sender: Any) {
        actionCopy?()
    }
    @IBAction func btnDownloadAction(_ sender: Any) {
        actionDownload?()
    }
    
}
