//
//  WatermarkVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 26/08/2025.
//

import Cocoa

class WatermarkVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var imgSelected: NSImageView!
    @IBOutlet weak var viewContainer: NSBox!
    @IBOutlet weak var btnText: NSButton!
    @IBOutlet weak var btnImage: NSButton!
    @IBOutlet weak var btnAddWatermark: NSButton!
    
    @IBOutlet weak var viewText: NSView!
    @IBOutlet weak var tfText: NSTextField!
    @IBOutlet weak var lblOpacityValue: NSTextField!
    @IBOutlet weak var sliderOpacity: NSSlider!
    @IBOutlet weak var lblSelectedFont: NSTextField!
    @IBOutlet weak var btnSelectFont: NSButton!
    @IBOutlet weak var btnWhite: NSButton!
    @IBOutlet weak var btnBlack: NSButton!
    @IBOutlet weak var btnBlue: NSButton!
    @IBOutlet weak var btnRed: NSButton!
    @IBOutlet weak var btnGreen: NSButton!
    @IBOutlet weak var colorPicker: NSColorWell!
    
    @IBOutlet weak var viewImage: NSView!
    @IBOutlet weak var imgUploadPlaceholder: NSImageView!
    @IBOutlet weak var lblUploadPlaceholder: NSTextField!
    @IBOutlet weak var imgSelectedUpload: NSImageView!
    @IBOutlet weak var btnRemoveImg: NSButton!
    @IBOutlet weak var btnUploadImage: NSButton!
    @IBOutlet weak var lblImgOpacityValue: NSTextField!
    @IBOutlet weak var sliderImgOpacity: NSSlider!
    
    var selectedImageURL: URL!
    var isText = true
    var selectedTextColor = NSColor.appWhiteOnly
    var isTextWatermarkAdded = false
    var isImageWatermarkAdded = false
    var arrFonts: [String] = []
    
    var signatureViews: [SignatureView] = []
    internal var selectedSignatureView: SignatureView?
    
    weak var delegate: DelegateHomeCollectionSelectable?
    
    var signImageView: [SignatureImageView] = []
    internal var selectedSignImageView: SignatureImageView?
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        DispatchQueue.main.async {
            if let window = self.view.window {
                // Hide traffic lights by removing title bar buttons
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        if let window = self.view.window {
            // Show the title bar buttons again
            window.standardWindowButton(.closeButton)?.isHidden = false
            window.standardWindowButton(.miniaturizeButton)?.isHidden = false
            window.standardWindowButton(.zoomButton)?.isHidden = false
        }
    }
    
    //MARK: Setup View
    func setupView() {
        if let image = NSImage(contentsOf: selectedImageURL) {
            imgSelected.image = image
        }
        
        getAllFonts()
        
        btnAddWatermark.isUserInteractionEnabled = false
        btnAddWatermark.isEnabled = false
        
        viewText.isHidden = false
        viewImage.isHidden = true
        
        tfText.focusRingType = .none
        
        sliderOpacity.isContinuous = true
        sliderImgOpacity.isContinuous = true
        
        imgSelectedUpload.isHidden = true
        btnRemoveImg.isHidden = true
        
        btnUploadImage.isHidden = false
        imgUploadPlaceholder.isHidden = false
        lblUploadPlaceholder.isHidden = false
        viewContainer.addTapGesture(target: self, action: #selector(deselectAllSignatures))
    }
    internal func createSignatureView(withText text: String) -> SignatureView {
        let frame = CGRect(x: (viewContainer.bounds.width - 150) / 2,y: (viewContainer.bounds.height - 150) / 2,width: 85,height: 90)
        let signatureView = SignatureView(frame: frame)
        signatureView.label.stringValue = text
        signatureView.label.textColor = selectedTextColor
        signatureView.label.font = NSFont(name: lblSelectedFont.stringValue, size: 20)
        //signatureView.layer?.borderColor = NSColor.primary1.cgColor
        //signatureView.layer?.borderWidth = 1
        signatureView.onBorderVisibilityChanged = { [weak self] isSelected in
            guard let self else { return }
            if isSelected {
                deselectAllSignatures()
                signatureView.label.layer?.borderColor = NSColor.primary1.cgColor
                signatureView.label.layer?.borderWidth = 1
                signatureView.deleteButton.isHidden = false
                signatureView.editButton.isHidden = false
                signatureView.resizeButton.isHidden = false
                selectedSignatureView = signatureView
                signatureView.onSelectionOfTextField = {[weak self] string in
                    guard let self else{return}
                    tfText.stringValue = string
                }
            } else {
                signatureView.label.layer?.borderWidth = 0
                signatureView.label.layer?.borderColor = NSColor.clear.cgColor
                signatureView.deleteButton.isHidden = true
                signatureView.editButton.isHidden = true
                signatureView.resizeButton.isHidden = true
                if selectedSignatureView == signatureView {selectedSignatureView = nil}
            }
        }
        signatureView.onDelete = { [weak self, weak signatureView] in
            guard let self, let viewToRemove = signatureView else { return }
            self.signatureViews.removeAll { $0 == viewToRemove }
            if selectedSignatureView == viewToRemove {selectedSignatureView = nil}
            isTextWatermarkAdded = false
            checkAddWatermarkButtonStatus()
        }
        return signatureView
    }
    @objc func deselectAllSignatures() {
        signatureViews.forEach { $0.isSelected = false }
        signImageView.forEach { $0.isSelected = false }
        selectedSignatureView = nil
        selectedSignImageView = nil
      }
    
    func addSignImage(img:NSImage){
        let frame = CGRect(x: (viewContainer.bounds.width - 150) / 2,y: (viewContainer.bounds.height - 150) / 2,width: 200,height: 200)
        let signatureView = SignatureImageView(frame: frame)
        signatureView.imageView.image = img
        signatureView.bgColor = .clear
        signatureView.imageView.layer?.borderColor = NSColor.primary1.cgColor
        signatureView.imageView.layer?.borderWidth = 1
        deselectAllSignatures()
        signatureView.onBorderVisibilityChanged = { [weak self] isSelected in
          guard let self else { return }
          if isSelected {
            deselectAllSignatures()
              signatureView.imageView.layer?.borderColor = NSColor.primary1.cgColor
            signatureView.imageView.layer?.borderWidth = 1
            signatureView.deleteButton.isHidden = false
            signatureView.resizeButton.isHidden = false
            selectedSignImageView = signatureView
          } else {
            signatureView.imageView.layer?.borderColor = NSColor.clear.cgColor
            signatureView.imageView.layer?.borderWidth = 0
            signatureView.deleteButton.isHidden = true
            signatureView.resizeButton.isHidden = true
            if selectedSignImageView == signatureView {selectedSignImageView = nil}
          }
        }
        signatureView.onDelete = { [weak self, weak signatureView] in
          guard let self = self, let viewToRemove = signatureView else { return }
          signImageView.removeAll { $0 == viewToRemove }
          if selectedSignImageView == viewToRemove {selectedSignImageView = nil}
            isImageWatermarkAdded = false
            checkAddWatermarkButtonStatus()
            
            imgSelectedUpload.isHidden = true
            btnRemoveImg.isHidden = true
            
            btnUploadImage.isHidden = false
            imgUploadPlaceholder.isHidden = false
            lblUploadPlaceholder.isHidden = false
            
        }
        signImageView.append(signatureView)
        viewContainer.addSubview(signatureView)
      }
    
    //MARK: Utility Methods
    
    func createFontMenu() -> NSMenu{
        let menu = NSMenu(title: "Select Font")
        
        // Loop through the string array and create menu items
        for option in arrFonts {
            let menuItem = NSMenuItem(title: option, action: #selector(menuItemSelected(_:)), keyEquivalent: "")
            menuItem.target = self  // Set the target to self to handle the action
            menu.addItem(menuItem)
        }
        
        return menu
    }
    
    func getAllFonts() {
        let fontManager = NSFontManager.shared
        for family in fontManager.availableFontFamilies {
            for fontName in fontManager.availableMembers(ofFontFamily: family)?.compactMap({ $0[0] as? String }) ?? [] {
                arrFonts.append(fontName)
            }
        }
        if arrFonts.count > 0 {
            lblSelectedFont.stringValue = arrFonts[0]
        }
    }
    
    func checkAddWatermarkButtonStatus() {
        if isTextWatermarkAdded || isImageWatermarkAdded {
            btnAddWatermark.isUserInteractionEnabled = true
            btnAddWatermark.isEnabled = true
        }else{
            btnAddWatermark.isUserInteractionEnabled = false
            btnAddWatermark.isEnabled = false
        }
    }
    
    //MARK: Button Action
    @IBAction func btnBackAction(_ sender: Any) {
        delegate?.seleclableCollectionView()
        removeChildFromNavigation()
    }
    @IBAction func btnTextAction(_ sender: Any) {
        isText = true
        viewText.isHidden = false
        viewImage.isHidden = true
        
        btnText.backgroundColor = .primary1
        btnText.contentTintColor = .appWhiteOnly
        
        btnImage.backgroundColor = .appClear
        btnImage.contentTintColor = .black6
    }
    @IBAction func btnImageAction(_ sender: Any) {
        isText = false
        viewText.isHidden = true
        viewImage.isHidden = false
        
        btnText.backgroundColor = .appClear
        btnText.contentTintColor = .black6
        
        btnImage.backgroundColor = .primary1
        btnImage.contentTintColor = .appWhiteOnly
    }
    @IBAction func btnAddWatermarkAction(_ sender: Any) {
        deselectAllSignatures()
        
        guard let imageWatermark = captureNSView(view: viewContainer, exportType: .SaveAsPNG) else {return}
        
        let vc = ImageRotateCompletionVC()
        vc.imgSelected = imageWatermark
        vc.actionDownload = {
            guard let tiffData = imageWatermark.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let pngData = bitmap.representation(using: .png, properties: [:]) else {
                return
            }
            let result = ThumbnailGenerator.generateThumbnailWithName(for: self.selectedImageURL)
            // Show save panel
            let panel = NSSavePanel()
            //panel.allowedFileTypes = ["png"]
            let nameWithoutExtension = (result.fileName as NSString).deletingPathExtension
            panel.nameFieldStringValue = nameWithoutExtension + ".png"
            
            panel.begin { response in
                if response == .OK, var url = panel.url {
                    if url.pathExtension.lowercased() != "png" {
                        url.deletePathExtension()
                        url.appendPathExtension("png")
                    }
                    do {
                        try pngData.write(to: url)
                        print("✅ Saved at \(url.path)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            let vc = DownloadedPopupVC()
                            self.presentAsSheet(vc)
                            
                            let sourceURL = url // This is the source file URL
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                            // Create "Files" subfolder inside Documents
                            let filesFolderURL = documentsDirectory.appendingPathComponent("Files")
                            if !FileManager.default.fileExists(atPath: filesFolderURL.path) {
                                do {
                                    try FileManager.default.createDirectory(at: filesFolderURL, withIntermediateDirectories: true)
                                    print("Files folder created at \(filesFolderURL.path)")
                                } catch {
                                    print("Failed to create 'Files' folder: \(error)")
                                }
                            }

                            // Destination URL inside "Files" folder
                            let destinationURL = filesFolderURL.appendingPathComponent(sourceURL.lastPathComponent)

                            do {
                                // Copy the file to the app's Documents directory
                                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                                print("File copied to \(destinationURL.path)")
                                
                                // Get the file size
                                let fileSize = (try? destinationURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                                
                                // Create a FileInfo object to store the file details
                                let fileExtension = destinationURL.pathExtension
                                let fileInfo = FileInfo(name: destinationURL.lastPathComponent, size: fileSize, path: destinationURL.path, conversionType: .tools, fileExtension: fileExtension, historyID: Utility.generateUnixTimeStamp())
                                
                                // Add the file to history using HistoryManager
                                HistoryManager.shared.addDownloadHistory(fileInfo: fileInfo)
                                
                                let oldURL = documentsDirectory.appendingPathComponent(sourceURL.lastPathComponent)
                                
                                if FileManager.default.fileExists(atPath: oldURL.path) {
                                    // Remove old file
                                    try FileManager.default.removeItem(at: oldURL)
                                    print("Existing file removed: \(destinationURL.path)")
                                }

                            } catch {
                                print("Failed to copy the file: \(error)")
                                // Optionally, show an alert to the user if copying fails
                            }
                            
                        }
                    } catch {
                        print("❌ Save failed: \(error)")
                    }
                }
            }
        }
        presentAsSheet(vc)
        
    }
    @IBAction func btnAddTextAction(_ sender: Any) {
        
        let text = tfText.stringValue
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            return
        }
//        watermark = WatermarkView(frame: NSRect(x: 50, y: 50, width: 200, height: 100), text: text, font: NSFont.systemFont(ofSize: 18), color: NSColor.red)
//        watermark.delegate = self
//        viewContainer.addSubview(watermark)
        
        if signatureViews.count > 0{
            //selectedSignatureView?.label.stringValue = text
            signatureViews[0].removeViewSignature()
            signatureViews.remove(at: 0)
        }
        
        isTextWatermarkAdded = true
        checkAddWatermarkButtonStatus()
//
        let signatureView = createSignatureView(withText: text)
        signatureViews.append(signatureView)
        viewContainer.addSubview(signatureView)
        deselectAllSignatures()
        signatureViews[0].label.alphaValue = sliderOpacity.doubleValue/100
    }
    @IBAction func sliderOpacityAction(_ sender: Any) {
        lblOpacityValue.stringValue = "\(Int(sliderOpacity.doubleValue))%"
        
        if signatureViews.count > 0{
            signatureViews[0].label.alphaValue = sliderOpacity.doubleValue/100
        }
    }
    @IBAction func btnSelectFontAction(_ sender: Any) {
        let DisplayMenu = createFontMenu()
        let buttonBounds = btnSelectFont.bounds
        let menuOrigin = NSPoint(x: 0, y: buttonBounds.height)
        DisplayMenu.popUp(positioning: nil, at: menuOrigin, in: btnSelectFont)
    }
    @objc func menuItemSelected(_ sender: NSMenuItem) {
        print("Selected item: \(sender.title)")
        lblSelectedFont.stringValue = sender.title
        
        if signatureViews.count > 0{
            signatureViews[0].label.font = NSFont(name: sender.title, size: 20)
        }
    }
    @IBAction func btnWhiteAction(_ sender: Any) {
        btnWhite.borderColor = .primary3
        btnBlack.borderColor = .appClear
        btnBlue.borderColor = .appClear
        btnRed.borderColor = .appClear
        btnGreen.borderColor = .appClear
        
        selectedTextColor = .appWhiteOnly
        
        if signatureViews.count > 0{
            signatureViews[0].label.textColor = selectedTextColor
        }
    }
    @IBAction func btnBlackAction(_ sender: Any) {
        btnWhite.borderColor = .appClear
        btnBlack.borderColor = .primary3
        btnBlue.borderColor = .appClear
        btnRed.borderColor = .appClear
        btnGreen.borderColor = .appClear
        
        selectedTextColor = .appBlackOnly
        
        if signatureViews.count > 0{
            signatureViews[0].label.textColor = selectedTextColor
        }
    }
    @IBAction func btnBlueAction(_ sender: Any) {
        btnWhite.borderColor = .appClear
        btnBlack.borderColor = .appClear
        btnBlue.borderColor = .primary3
        btnRed.borderColor = .appClear
        btnGreen.borderColor = .appClear
        
        selectedTextColor = .primary1
        
        if signatureViews.count > 0{
            signatureViews[0].label.textColor = selectedTextColor
        }
    }
    @IBAction func btnRedAction(_ sender: Any) {
        btnWhite.borderColor = .appClear
        btnBlack.borderColor = .appClear
        btnBlue.borderColor = .appClear
        btnRed.borderColor = .primary3
        btnGreen.borderColor = .appClear
        
        selectedTextColor = .appRed
        
        if signatureViews.count > 0{
            signatureViews[0].label.textColor = selectedTextColor
        }
    }
    @IBAction func btnGreenAction(_ sender: Any) {
        btnWhite.borderColor = .appClear
        btnBlack.borderColor = .appClear
        btnBlue.borderColor = .appClear
        btnRed.borderColor = .appClear
        btnGreen.borderColor = .primary3
        
        selectedTextColor = .appGreen
        
        if signatureViews.count > 0{
            signatureViews[0].label.textColor = selectedTextColor
        }
    }
    @IBAction func btnRemoveImgAction(_ sender: Any) {
        imgSelectedUpload.isHidden = true
        btnRemoveImg.isHidden = true
        
        btnUploadImage.isHidden = false
        imgUploadPlaceholder.isHidden = false
        lblUploadPlaceholder.isHidden = false
        
        if signImageView.count > 0{
            signImageView[0].removeViewSignature()
            signImageView.remove(at: 0)
        }
        
        isImageWatermarkAdded = false
        checkAddWatermarkButtonStatus()
    }
    @IBAction func btnUploadImageAction(_ sender: Any) {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose a file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedContentTypes = [.jpeg, .png]
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            if let image = NSImage(contentsOf: result!) {
                imgSelectedUpload.image = image
                
                isImageWatermarkAdded = true
                
                checkAddWatermarkButtonStatus()
                
                imgSelectedUpload.isHidden = false
                btnRemoveImg.isHidden = false
                
                btnUploadImage.isHidden = true
                imgUploadPlaceholder.isHidden = true
                lblUploadPlaceholder.isHidden = true
                
                if signImageView.count > 0{
                    //selectedSignatureView?.label.stringValue = text
                    signImageView[0].removeViewSignature()
                    signImageView.remove(at: 0)
                }
                
                addSignImage(img: image)
                
                deselectAllSignatures()
                signImageView[0].imageView.alphaValue = sliderOpacity.doubleValue/100
                
            }
        } else {
            return
        }
    }
    @IBAction func sliderImgOpacityAction(_ sender: Any) {
        lblImgOpacityValue.stringValue = "\(Int(sliderImgOpacity.doubleValue))%"
        
        if signImageView.count > 0{
            signImageView[0].imageView.alphaValue = CGFloat(sliderImgOpacity.doubleValue)/100
        }
    }
    
    @IBAction func colorPickerAction(_ sender: NSColorWell) {
        selectedTextColor = sender.color
        
        if signatureViews.count > 0{
            signatureViews[0].label.textColor = selectedTextColor
        }
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}
extension WatermarkVC {
    func captureNSView(view: NSView, exportType: ExportType) -> NSImage? {
        let viewBounds = view.bounds
        view.backgroundColor = .white
        guard let imageRep = view.bitmapImageRepForCachingDisplay(in: viewBounds) else { return nil }
        view.cacheDisplay(in: viewBounds, to: imageRep)
        let originalImage = NSImage(size: viewBounds.size)
        originalImage.addRepresentation(imageRep)
        let scale = exportType.scalingFactor
        let scaledSize = NSSize(width: viewBounds.size.width * scale, height: viewBounds.size.height * scale)
        let scaledImage = NSImage(size: scaledSize)
        scaledImage.lockFocus()
        originalImage.draw(in: NSRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        scaledImage.unlockFocus()
        if exportType == .SaveAsJPEG {
            return scaledImage
        } else {
            return scaledImage
        }
    }
}
