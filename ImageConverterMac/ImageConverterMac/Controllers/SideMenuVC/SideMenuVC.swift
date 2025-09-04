//
//  SideMenuVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/08/2025.
//

import Cocoa

protocol SideBarControllerSelectionDelegate: AnyObject {
    func sideBarController(_ index: Int)
}

class SideMenuVC: NSViewController,Shareable {

    //MARK: Outlets
    @IBOutlet weak var viewHome: NSBox!
    @IBOutlet weak var viewTools: NSBox!
    @IBOutlet weak var viewHistory: NSBox!
    
    @IBOutlet weak var imgHome: NSImageView!
    @IBOutlet weak var lblHome: NSTextField!
    
    @IBOutlet weak var imgTools: NSImageView!
    @IBOutlet weak var lblTools: NSTextField!
    
    @IBOutlet weak var imgHistory: NSImageView!
    @IBOutlet weak var lblHistory: NSTextField!
    
    @IBOutlet weak var imgArrow: NSImageView!
    @IBOutlet weak var stackSettings: NSStackView!
    @IBOutlet weak var btnDisplay: NSButton!
    @IBOutlet weak var btnShare: NSButton!
    
    @IBOutlet weak var viewSettingBox1: HoverBox!
    @IBOutlet weak var viewSettingBox2: HoverBox!
    @IBOutlet weak var viewSettingBox3: HoverBox!
    @IBOutlet weak var viewSettingBox4: HoverBox!
    @IBOutlet weak var viewSettingBox5: HoverBox!
    @IBOutlet weak var viewSettingBox6: HoverBox!
    @IBOutlet weak var viewSettingBox7: HoverBox!
    
    @IBOutlet weak var viewUpgrade: NSView!
    
    var isSettingsShow = false
    var delegate: SideBarControllerSelectionDelegate?
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if isPremiumUser() {
            self.changeStatus()
        }
    }
    
    //MARK: Setup View
    func setupView() {
        setHoverBoxes()
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeStatus), name: .PremiumPurchasedSuccessed, object: nil)
    }
    
    //MARK: Utility Methods
    
    @objc func changeStatus() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Hide any loading HUD (if shown) and update the 'Go Pro' button visibility
            Utility.hideHud()
            self.viewUpgrade.isHidden = true
        }
    }
    
    func createDisplayMenu() -> NSMenu {
        let menu = NSMenu()
        
        let systemItem = NSMenuItem(title: "System", action: #selector(DisplayModeTapped), keyEquivalent: "")
        systemItem.tag = 1
        systemItem.target = self
        if Utility.getDefaultObject(forKey: strDisplayMode) == DisplayModeOptions.System.rawValue {
            systemItem.state = .on
        }
        menu.addItem(systemItem)
        
        let darkItem = NSMenuItem(title: "Dark", action: #selector(DisplayModeTapped), keyEquivalent: "")
        darkItem.tag = 2
        if Utility.getDefaultObject(forKey: strDisplayMode) == DisplayModeOptions.Dark.rawValue {
            darkItem.state = .on
        }
        darkItem.target = self
        menu.addItem(darkItem)
        
        let lightItem = NSMenuItem(title: "Light", action: #selector(DisplayModeTapped), keyEquivalent: "")
        lightItem.tag = 3
        if Utility.getDefaultObject(forKey: strDisplayMode) == DisplayModeOptions.Light.rawValue {
            lightItem.state = .on
        }
        lightItem.target = self
        menu.addItem(lightItem)
        
        return menu
    }
    
    func setHoverBoxes() {
        viewSettingBox1.onHoverStateChanged = { isHovered, box in
            box.fillColor = isHovered ? .white4 : .appClear
        }
        viewSettingBox2.onHoverStateChanged = { isHovered, box in
            box.fillColor = isHovered ? .white4 : .appClear
        }
        viewSettingBox3.onHoverStateChanged = { isHovered, box in
            box.fillColor = isHovered ? .white4 : .appClear
        }
        viewSettingBox4.onHoverStateChanged = { isHovered, box in
            box.fillColor = isHovered ? .white4 : .appClear
        }
        viewSettingBox5.onHoverStateChanged = { isHovered, box in
            box.fillColor = isHovered ? .white4 : .appClear
        }
        viewSettingBox6.onHoverStateChanged = { isHovered, box in
            box.fillColor = isHovered ? .white4 : .appClear
        }
        viewSettingBox7.onHoverStateChanged = { isHovered, box in
            box.fillColor = isHovered ? .white4 : .appClear
        }
    }
    
    //MARK: Button Action
    @IBAction func btnHomeAction(_ sender: Any) {
        viewHome.fillColor = .primary1
        viewTools.fillColor = .appClear
        viewHistory.fillColor = .appClear
        
        lblHome.textColor = .appWhiteOnly
        lblTools.textColor = .black1
        lblHistory.textColor = .black1
        
        imgHome.image = NSImage(resource: ImageResource.imgSMHomeSelected)
        imgTools.image = NSImage(resource: ImageResource.imgSMTools)
        imgHistory.image = NSImage(resource: ImageResource.imgSMHistory)
        
        delegate?.sideBarController(0)
    }
    @IBAction func btnToolsAction(_ sender: Any) {
        viewHome.fillColor = .appClear
        viewTools.fillColor = .primary1
        viewHistory.fillColor = .appClear
        
        lblHome.textColor = .black1
        lblTools.textColor = .appWhiteOnly
        lblHistory.textColor = .black1
        
        imgHome.image = NSImage(resource: ImageResource.imgSMHome)
        imgTools.image = NSImage(resource: ImageResource.imgSMToolsSelected)
        imgHistory.image = NSImage(resource: ImageResource.imgSMHistory)
        
        delegate?.sideBarController(1)
    }
    @IBAction func btnHistoryAction(_ sender: Any) {
        viewHome.fillColor = .appClear
        viewTools.fillColor = .appClear
        viewHistory.fillColor = .primary1
        
        lblHome.textColor = .black1
        lblTools.textColor = .black1
        lblHistory.textColor = .appWhiteOnly
        
        imgHome.image = NSImage(resource: ImageResource.imgSMHome)
        imgTools.image = NSImage(resource: ImageResource.imgSMTools)
        imgHistory.image = NSImage(resource: ImageResource.imgSMHistorySelected)
        
        delegate?.sideBarController(2)
    }
    @IBAction func btnSettingsAction(_ sender: Any) {
        if isSettingsShow {
            isSettingsShow = false
            imgArrow.image = NSImage(resource: ImageResource.imgSMArrow)
            stackSettings.isHidden = true
        }else{
            isSettingsShow = true
            imgArrow.image = NSImage(resource: ImageResource.imgSMArrowDown)
            stackSettings.isHidden = false
        }
    }
    @IBAction func btnRestoreAction(_ sender: Any) {
    }
    @IBAction func btnDisplayAction(_ sender: NSButton) {
        let DisplayMenu = createDisplayMenu()
        let buttonBounds = btnDisplay.bounds
        let menuOrigin = NSPoint(x: 0, y: buttonBounds.height)
        DisplayMenu.popUp(positioning: nil, at: menuOrigin, in: btnDisplay)
    }
    @IBAction func btnRateAction(_ sender: Any) {
        guard let window = self.view.window else { return }
        window.contentViewController?.openURLinExternalBrowser(url: urlRate)
    }
    @IBAction func btnShareAction(_ sender: Any) {
        share(sender: btnShare, items: [urlAppStore])
    }
    @IBAction func btnPrivacyAction(_ sender: Any) {
        guard let window = self.view.window else { return }
        window.contentViewController?.openURLinExternalBrowser(url: urlPrivacy)
    }
    @IBAction func btnTermsAction(_ sender: Any) {
        guard let window = self.view.window else { return }
        window.contentViewController?.openURLinExternalBrowser(url: urlTerms)
    }
    @objc func DisplayModeTapped(item:NSMenuItem) {
        ud.set(true, forKey: strViewModeSetFromApp)
        
        if item.tag == 1 {
            Utility.saveDefaultObject(obj: DisplayModeOptions.System.rawValue, forKey: strDisplayMode)
            NSApp.appearance = nil
        }
        if item.tag == 2 {
            Utility.saveDefaultObject(obj: DisplayModeOptions.Dark.rawValue, forKey: strDisplayMode)
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
        if item.tag == 3 {
            Utility.saveDefaultObject(obj: DisplayModeOptions.Light.rawValue, forKey: strDisplayMode)
            NSApp.appearance = NSAppearance(named: .aqua)
        }
    }
    @IBAction func btnUpgradeAction(_ sender: Any) {
        let vc = ProPaymentVC()
        self.presentAsSheet(vc)
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}
