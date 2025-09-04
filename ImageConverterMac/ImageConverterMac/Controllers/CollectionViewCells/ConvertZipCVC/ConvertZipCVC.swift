//
//  ConvertZipCVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 20/08/2025.
//

import Cocoa

class ConvertZipCVC: NSCollectionViewItem {

    @IBOutlet weak var imgConvert: NSImageView!
    
    var actionRemove: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func btnRemoveAction(_ sender: Any) {
        actionRemove?()
    }
    
}
