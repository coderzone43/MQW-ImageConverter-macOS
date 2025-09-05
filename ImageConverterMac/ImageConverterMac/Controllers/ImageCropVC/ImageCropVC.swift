//
//  ImageCropVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 22/08/2025.
//

import Cocoa

class ImageCropVC: NSViewController {
    
    //MARK: Outlets
    @IBOutlet weak var viewContainer: NSBox!
    @IBOutlet weak var imgCrop: NSImageView!
    
    @IBOutlet weak var btnOriginal: NSButton!
    @IBOutlet weak var btnCustom: NSButton!
    @IBOutlet weak var btn1_1: NSButton!
    @IBOutlet weak var btn2_1: NSButton!
    @IBOutlet weak var btn3_4: NSButton!
    @IBOutlet weak var btn4_5: NSButton!
    @IBOutlet weak var btn9_16: NSButton!
    @IBOutlet weak var btn16_9: NSButton!
    @IBOutlet weak var btn1_2: NSButton!
    
    //All Button Boxes
    @IBOutlet weak var box1: NSBox!
    @IBOutlet weak var box2: NSBox!
    @IBOutlet weak var box3: NSBox!
    @IBOutlet weak var box4: NSBox!
    @IBOutlet weak var box5: NSBox!
    @IBOutlet weak var box6: NSBox!
    @IBOutlet weak var box7: NSBox!
    @IBOutlet weak var box8: NSBox!
    @IBOutlet weak var box9: NSBox!
    
    var selectedImageURL: URL!
    weak var delegate: DelegateHomeCollectionSelectable?
    //var image: NSImage?
    var imageCropperView: CropView!
    
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
        imageCropperView = CropView(frame: NSRect(x: 0, y: 0, width: 500, height: 500))
        viewContainer.addSubview(imageCropperView)
        
        // Load image (example)
        imgCrop.image = NSImage(contentsOf: selectedImageURL)
        
        if let image = NSImage(contentsOf: selectedImageURL) {
            let boxBounds = viewContainer.bounds
                let imageSize = image.size
                
                let scale = min(boxBounds.width / imageSize.width,
                                boxBounds.height / imageSize.height,
                                1.0) // don’t scale up, only shrink
                
                let newWidth = imageSize.width * scale
                let newHeight = imageSize.height * scale
                
                let x = (boxBounds.width - newWidth) / 2
                let y = (boxBounds.height - newHeight) / 2
                
            imgCrop.frame = NSRect(x: x, y: y, width: newWidth, height: newHeight)
        }
        //imageCropperView.image = image
    }
    
    //MARK: Utility Methods
    
    //MARK: Button Action
    @IBAction func btnBackAction(_ sender: Any) {
        delegate?.seleclableCollectionView()
        removeChildFromNavigation()
    }
    
    @IBAction func btnCropAction(_ sender: Any) {
        let vc = ImageRotateCompletionVC()
        if let croppedImage = imageCropperView.captureCroppedImage(from: imgCrop) {
            print("Image cropped successfully")
            vc.imgSelected = croppedImage
        }
        vc.actionDownload = {
            if let croppedImage = self.imageCropperView.captureCroppedImage(from: self.imgCrop) {
                guard let tiffData = croppedImage.tiffRepresentation,
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
        }
        presentAsSheet(vc)
    }
    
    @IBAction func btnOriginalAction(_ sender: Any) {
        box1.borderColor = .primary1
        box2.borderColor = .white3
        box3.borderColor = .white3
        box4.borderColor = .white3
        box5.borderColor = .white3
        box6.borderColor = .white3
        box7.borderColor = .white3
        box8.borderColor = .white3
        box9.borderColor = .white3
        
        btnOriginal.image = NSImage(resource: ImageResource.imgOriginalSelected)
        btnCustom.image = NSImage(resource: ImageResource.imgCustom)
        btn1_1.image = NSImage(resource: ImageResource.img11)
        btn2_1.image = NSImage(resource: ImageResource.img21)
        btn3_4.image = NSImage(resource: ImageResource.img34)
        btn4_5.image = NSImage(resource: ImageResource.img45)
        btn9_16.image = NSImage(resource: ImageResource.img916)
        btn16_9.image = NSImage(resource: ImageResource.img169)
        btn1_2.image = NSImage(resource: ImageResource.img12)
        
        btnOriginal.contentTintColor = .primary1
        btnCustom.contentTintColor = .black4
        btn1_1.contentTintColor = .black4
        btn2_1.contentTintColor = .black4
        btn3_4.contentTintColor = .black4
        btn4_5.contentTintColor = .black4
        btn9_16.contentTintColor = .black4
        btn16_9.contentTintColor = .black4
        btn1_2.contentTintColor = .black4
        
        imageCropperView.setCropRect(NSRect(x: 0, y: 0, width: 500, height: 500))
        
    }
    @IBAction func btnCustomAction(_ sender: Any) {
        box1.borderColor = .white3
        box2.borderColor = .primary1
        box3.borderColor = .white3
        box4.borderColor = .white3
        box5.borderColor = .white3
        box6.borderColor = .white3
        box7.borderColor = .white3
        box8.borderColor = .white3
        box9.borderColor = .white3
        
        btnOriginal.image = NSImage(resource: ImageResource.imgOriginal)
        btnCustom.image = NSImage(resource: ImageResource.imgCustomSelected)
        btn1_1.image = NSImage(resource: ImageResource.img11)
        btn2_1.image = NSImage(resource: ImageResource.img21)
        btn3_4.image = NSImage(resource: ImageResource.img34)
        btn4_5.image = NSImage(resource: ImageResource.img45)
        btn9_16.image = NSImage(resource: ImageResource.img916)
        btn16_9.image = NSImage(resource: ImageResource.img169)
        btn1_2.image = NSImage(resource: ImageResource.img12)
        
        btnOriginal.contentTintColor = .black4
        btnCustom.contentTintColor = .primary1
        btn1_1.contentTintColor = .black4
        btn2_1.contentTintColor = .black4
        btn3_4.contentTintColor = .black4
        btn4_5.contentTintColor = .black4
        btn9_16.contentTintColor = .black4
        btn16_9.contentTintColor = .black4
        btn1_2.contentTintColor = .black4
        
        imageCropperView.setCropRect(NSRect(x: 100, y: 100, width: 300, height: 300))
    }
    @IBAction func btn1_1Action(_ sender: Any) {
        box1.borderColor = .white3
        box2.borderColor = .white3
        box3.borderColor = .primary1
        box4.borderColor = .white3
        box5.borderColor = .white3
        box6.borderColor = .white3
        box7.borderColor = .white3
        box8.borderColor = .white3
        box9.borderColor = .white3
        
        btnOriginal.image = NSImage(resource: ImageResource.imgOriginal)
        btnCustom.image = NSImage(resource: ImageResource.imgCustom)
        btn1_1.image = NSImage(resource: ImageResource.img11Selected)
        btn2_1.image = NSImage(resource: ImageResource.img21)
        btn3_4.image = NSImage(resource: ImageResource.img34)
        btn4_5.image = NSImage(resource: ImageResource.img45)
        btn9_16.image = NSImage(resource: ImageResource.img916)
        btn16_9.image = NSImage(resource: ImageResource.img169)
        btn1_2.image = NSImage(resource: ImageResource.img12)
        
        btnOriginal.contentTintColor = .black4
        btnCustom.contentTintColor = .black4
        btn1_1.contentTintColor = .primary1
        btn2_1.contentTintColor = .black4
        btn3_4.contentTintColor = .black4
        btn4_5.contentTintColor = .black4
        btn9_16.contentTintColor = .black4
        btn16_9.contentTintColor = .black4
        btn1_2.contentTintColor = .black4
        
        imageCropperView.setCropRect(NSRect(x: 100, y: 100, width: 150, height: 150))
    }
    @IBAction func btn2_1Action(_ sender: Any) {
        box1.borderColor = .white3
        box2.borderColor = .white3
        box3.borderColor = .white3
        box4.borderColor = .primary1
        box5.borderColor = .white3
        box6.borderColor = .white3
        box7.borderColor = .white3
        box8.borderColor = .white3
        box9.borderColor = .white3
        
        btnOriginal.image = NSImage(resource: ImageResource.imgOriginal)
        btnCustom.image = NSImage(resource: ImageResource.imgCustom)
        btn1_1.image = NSImage(resource: ImageResource.img11)
        btn2_1.image = NSImage(resource: ImageResource.img21Selected)
        btn3_4.image = NSImage(resource: ImageResource.img34)
        btn4_5.image = NSImage(resource: ImageResource.img45)
        btn9_16.image = NSImage(resource: ImageResource.img916)
        btn16_9.image = NSImage(resource: ImageResource.img169)
        btn1_2.image = NSImage(resource: ImageResource.img12)
        
        btnOriginal.contentTintColor = .black4
        btnCustom.contentTintColor = .black4
        btn1_1.contentTintColor = .black4
        btn2_1.contentTintColor = .primary1
        btn3_4.contentTintColor = .black4
        btn4_5.contentTintColor = .black4
        btn9_16.contentTintColor = .black4
        btn16_9.contentTintColor = .black4
        btn1_2.contentTintColor = .black4
        
        imageCropperView.setCropRect(NSRect(x: 100, y: 100, width: 150, height: 300))
    }
    @IBAction func btn3_4Action(_ sender: Any) {
        box1.borderColor = .white3
        box2.borderColor = .white3
        box3.borderColor = .white3
        box4.borderColor = .white3
        box5.borderColor = .primary1
        box6.borderColor = .white3
        box7.borderColor = .white3
        box8.borderColor = .white3
        box9.borderColor = .white3
        
        btnOriginal.image = NSImage(resource: ImageResource.imgOriginal)
        btnCustom.image = NSImage(resource: ImageResource.imgCustom)
        btn1_1.image = NSImage(resource: ImageResource.img11)
        btn2_1.image = NSImage(resource: ImageResource.img21)
        btn3_4.image = NSImage(resource: ImageResource.img34Selected)
        btn4_5.image = NSImage(resource: ImageResource.img45)
        btn9_16.image = NSImage(resource: ImageResource.img916)
        btn16_9.image = NSImage(resource: ImageResource.img169)
        btn1_2.image = NSImage(resource: ImageResource.img12)
        
        btnOriginal.contentTintColor = .black4
        btnCustom.contentTintColor = .black4
        btn1_1.contentTintColor = .black4
        btn2_1.contentTintColor = .black4
        btn3_4.contentTintColor = .primary1
        btn4_5.contentTintColor = .black4
        btn9_16.contentTintColor = .black4
        btn16_9.contentTintColor = .black4
        btn1_2.contentTintColor = .black4
        
        imageCropperView.setCropRect(NSRect(x: 100, y: 100, width: 225, height: 300))
    }
    @IBAction func btn4_5Action(_ sender: Any) {
        box1.borderColor = .white3
        box2.borderColor = .white3
        box3.borderColor = .white3
        box4.borderColor = .white3
        box5.borderColor = .white3
        box6.borderColor = .primary1
        box7.borderColor = .white3
        box8.borderColor = .white3
        box9.borderColor = .white3
        
        btnOriginal.image = NSImage(resource: ImageResource.imgOriginal)
        btnCustom.image = NSImage(resource: ImageResource.imgCustom)
        btn1_1.image = NSImage(resource: ImageResource.img11)
        btn2_1.image = NSImage(resource: ImageResource.img21)
        btn3_4.image = NSImage(resource: ImageResource.img34)
        btn4_5.image = NSImage(resource: ImageResource.img45Selected)
        btn9_16.image = NSImage(resource: ImageResource.img916)
        btn16_9.image = NSImage(resource: ImageResource.img169)
        btn1_2.image = NSImage(resource: ImageResource.img12)
        
        btnOriginal.contentTintColor = .black4
        btnCustom.contentTintColor = .black4
        btn1_1.contentTintColor = .black4
        btn2_1.contentTintColor = .black4
        btn3_4.contentTintColor = .black4
        btn4_5.contentTintColor = .primary1
        btn9_16.contentTintColor = .black4
        btn16_9.contentTintColor = .black4
        btn1_2.contentTintColor = .black4
        
        imageCropperView.setCropRect(NSRect(x: 100, y: 100, width: 240, height: 300))
    }
    @IBAction func btn9_16Action(_ sender: Any) {
        box1.borderColor = .white3
        box2.borderColor = .white3
        box3.borderColor = .white3
        box4.borderColor = .white3
        box5.borderColor = .white3
        box6.borderColor = .white3
        box7.borderColor = .primary1
        box8.borderColor = .white3
        box9.borderColor = .white3
        
        btnOriginal.image = NSImage(resource: ImageResource.imgOriginal)
        btnCustom.image = NSImage(resource: ImageResource.imgCustom)
        btn1_1.image = NSImage(resource: ImageResource.img11)
        btn2_1.image = NSImage(resource: ImageResource.img21)
        btn3_4.image = NSImage(resource: ImageResource.img34)
        btn4_5.image = NSImage(resource: ImageResource.img45)
        btn9_16.image = NSImage(resource: ImageResource.img916Selected)
        btn16_9.image = NSImage(resource: ImageResource.img169)
        btn1_2.image = NSImage(resource: ImageResource.img12)
        
        btnOriginal.contentTintColor = .black4
        btnCustom.contentTintColor = .black4
        btn1_1.contentTintColor = .black4
        btn2_1.contentTintColor = .black4
        btn3_4.contentTintColor = .black4
        btn4_5.contentTintColor = .black4
        btn9_16.contentTintColor = .primary1
        btn16_9.contentTintColor = .black4
        btn1_2.contentTintColor = .black4
        
        imageCropperView.setCropRect(NSRect(x: 50, y: 50, width: 225, height: 400))
    }
    @IBAction func btn16_9Action(_ sender: Any) {
        box1.borderColor = .white3
        box2.borderColor = .white3
        box3.borderColor = .white3
        box4.borderColor = .white3
        box5.borderColor = .white3
        box6.borderColor = .white3
        box7.borderColor = .white3
        box8.borderColor = .primary1
        box9.borderColor = .white3
        
        btnOriginal.image = NSImage(resource: ImageResource.imgOriginal)
        btnCustom.image = NSImage(resource: ImageResource.imgCustom)
        btn1_1.image = NSImage(resource: ImageResource.img11)
        btn2_1.image = NSImage(resource: ImageResource.img21)
        btn3_4.image = NSImage(resource: ImageResource.img34)
        btn4_5.image = NSImage(resource: ImageResource.img45)
        btn9_16.image = NSImage(resource: ImageResource.img916)
        btn16_9.image = NSImage(resource: ImageResource.img169Selected)
        btn1_2.image = NSImage(resource: ImageResource.img12)
        
        btnOriginal.contentTintColor = .black4
        btnCustom.contentTintColor = .black4
        btn1_1.contentTintColor = .black4
        btn2_1.contentTintColor = .black4
        btn3_4.contentTintColor = .black4
        btn4_5.contentTintColor = .black4
        btn9_16.contentTintColor = .black4
        btn16_9.contentTintColor = .primary1
        btn1_2.contentTintColor = .black4
        
        imageCropperView.setCropRect(NSRect(x: 50, y: 50, width: 400, height: 225))
    }
    @IBAction func btn1_2Action(_ sender: Any) {
        box1.borderColor = .white3
        box2.borderColor = .white3
        box3.borderColor = .white3
        box4.borderColor = .white3
        box5.borderColor = .white3
        box6.borderColor = .white3
        box7.borderColor = .white3
        box8.borderColor = .white3
        box9.borderColor = .primary1
        
        btnOriginal.image = NSImage(resource: ImageResource.imgOriginal)
        btnCustom.image = NSImage(resource: ImageResource.imgCustom)
        btn1_1.image = NSImage(resource: ImageResource.img11)
        btn2_1.image = NSImage(resource: ImageResource.img21)
        btn3_4.image = NSImage(resource: ImageResource.img34)
        btn4_5.image = NSImage(resource: ImageResource.img45)
        btn9_16.image = NSImage(resource: ImageResource.img916)
        btn16_9.image = NSImage(resource: ImageResource.img169)
        btn1_2.image = NSImage(resource: ImageResource.img12Selected)
        
        btnOriginal.contentTintColor = .black4
        btnCustom.contentTintColor = .black4
        btn1_1.contentTintColor = .black4
        btn2_1.contentTintColor = .black4
        btn3_4.contentTintColor = .black4
        btn4_5.contentTintColor = .black4
        btn9_16.contentTintColor = .black4
        btn16_9.contentTintColor = .black4
        btn1_2.contentTintColor = .primary1
        
        imageCropperView.setCropRect(NSRect(x: 100, y: 100, width: 300, height: 150))
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}
