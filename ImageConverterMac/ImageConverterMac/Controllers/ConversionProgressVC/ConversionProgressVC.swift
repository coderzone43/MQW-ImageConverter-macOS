//
//  ConversionProgressVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 08/08/2025.
//

import Cocoa

class ConversionProgressVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var lblPercentage: NSTextField!
    @IBOutlet weak var lblTitle: NSTextField!
    
    var cancellationToken: CancellationToken?
    var onCancel: (() -> Void)?
    var strTitle = ""
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    //MARK: Setup View
    func setupView() {
        lblTitle.stringValue = strTitle
    }
    
    //MARK: Utility Methods
    
    func updateProgress(_ percent: Double) {
        let clamped = max(0, min(1, percent))
        progressBar.doubleValue = clamped * 100
        lblPercentage.stringValue = "\(Int(clamped * 100))%"
    }
    
    //MARK: Button Action
    @IBAction func btnCloseAction(_ sender: Any) {
        cancellationToken?.cancel()
        onCancel?()
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
