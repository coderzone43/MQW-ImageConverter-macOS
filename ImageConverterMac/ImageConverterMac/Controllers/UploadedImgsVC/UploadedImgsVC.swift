//
//  UploadedImgsVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 07/08/2025.
//

import Cocoa
import ZIPFoundation
import UniformTypeIdentifiers

class UploadedImgsVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var collectionFiles: NSCollectionView!
    @IBOutlet weak var btnConvert: NSButton!
    @IBOutlet weak var btnAdd: NSButton!
    
    var strTitle = ""
    var convertedFileType:FileTypes = .PNG
    var outputFileType:ItemType = .PNG
    
    var browsedFileType:ItemType!
    
    var selectedConversionType:ConversionCategory = .imageToImage
    
    var arrFiles:[URL] = []
    weak var delegate: DelegateHomeCollectionSelectable?
    var isConverting = true
    
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
        lblTitle.stringValue = strTitle
        
        collectionFiles.hideVerticalScroller()
        setFileTypes()
        
        print("Files count is \(arrFiles.count)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.collectionFiles.reloadData()
        }
    }
    
    //MARK: Utility Methods
    
    func setFileTypes(){
        if convertedFileType == .PDF {
            selectedConversionType = .imageToPDF
        }
        
        if browsedFileType == .PDF {
            selectedConversionType = .pdfToImage
        }
        
        switch convertedFileType {
        case .PNG:
            outputFileType = .PNG
        case .JPG:
            outputFileType = .JPG
        case .PDF:
            outputFileType = .PDF
        case .TIFF:
            outputFileType = .TIFF
        case .HEIC:
            outputFileType = .HEIC
        case .HEIF:
            outputFileType = .HEIF
        case .Webp:
            outputFileType = .Webp
        case .GIF:
            outputFileType = .GIF
        default:
            break
        }
    }
    
    func showConversionLoader() -> ConversionProgressVC? {
        let loaderVC = ConversionProgressVC(nibName: "ConversionProgressVC", bundle: nil)
        
        guard let window = NSApplication.shared.windows.first,
              let contentVC = window.contentViewController
        else { return nil }

        loaderVC.view.frame = contentVC.view.bounds
        loaderVC.view.autoresizingMask = [.width, .height]
        contentVC.addChild(loaderVC)
        contentVC.view.addSubview(loaderVC.view)

        return loaderVC
    }

    func hideConversionLoader(loaderVC: ConversionProgressVC) {
        //loaderVC.view.removeFromSuperview()
        //loaderVC.removeFromParent()
        loaderVC.dismiss(nil)
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
        switch browsedFileType {
        case .PNG:
            dialog.allowedContentTypes = [.png]
        case .JPG:
            dialog.allowedContentTypes = [.jpeg]
        case .PDF:
            dialog.allowedContentTypes = [.pdf]
        case .TIFF:
            dialog.allowedContentTypes = [.tiff]
        case .HEIC:
            dialog.allowedContentTypes = [.heic]
        case .HEIF:
            dialog.allowedContentTypes = [.heif]
        case .Webp:
            dialog.allowedContentTypes = [.webP]
        case .GIF:
            dialog.allowedContentTypes = [.gif]
        case .image:
            dialog.allowedContentTypes = [.image]
            
        default:
            break
        }
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.urls
            if result.count > 0 {
                for file in result {
                    arrFiles.append(file)
                }
                collectionFiles.reloadData()
            }
        } else {
            return
        }
    }
    @IBAction func btnConvertAction(_ sender: Any) {
        if isConverting{
            if arrFiles.count > 0{
                let count = Utility.getDefaultObject(forKey: strFreeHitsCount)
                print("Free count is \(count)")
                if !isPremiumUser() && Int(count)! > freeHitsIntValue{
                    let vc = ProPaymentVC()
                    self.presentAsSheet(vc)
                    return
                }
                let cancelToken = CancellationToken()
                
                let loaderVC = ConversionProgressVC() //showConversionLoader()
                loaderVC.strTitle = "Conversion in progress..."
                self.presentAsSheet(loaderVC)
                
                loaderVC.cancellationToken = cancelToken

                FileConversionManager.convert(
                    files: arrFiles,
                    conversionType: selectedConversionType,
                    inputType: browsedFileType,
                    outputType: outputFileType,
                    cancellationToken: cancelToken,
                    progress: { percent in
                        loaderVC.updateProgress(percent)
                    },
                    completion: { [weak self] results in
                        self?.hideConversionLoader(loaderVC: loaderVC)
                        print("Done:", results)
                        self?.btnAdd.isHidden = true
                        self?.isConverting = false
                        self?.btnConvert.title = "Download All"
                        self?.arrFiles.removeAll()
                        self?.arrFiles = results
                        
                        if self?.arrFiles.count == 1{
                            self?.btnConvert.isHidden = true
                        }
                        
                        self?.collectionFiles.reloadData()
                        
                    }
                )
            }
        }else{
            self.zipSelectedFile()
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
extension UploadedImgsVC: NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFiles.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ImgListCVC"), for: indexPath) as! ImgListCVC
        
        let result = ThumbnailGenerator.generateThumbnailWithName(for: arrFiles[indexPath.item])
        if arrFiles[indexPath.item].pathExtension.lowercased() == "zip"{
            cell.imgFile.image = NSImage(resource: ImageResource.imgZipFile)
        }else{
            cell.imgFile.image = result.image
        }
        cell.lblTitle.stringValue = result.fileName
        
        if isConverting{
            cell.btnClose.isHidden = false
            cell.btnDownload.isHidden = true
        }else{
            cell.btnClose.isHidden = true
            cell.btnDownload.isHidden = false
        }
        
        cell.actionDelete = {
            guard let window = self.view.window else{ return}
            Utility.showAlertSheet(message: "Remove File?", information: "Are you sure want to remove this file", firstButtonTitle: "OK", secondButtonTitle: "Cancel" , window: window) { delete in
                if delete{
                    print("OK Tapped")
                    self.arrFiles.remove(at: indexPath.item)
                    self.collectionFiles.reloadData()
                }
            }
        }
        
        cell.actionDownload = {
            Utility.saveFilesToSelectedLocation(fileURLs: [self.arrFiles[indexPath.item]]) { success, errors in
                if success {
                    print("All files saved successfully.")
                    let vc = DownloadedPopupVC()
                    self.presentAsSheet(vc)
                    
                    let sourceURL = self.arrFiles[indexPath.item] // This is the source file URL
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let destinationURL = documentsDirectory.appendingPathComponent(sourceURL.lastPathComponent)

                    do {
                        // Copy the file to the app's Documents directory
                        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                        print("✅ File copied to \(destinationURL.path)")
                        
                        // Get the file size
                        let fileSize = (try? destinationURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                        
                        // Determine the file type
                        var type: FileTypes = .PNG
                        switch self.outputFileType {
                        case .PNG:
                            type = .PNG
                        case .JPG:
                            type = .JPG
                        case .Webp:
                            type = .Webp
                        case .PDF:
                            type = .PDF
                        default:
                            type = .tools
                        }
                        
                        // Create a FileInfo object to store the file details
                        let fileExtension = destinationURL.pathExtension
                        let fileInfo = FileInfo(name: destinationURL.lastPathComponent, size: fileSize, path: destinationURL.path, conversionType: type, fileExtension: fileExtension, historyID: Utility.generateUnixTimeStamp())
                        
                        // Add the file to history using HistoryManager
                        HistoryManager.shared.addDownloadHistory(fileInfo: fileInfo)
                        Utility.increaseFreeHitsCount()

                    } catch {
                        print("❌ Failed to copy the file: \(error)")
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
extension UploadedImgsVC{
    private func zipSelectedFile() {
        //guard arrFiles.isEmpty else { return }
        //isProcessing = true
        //statusMessage = "Creating zip file..."
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let zippedURL = try self.createZipFile(from: self.arrFiles)
                DispatchQueue.main.async {
                    
                    Utility.saveFilesToSelectedLocation(fileURLs: [zippedURL]) { success, errors in
                        if success {
                            print("All files saved successfully.")
                            let vc = DownloadedPopupVC()
                            self.presentAsSheet(vc)
                            
                            let sourceURL = zippedURL // This is the source file URL
                            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let destinationURL = documentsDirectory.appendingPathComponent(sourceURL.lastPathComponent)
                            
                            do {
                                // Copy the file to the app's Documents directory
                                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                                print("✅ File copied to \(destinationURL.path)")
                                
                                // Get the file size
                                let fileSize = (try? destinationURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                                
                                // Determine the file type
                                var type: FileTypes = .PNG
                                switch self.outputFileType {
                                case .PNG:
                                    type = .PNG
                                case .JPG:
                                    type = .JPG
                                case .Webp:
                                    type = .Webp
                                case .PDF:
                                    type = .PDF
                                default:
                                    type = .tools
                                }
                                
                                // Create a FileInfo object to store the file details
                                let fileExtension = destinationURL.pathExtension
                                let fileInfo = FileInfo(name: destinationURL.lastPathComponent, size: fileSize, path: destinationURL.path, conversionType: type, fileExtension: fileExtension, historyID: Utility.generateUnixTimeStamp())
                                
                                // Add the file to history using HistoryManager
                                HistoryManager.shared.addDownloadHistory(fileInfo: fileInfo)
                                Utility.increaseFreeHitsCount()
                            } catch {
                                print("❌ Failed to copy the file: \(error)")
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
                }
            } catch {
                print("error zipping file: \(error)")
            }
        }
    }
    private func createZipFile(from sourceURLs: [URL]) throws -> URL {
        // Get access to all files
        /*for url in sourceURLs {
            guard url.startAccessingSecurityScopedResource() else {
                throw ZipError.securityScopeError
            }
        }
        defer {
            for url in sourceURLs {
                url.stopAccessingSecurityScopedResource()
            }
        }*/
        // Create temporary directory for zip file
        let tempDir = FileManager.default.temporaryDirectory
        let zipFileName = "Archive_\(Int(Date().timeIntervalSince1970)).zip"
        let zipURL = tempDir.appendingPathComponent(zipFileName)
        // Remove existing zip file if it exists
        try? FileManager.default.removeItem(at: zipURL)
        // Use command line zip utility (most reliable approach)
        let process = Process()
        process.launchPath = "/usr/bin/zip"
        // Build arguments - add all file paths
        var arguments = ["-j", zipURL.path] // -j doesn't store directory structure
        arguments.append(contentsOf: sourceURLs.map { $0.path })
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        process.launch()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("error creating zip \(errorOutput.localizedLowercase)")
        }
        // Verify the zip file was created
        guard FileManager.default.fileExists(atPath: zipURL.path) else {
            print("error in zipURL.path")
            throw ZipError.fileNotFound
        }
        return zipURL
    }
    private func saveZipFile(_ zipURL: URL) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.zip]
        savePanel.nameFieldStringValue = zipURL.lastPathComponent
        savePanel.begin { response in
            if response == .OK, let destinationURL = savePanel.url {
                do {
                    // Copy the zip file to the selected location
                    try FileManager.default.copyItem(at: zipURL, to: destinationURL)
                    print("Zip file saved to: \(destinationURL.path)")
                } catch {
                    print("Error saving file: \(error.localizedDescription)")
                }
            }
        }
    }
}
enum ZipError: LocalizedError {
  case securityScopeError
  case compressionFailed(String)
  case fileNotFound
  var errorDescription: String? {
    switch self {
    case .securityScopeError:
      return "Unable to access the selected file"
    case .compressionFailed(let details):
      return "Compression failed: \(details)"
    case .fileNotFound:
      return "Zip file was not created"
    }
  }
}
