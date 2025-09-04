//
//  ImageRotateVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 13/08/2025.
//

import Cocoa

class ImageRotateVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var imgSelected: NSRotatingImageView!
    @IBOutlet weak var sliderStraighten: NSSlider!
    @IBOutlet weak var lblStraightenValue: NSTextField!
    
    var selectedImageURL: URL!
    weak var delegate: DelegateHomeCollectionSelectable?
    
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
        sliderStraighten.isContinuous = true
        imgSelected.image = NSImage(contentsOf: selectedImageURL)
    }
    
    //MARK: Utility Methods
    
    func getRotatedImage(from imageView: NSImageView, angle: CGFloat) -> NSImage? {
        guard let image = imageView.image else { return nil }
        
        let size = image.size
        let rotatedImage = NSImage(size: size)
        
        rotatedImage.lockFocus()
        
        let ctx = NSGraphicsContext.current?.cgContext
        ctx?.translateBy(x: size.width / 2, y: size.height / 2)
        ctx?.rotate(by: angle * .pi / 180)
        
        let rect = CGRect(x: -size.width / 2,
                          y: -size.height / 2,
                          width: size.width,
                          height: size.height)
        
        image.draw(in: rect)
        
        rotatedImage.unlockFocus()
        return rotatedImage
    }
    
    //MARK: Button Action
    @IBAction func btnBackAction(_ sender: Any) {
        delegate?.seleclableCollectionView()
        removeChildFromNavigation()
    }
    @IBAction func btnRotateAction(_ sender: Any) {
        if let img = imgSelected.image {
            imgSelected.image = ImageTransformer.transform(originalImage: img, option: .rotate90)
        }
    }
    @IBAction func btnFlipHAction(_ sender: Any) {
        if let img = imgSelected.image {
            imgSelected.image = ImageTransformer.transform(originalImage: img, option: .flipHorizontal)
        }
    }
    @IBAction func btnFlipVAction(_ sender: Any) {
        if let img = imgSelected.image {
            imgSelected.image = ImageTransformer.transform(originalImage: img, option: .flipVertical)
        }
    }
    @IBAction func sliderStraightenAction(_ sender: NSSlider) {
        imgSelected.rotationAngle = CGFloat(sender.doubleValue)
        lblStraightenValue.stringValue = "\(Int(sender.doubleValue))"
    }
    @IBAction func btnDownloadAction(_ sender: Any) {
        
        let vc = ImageRotateCompletionVC()
        if let rotatedImage = self.getRotatedImage(from: self.imgSelected, angle: self.sliderStraighten.doubleValue) {
            vc.imgSelected = rotatedImage
        }
        vc.actionDownload = {
            if let rotatedImage = self.getRotatedImage(from: self.imgSelected, angle: self.sliderStraighten.doubleValue) {
                guard let tiffData = rotatedImage.tiffRepresentation,
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
                }// rotated now has the image at whatever angle the slider is set to
            }
        }
        presentAsSheet(vc)
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}

