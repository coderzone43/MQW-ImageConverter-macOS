//
//  ImgListCVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 07/08/2025.
//

import Cocoa

class ImgListCVC: NSCollectionViewItem {

    @IBOutlet weak var imgFile: NSImageView!
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var btnClose: NSButton!
    @IBOutlet weak var btnDownload: NSButton!
    
    var actionDelete: (() -> Void)?
    var actionDownload: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func btnCloseAction(_ sender: Any) {
        actionDelete?()
    }
    @IBAction func btnDownloadAction(_ sender: Any) {
        actionDownload?()
    }
    
}
