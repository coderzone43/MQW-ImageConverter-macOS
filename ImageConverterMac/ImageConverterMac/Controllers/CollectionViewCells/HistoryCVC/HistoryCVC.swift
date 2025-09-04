//
//  HistoryCVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 27/08/2025.
//

import Cocoa

class HistoryCVC: NSCollectionViewItem {

    @IBOutlet weak var imgFile: NSImageView!
    @IBOutlet weak var lblFilename: NSTextField!
    @IBOutlet weak var lblFileType: NSTextField!
    @IBOutlet weak var lblSize: NSTextField!
    @IBOutlet weak var btnOption: NSButton!
    
    var actionOptionMenu: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func btnOptionsAction(_ sender: Any) {
        actionOptionMenu?()
    }
    
}
