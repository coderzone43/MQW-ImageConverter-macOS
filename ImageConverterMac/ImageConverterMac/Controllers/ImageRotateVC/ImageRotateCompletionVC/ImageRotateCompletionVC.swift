//
//  ImageRotateCompletionVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 20/08/2025.
//

import Cocoa

class ImageRotateCompletionVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var imgRotate: NSImageView!
    
    var actionDownload: (() -> Void)?
    var imgSelected: NSImage!
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    //MARK: Setup View
    func setupView() {
        imgRotate.image = imgSelected
    }
    
    //MARK: Utility Methods
    
    //MARK: Button Action
    @IBAction func btnCloseAction(_ sender: Any) {
        dismiss(nil)
    }
    @IBAction func btnDownloadAction(_ sender: Any) {
        actionDownload?()
        dismiss(nil)
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}
