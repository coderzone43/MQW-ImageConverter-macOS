//
//  ExtractResultVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 20/08/2025.
//

import Cocoa
import ZIPFoundation

class ExtractResultVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var collectionText: NSCollectionView!
    @IBOutlet weak var btnDownloadAll: NSButton!
    
    var arrFiles:[URL] = []
    var arrText:[String] = []
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        collectionText.collectionViewLayout?.invalidateLayout()
    }
    
    //MARK: Setup View
    func setupView() {
        collectionText.hideVerticalScroller()
        
        if arrFiles.count == 1{
            btnDownloadAll.isHidden = true
        }else{
            var isTextFound = false
            for text in arrText{
                if !text.isEmpty{
                    isTextFound = true
                    break
                }
            }
            if isTextFound{
                btnDownloadAll.isHidden = false
            }else{
                btnDownloadAll.isHidden = true
            }
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
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        do {
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create temp dir: \(error)")
        }
        var txtFileURLs: [URL] = []
        
        for i in 0..<arrText.count {
            if !arrText[i].isEmpty{
                let result = ThumbnailGenerator.generateThumbnailWithName(for: arrFiles[i])
                let imageURL = tempDir.appendingPathComponent(result.fileName)
                
                let text = arrText[i]
                let fileName = imageURL.deletingPathExtension().lastPathComponent + ".txt"
                let tempURL = tempDir.appendingPathComponent(fileName)
                
                do {
                    try text.write(to: tempURL, atomically: true, encoding: .utf8)
                    txtFileURLs.append(tempURL)
                } catch {
                    print("Failed to save text file: \(error)")
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
        
        for imageURL in txtFileURLs {
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
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}
extension ExtractResultVC: NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFiles.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ExtractResultCVC"), for: indexPath) as! ExtractResultCVC
        
        let result = ThumbnailGenerator.generateThumbnailWithName(for: arrFiles[indexPath.item])
        cell.imgText.image = result.image
        cell.lblImgName.stringValue = result.fileName
        if arrText[indexPath.item].isEmpty{
            cell.lblText.stringValue = "No Text Found"
            cell.btnCopy.isHidden = true
            cell.btnDownload.isHidden = true
        }else{
            cell.lblText.stringValue = arrText[indexPath.item]
            cell.btnCopy.isHidden = false
            cell.btnDownload.isHidden = false
        }
        
        cell.actionCopy = {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(self.arrText[indexPath.item], forType: .string)
            let vc = DownloadedPopupVC()
            vc.strMsg = "Text Copied!"
            self.presentAsSheet(vc)
        }
        
        cell.actionDownload = {
            if let fileURL = Utility.saveTextFile(self.arrText[indexPath.item], for: self.arrFiles[indexPath.item]){
                Utility.saveFilesToSelectedLocation(fileURLs: [fileURL]) { success, errors in
                    if success {
                        print("All files saved successfully.")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            let vc = DownloadedPopupVC()
                            self.presentAsSheet(vc)
                            
                            let sourceURL = fileURL // This is the source file URL
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
        }
        
        return cell
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let index = indexPaths.first else{ return}
    }
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        NSSize(width: collectionView.frame.width - 1, height: 65)
    }
}
