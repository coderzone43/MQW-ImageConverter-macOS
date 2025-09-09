//
//  CompressResultVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 21/08/2025.
//

import Cocoa
import ZIPFoundation

class CompressResultVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var collectionFiles: NSCollectionView!
    @IBOutlet weak var btnDownloadAll: NSButton!
    
    var arrImgs:[CompressibleImage] = []
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        collectionFiles.collectionViewLayout?.invalidateLayout()
    }
    
    //MARK: Setup View
    func setupView() {
        collectionFiles.hideVerticalScroller()
        
        if arrImgs.count == 1{
            btnDownloadAll.isHidden = true
        }
    }
    
    //MARK: Utility Methods
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //MARK: Button Action
    @IBAction func btnBackAction(_ sender: Any) {
        removeChildFromNavigation()
    }
    @IBAction func btnDownloadAllAction(_ sender: Any) {
        if arrImgs.count > 0 {
            let fileManager = FileManager.default
            let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            
            do {
                try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create temp dir: \(error)")
            }
            var imageFileURLs: [URL] = []
            
            for i in 0..<arrImgs.count {
                let result = ThumbnailGenerator.generateThumbnailWithName(for: arrImgs[i].url)
                let img = arrImgs[i].image
                let imgType: NSBitmapImageRep.FileType = .jpeg
                let imageURL = tempDir.appendingPathComponent(result.fileName)
                do {
                    try arrImgs[i].compressedData?.write(to: imageURL)
                    imageFileURLs.append(imageURL)
                } catch {
                    print("Failed to write image: \(error)")
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
extension CompressResultVC: NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImgs.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ImgListCVC"), for: indexPath) as! ImgListCVC
        
        let result = ThumbnailGenerator.generateThumbnailWithName(for: arrImgs[indexPath.item].url)
        cell.imgFile.image = result.image
        cell.lblTitle.stringValue = result.fileName
        
        cell.btnClose.isHidden = true
        cell.btnDownload.isHidden = false
        
        cell.actionDownload = {
            let fileManager = FileManager.default
            let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            
            do {
                try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create temp dir: \(error)")
            }

            let img = self.arrImgs[indexPath.item].image
            let imgType: NSBitmapImageRep.FileType = .jpeg
            let imageURL = tempDir.appendingPathComponent(result.fileName)
            do {
                try self.arrImgs[indexPath.item].compressedData?.write(to: imageURL)
                
                Utility.saveFilesToSelectedLocation(fileURLs: [imageURL]) { success, errors in
                    if success {
                        print("All files saved successfully.")
                        let vc = DownloadedPopupVC()
                        self.presentAsSheet(vc)
                        
                        let sourceURL = imageURL // This is the source file URL
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
                        
                    } else {
                        if errors.isEmpty {
                            print("User cancelled.")
                        } else {
                            print("Some files failed: \(errors)")
                        }
                    }
                }
                
            } catch {
                print("Failed to write image: \(error)")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        NSSize(width: collectionView.frame.width - 1, height: 65)
    }
}
