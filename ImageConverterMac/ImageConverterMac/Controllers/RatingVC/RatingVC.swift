//
//  RatingVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 06/08/2025.
//

import Cocoa

class RatingVC: NSViewController {
    
    //MARK: Outlets
    @IBOutlet weak var btnStar1: NSButton!
    @IBOutlet weak var btnStar2: NSButton!
    @IBOutlet weak var btnStar3: NSButton!
    @IBOutlet weak var btnStar4: NSButton!
    @IBOutlet weak var btnStar5: NSButton!
    @IBOutlet weak var btnReview: NSButton!
    @IBOutlet weak var viewStar1: HoverView!
    @IBOutlet weak var viewStar2: HoverView!
    @IBOutlet weak var viewStar3: HoverView!
    @IBOutlet weak var viewStar4: HoverView!
    @IBOutlet weak var viewStar5: HoverView!
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    //MARK: Setup View
    func setupView() {
        btnReview.isEnabled = false
        btnReview.isUserInteractionEnabled = false
        checkHover()
    }
    
    //MARK: Utility Methods
    
    func checkHover() {
        viewStar1.onHoverStateChanged = { isHovered,btnView in
            if isHovered {
                self.btnStar1.image = NSImage(resource: ImageResource.imgStarFill)
            }else{
                self.btnStar1.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar2.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar3.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar4.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar5.image = NSImage(resource: ImageResource.imgStar)
            }
        }
        
        viewStar2.onHoverStateChanged = { isHovered,btnView in
            if isHovered {
                self.btnStar1.image = NSImage(resource: ImageResource.imgStarFill)
                self.btnStar2.image = NSImage(resource: ImageResource.imgStarFill)
            }else{
                self.btnStar1.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar2.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar3.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar4.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar5.image = NSImage(resource: ImageResource.imgStar)
            }
        }
        
        viewStar3.onHoverStateChanged = { isHovered,btnView in
            if isHovered {
                self.btnStar1.image = NSImage(resource: ImageResource.imgStarFill)
                self.btnStar2.image = NSImage(resource: ImageResource.imgStarFill)
                self.btnStar3.image = NSImage(resource: ImageResource.imgStarFill)
            }else{
                self.btnStar1.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar2.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar3.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar4.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar5.image = NSImage(resource: ImageResource.imgStar)
            }
        }
        
        viewStar4.onHoverStateChanged = { isHovered,btnView in
            if isHovered {
                self.btnStar1.image = NSImage(resource: ImageResource.imgStarFill)
                self.btnStar2.image = NSImage(resource: ImageResource.imgStarFill)
                self.btnStar3.image = NSImage(resource: ImageResource.imgStarFill)
                self.btnStar4.image = NSImage(resource: ImageResource.imgStarFill)
            }else{
                self.btnStar1.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar2.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar3.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar4.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar5.image = NSImage(resource: ImageResource.imgStar)
            }
        }
        
        viewStar5.onHoverStateChanged = { isHovered,btnView in
            if isHovered {
                self.btnStar1.image = NSImage(resource: ImageResource.imgStarFill)
                self.btnStar2.image = NSImage(resource: ImageResource.imgStarFill)
                self.btnStar3.image = NSImage(resource: ImageResource.imgStarFill)
                self.btnStar4.image = NSImage(resource: ImageResource.imgStarFill)
                self.btnStar5.image = NSImage(resource: ImageResource.imgStarFill)
            }else{
                self.btnStar1.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar2.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar3.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar4.image = NSImage(resource: ImageResource.imgStar)
                self.btnStar5.image = NSImage(resource: ImageResource.imgStar)
            }
        }
    }
    
    //MARK: Button Action
    @IBAction func btnCloseAction(_ sender: Any) {
        dismiss(nil)
    }
    @IBAction func btnEmailAction(_ sender: Any) {
        Utility.openEmail(address: supportEmail, subject: "Support Question", body: "")
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}
