//
//  ProPaymentCVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 04/09/2025.
//

import Cocoa

class ProPaymentCVC: NSCollectionViewItem {
    
    @IBOutlet weak var lblPackageName: NSTextField!
    @IBOutlet weak var lblPrice: NSTextField!
    @IBOutlet weak var lblPerDayPrice: NSTextField!
    @IBOutlet weak var lblSave: NSTextField!
    @IBOutlet weak var viewContainer: NSBox!
    @IBOutlet weak var viewSave: NSBox!
    @IBOutlet weak var imgRadio: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
