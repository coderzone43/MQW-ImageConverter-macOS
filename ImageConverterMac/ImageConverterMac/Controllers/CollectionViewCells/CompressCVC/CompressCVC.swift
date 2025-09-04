//
//  CompressCVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 21/08/2025.
//

import Cocoa

class CompressCVC: NSCollectionViewItem {

    @IBOutlet weak var imgCompress: NSImageView!
    @IBOutlet weak var lblSize: NSTextField!
    
    var actionRemove: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func configure(with model: CompressibleImage) {
        imgCompress.image = model.image
        lblSize.stringValue = "\(model.originalSizeString) → \(model.compressedSizeString)"
    }
    
    @IBAction func btnRemoveAction(_ sender: Any) {
        actionRemove?()
    }
    
}
