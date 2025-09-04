//
//  ConvertZipVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 20/08/2025.
//

import Cocoa
import ZIPFoundation

class ConvertZipVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var collectionConvert: NSCollectionView!
    
    var arrFiles:[URL] = []
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
        collectionConvert.hideVerticalScroller()
    }
    
    //MARK: Utility Methods
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //MARK: Button Action
    @IBAction func btnBackAction(_ sender: Any) {
        delegate?.seleclableCollectionView()
        removeChildFromNavigation()
    }
    @IBAction func btnAddAction(_ sender: Any) {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = true;
        dialog.canChooseDirectories    = false;
        
        dialog.allowedContentTypes = [.image]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.urls
            if result.count > 0 {
                for file in result {
                    arrFiles.append(file)
                }
                collectionConvert.reloadData()
            }
        } else {
            return
        }
    }
    @IBAction func btnConvertAction(_ sender: Any) {
        if arrFiles.count > 0 {
            let fileManager = FileManager.default
            let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            
            do {
                try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create temp dir: \(error)")
            }
            var imageFileURLs: [URL] = []
            
            for i in 0..<arrFiles.count {
                let result = ThumbnailGenerator.generateThumbnailWithName(for: arrFiles[i])
                let img = NSImage(contentsOf: arrFiles[i])
                let imgType: NSBitmapImageRep.FileType = .jpeg
                if let tiffData = img?.tiffRepresentation,
                   let bitmap = NSBitmapImageRep(data: tiffData),
                   let jpegData = bitmap.representation(using: imgType, properties: [.compressionFactor: 1.0]) {
                    let imageURL = tempDir.appendingPathComponent(result.fileName)
                    do {
                        try jpegData.write(to: imageURL)
                        imageFileURLs.append(imageURL)
                    } catch {
                        print("Failed to write image: \(error)")
                    }
                }
            }
            
            let zipFileURL = getDocumentsDirectory().appendingPathComponent("Archive_\(Int(Date().timeIntervalSince1970)).zip")
            if fileManager.fileExists(atPath: zipFileURL.path) {
                try? fileManager.removeItem(at: zipFileURL)
            }
            
            guard let archive = Archive(url: zipFileURL, accessMode: .create) else {
                print("Failed to create archive")
                return
            }
            
            for imageURL in imageFileURLs {
                do {
                    try archive.addEntry(with: imageURL.lastPathComponent, relativeTo: tempDir)
                } catch {
                    print("Failed to add \(imageURL.lastPathComponent) to zip: \(error)")
                }
            }
            
            if archive.url.path != "" {
                let vc = ImageRotateCompletionVC()
                vc.imgSelected = NSImage(resource: ImageResource.imgZipDownloader)
                vc.actionDownload = {
                    Utility.saveFilesToSelectedLocation(fileURLs: [archive.url]) { success, errors in
                        if success {
                            print("All files saved successfully.")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let vc = DownloadedPopupVC()
                                self.presentAsSheet(vc)
                                
                                let sourceURL = archive.url // This is the source file URL
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
                        } else {
                            if errors.isEmpty {
                                print("User cancelled.")
                            } else {
                                print("Some files failed: \(errors)")
                            }
                        }
                    }
                }
                presentAsSheet(vc)
            }
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
extension ConvertZipVC: NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFiles.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ConvertZipCVC"), for: indexPath) as! ConvertZipCVC
        
        cell.imgConvert.image = NSImage(contentsOf: arrFiles[indexPath.item])
        
        cell.actionRemove = {
            guard let window = self.view.window else{ return}
            Utility.showAlertSheet(message: "Remove File?", information: "Are you sure want to remove this file", firstButtonTitle: "OK", secondButtonTitle: "Cancel" , window: window) { delete in
                if delete{
                    print("OK Tapped")
                    self.arrFiles.remove(at: indexPath.item)
                    self.collectionConvert.reloadData()
                }
            }
        }
        
        return cell
    }
}
