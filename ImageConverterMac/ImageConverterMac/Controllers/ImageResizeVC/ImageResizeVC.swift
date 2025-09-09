//
//  ImageResizeVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 25/08/2025.
//

import Cocoa

class ImageResizeVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var imgResize: NSImageView!
    @IBOutlet weak var viewContainer: NSBox!
    @IBOutlet weak var btnBySize: NSButton!
    @IBOutlet weak var btnByPercentage: NSButton!
    
    @IBOutlet weak var viewBySize: NSBox!
    @IBOutlet weak var tfWidth: NSTextField!
    @IBOutlet weak var tfHeight: NSTextField!
    @IBOutlet weak var checkBoxRatio: NSButton!
    
    @IBOutlet weak var viewByPercentage: NSBox!
    @IBOutlet weak var lblPercentage: NSTextField!
    @IBOutlet weak var sliderResize: NSSlider!
    @IBOutlet weak var lblOriginalSize: NSTextField!
    @IBOutlet weak var lblDecreasSize: NSTextField!
    @IBOutlet weak var lblPreset: NSTextField!
    @IBOutlet weak var lblType: NSTextField!
    @IBOutlet weak var viewType: NSView!
    @IBOutlet weak var btnPreset: NSButton!
    @IBOutlet weak var btnType: NSButton!
    
    var selectedImageURL: URL!
    weak var delegate: DelegateHomeCollectionSelectable?
    var isBySize = true
    var isAspectedRatio = false
    var originalWidth: CGFloat = 0
    var originalHeight: CGFloat = 0
    var decreasedWidth: CGFloat = 0
    var decreasedHeight: CGFloat = 0
    var menuManager: ResizeMenuManager!
    var menuType = NSMenu()
    
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
        tfWidth.formatter = NumberRangeFormatter()
        tfHeight.formatter = NumberRangeFormatter()
        if let image = NSImage(contentsOf: selectedImageURL) {
            // Get the image dimensions (width and height)
            let imageSize = image.size
            print("Image Dimensions: Width: \(imageSize.width), Height: \(imageSize.height)")
            originalWidth = imageSize.width
            originalHeight = imageSize.height
            tfWidth.stringValue = String(format: "%.0f", originalWidth)
            tfHeight.stringValue = String(format: "%.0f", originalHeight)
            imgResize.image = image
        }
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(textDidChangeWidth(_:)),
            name: NSControl.textDidChangeNotification,
            object: tfWidth)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(textDidChangeHeight(_:)),
            name: NSControl.textDidChangeNotification,
            object: tfHeight)
        
        tfWidth.focusRingType = .none
        tfHeight.focusRingType = .none
        
        viewBySize.isHidden = false
        viewByPercentage.isHidden = true
        viewType.isHidden = true
        
        menuManager = ResizeMenuManager()
        menuManager.delegate = self
        
        updateImageSize(percentage: 10)
        sliderResize.isContinuous = true
    }
    
    //MARK: Utility Methods
    
    //MARK: Button Action
    @IBAction func btnBackAction(_ sender: Any) {
        delegate?.seleclableCollectionView()
        removeChildFromNavigation()
    }
    @IBAction func btnBySizeAction(_ sender: Any) {
        isBySize = true
        viewBySize.isHidden = false
        viewByPercentage.isHidden = true
        
        btnBySize.backgroundColor = .primary1
        btnBySize.contentTintColor = .appWhiteOnly
        
        btnByPercentage.backgroundColor = .appClear
        btnByPercentage.contentTintColor = .black6
    }
    @IBAction func btnByPercentageAction(_ sender: Any) {
        isBySize = false
        viewBySize.isHidden = true
        viewByPercentage.isHidden = false
        
        btnBySize.backgroundColor = .appClear
        btnBySize.contentTintColor = .black6
        
        btnByPercentage.backgroundColor = .primary1
        btnByPercentage.contentTintColor = .appWhiteOnly
    }
    @IBAction func checkBoxRatioAction(_ sender: NSButton) {
        if sender.state == .on {
            isAspectedRatio = true
        }else{
            isAspectedRatio = false
        }
    }
    @IBAction func btnResizeImageAction(_ sender: Any) {
        if tfWidth.stringValue.isEmpty || tfHeight.stringValue.isEmpty {
            DispatchQueue.main.async {[weak self] in
                guard let self else {return}
                guard let window = self.view.window else {return}
                Utility.dialogWithMsg(message: "Plz fill all fields", window: window)
                return
            }
        }
        let count = Utility.getDefaultObject(forKey: strFreeHitsCount)
        print("Free count is \(count)")
        if !isPremiumUser() && Int(count)! > freeHitsIntValue{
            let vc = ProPaymentVC()
            self.presentAsSheet(vc)
            return
        }
        var width: CGFloat = 0
        var height: CGFloat = 0
        if isBySize {
            width = CGFloat(Double(tfWidth.stringValue) ?? 0)
            height = CGFloat(Double(tfHeight.stringValue) ?? 0)
        }else{
            width = decreasedWidth
            height = decreasedHeight
        }
        if let resizedImage = resizeImage(imgResize.image!, to: NSSize(width: width/2, height: height/2)){
            let vc = ImageRotateCompletionVC()
            vc.imgSelected = resizedImage
            vc.actionDownload = {
                guard let tiffData = resizedImage.tiffRepresentation,
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
                                    Utility.increaseFreeHitsCount()
                                    
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
    }
    @IBAction func sliderResizeAction(_ sender: Any) {
        let percentage = sliderResize.doubleValue
        updateImageSize(percentage: percentage)
    }
    @IBAction func btnPresetAction(_ sender: NSButton) {
        let buttonBounds = btnPreset.bounds
        let menuOrigin = NSPoint(x: 0, y: buttonBounds.height)
        menuManager.firstMenu.popUp(positioning: nil, at: menuOrigin, in: btnPreset)
    }
    @IBAction func btnTypeAction(_ sender: NSButton) {
        let buttonBounds = btnType.bounds
        let menuOrigin = NSPoint(x: 0, y: buttonBounds.height)
        menuType.popUp(positioning: nil, at: menuOrigin, in: btnType)
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
    @objc func textDidChangeWidth(_ notification: Notification) {
        if let tf = notification.object as? NSTextField {
            if isAspectedRatio {
                // Lock aspect ratio: update height based on the width
                if let width = Double(tfWidth.stringValue), width > 0 {
                    let aspectRatio = originalWidth / originalHeight
                    let newHeight = CGFloat(width) / aspectRatio
                    tfHeight.stringValue = String(format: "%.0f", newHeight)
                }
            }
        }
    }
    
    @objc func textDidChangeHeight(_ notification: Notification) {
        if let tf = notification.object as? NSTextField {
            if isAspectedRatio {
                // Lock aspect ratio: update width based on the height
                if let height = Double(tfHeight.stringValue), height > 0 {
                    let aspectRatio = originalWidth / originalHeight
                    let newWidth = CGFloat(height) * aspectRatio
                    tfWidth.stringValue = String(format: "%.0f", newWidth)
                }
            }
        }
    }
    
}
extension ImageResizeVC:ResizeMenuManagerDelegate {
    func showSecondMenu(_ secondMenu: NSMenu) {
        viewType.isHidden = false
        menuType = secondMenu
        lblType.stringValue = "Choose Type"
        tfWidth.stringValue = ""
        tfHeight.stringValue = ""
    }
    
    func titleForFirstMenuBeforeShowinfgSecondMenu(title:String){
        lblPreset.stringValue = title
    }
    
    func didSelectFinalDimensions(width: CGFloat, height: CGFloat, title: String, fromFirstMenu: Bool) {
        tfWidth.stringValue = "\(Int(width))"
        tfHeight.stringValue = "\(Int(height))"
        
        if fromFirstMenu {
            lblPreset.stringValue = title
            viewType.isHidden = true
            lblType.stringValue = "Choose Type"
            //tfWidth.stringValue = ""
            //tfHeight.stringValue = ""
        }else{
            lblType.stringValue = title
        }
    }
    
    /*func handleFirstMenuSelection(_ item: NSMenuItem) {
        let (secondMenu, showSecond) = menuManager.firstMenuSelectedItem(item)
        
        if showSecond, let secondMenu = secondMenu {
            // show your second menu in other view object
            print("Second menu should show now")
            // You can position it where you want
            viewType.isHidden = false
            menuType = secondMenu
        }else{
            viewType.isHidden = true
        }
    }*/
    
    func resizeImage(_ image: NSImage, to size: NSSize) -> NSImage? {
        // Ensure the image has a valid representation
        guard let bitmapRep = NSBitmapImageRep(data: image.tiffRepresentation ?? Data()) else { return nil }
        // Create a new image with the target size (300x300)
        let targetSize = size
        let newImage = NSImage(size: targetSize)
        // Calculate the aspect ratio to fit the image within 300x300 while preserving transparency
        let aspectRatio = min(targetSize.width / image.size.width, targetSize.height / image.size.height)
        let scaledSize = NSSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        // Calculate the centered position for the image
        let origin = NSPoint(x: (targetSize.width - scaledSize.width) / 2, y: (targetSize.height - scaledSize.height) / 2)
        let drawRect = NSRect(origin: origin, size: scaledSize)
        // Draw the image with transparency
        newImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        // Clear the background to ensure transparency
        NSColor.clear.set()
        NSRect(origin: .zero, size: targetSize).fill()
        image.draw(in: drawRect, from: NSRect(origin: .zero, size: image.size), operation: .copy, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
    func updateImageSize(percentage: Double) {
        // Calculate new dimensions
        decreasedWidth = originalWidth * CGFloat(percentage / 100)
        decreasedHeight = originalHeight * CGFloat(percentage / 100)
        
        // Update the width and height labels
        
        lblOriginalSize.stringValue = String(format: "%.0f", originalWidth) + " x " + String(format: "%.0f", originalHeight)
        lblDecreasSize.stringValue = String(format: "%.0f", decreasedWidth) + " x " + String(format: "%.0f", decreasedHeight)
        
        // Update the percentage label
        lblPercentage.stringValue = "\(Int(percentage))%"
    }
}
