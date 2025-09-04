//
//  UploadFileVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 07/08/2025.
//

import Cocoa
import PDFKit

class UploadFileVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var viewUpload: NSBox!
    @IBOutlet weak var viewDragDrop: DragDropView!
    
    var convertedFileType:FileTypes = .PNG
    var browsedFileType:ItemType = .PNG
    var isTool = false
    var fileURL: (([URL]) -> Void)?
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    //MARK: Setup View
    func setupView() {
        //print("browsed type is \(browsedFileType.rawValue)")
        //print("converted type is \(convertedFileType.rawValue)")
        setupDragDropView()
    }
    
    //MARK: Utility Methods
    func setupDragDropView() {
        if isTool{
            viewDragDrop.acceptedFileExtensions = ["image"]
            if browsedFileType == .extractText || browsedFileType == .watermark{
                viewDragDrop.acceptedFileExtensions = ["jpeg", "png", "svg", "jpg"]
            }
            if browsedFileType == .compress || browsedFileType == .resize{
                viewDragDrop.acceptedFileExtensions = ["jpeg", "png", "svg", "jpg", "gif"]
            }
            if browsedFileType == .crop{
                viewDragDrop.acceptedFileExtensions = ["jpeg", "png", "gif", "jpg"]
            }
        }else{
            switch browsedFileType {
            case .PNG:
                viewDragDrop.acceptedFileExtensions = ["png"]
            case .JPG:
                viewDragDrop.acceptedFileExtensions = ["jpeg"]
            case .PDF:
                viewDragDrop.acceptedFileExtensions = ["pdf"]
            case .TIFF:
                viewDragDrop.acceptedFileExtensions = ["tiff"]
            case .HEIC:
                viewDragDrop.acceptedFileExtensions = ["heic"]
            case .HEIF:
                viewDragDrop.acceptedFileExtensions = ["heif"]
            case .Webp:
                viewDragDrop.acceptedFileExtensions = ["webP"]
            case .GIF:
                viewDragDrop.acceptedFileExtensions = ["gif"]
            case .image:
                viewDragDrop.acceptedFileExtensions = ["image"]
                
            default:
                break
            }
        }
        
        viewDragDrop.onFileDropped = { url in
            print("Dropped file: \(url)")
            
            do {
                let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                if let fileSize = attrs[.size] as? NSNumber {
                    if fileSize.int64Value > 100 * 1024 * 1024 {
                        /*let alert = NSAlert()
                        alert.messageText = "File Too Large"
                        alert.informativeText = "The file \"\(url.lastPathComponent)\" is larger than 100 MB and cannot be used."
                        alert.addButton(withTitle: "OK")
                        alert.runModal()*/
                        Utility.dialogWithMsg(message: "The file \"\(url.lastPathComponent)\" is larger than 100 MB and cannot be used.", window: self.view.window ?? NSWindow())
                        return // stop here
                    }
                }
            }catch {
                print("⚠️ Could not read file info: \(error)")
            }
            
            if url.pathExtension.lowercased() == "pdf" {
                if let pdfDoc = PDFDocument(url: url), pdfDoc.isEncrypted {
                    /*let alert = NSAlert()
                     alert.messageText = "Locked File Detected"
                     alert.informativeText = "The file \"\(url.lastPathComponent)\" is locked and cannot be used. Please unlock it first."
                     alert.addButton(withTitle: "OK")
                     alert.runModal()*/
                    Utility.dialogWithMsg(message: "The file \"\(url.lastPathComponent)\" is locked and cannot be used. Please unlock it first.", window: self.view.window ?? NSWindow())
                    return // stop here
                }
            }
            
            
            self.fileURL?([url])
            self.dismiss(nil)
        }
    }
    
    //MARK: Button Action
    @IBAction func btnCloseAction(_ sender: Any) {
        dismiss(nil)
    }
    @IBAction func btnBrowseAction(_ sender: Any) {
        let dialog = NSOpenPanel()
        dialog.title                   = "Choose a file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        if isTool{
            dialog.allowedContentTypes = [.image]
            if browsedFileType == .rotate || browsedFileType == .crop || browsedFileType == .resize || browsedFileType == .watermark{
                dialog.allowsMultipleSelection = false
            }else{
                dialog.allowsMultipleSelection = true
            }
            if browsedFileType == .extractText || browsedFileType == .watermark{
                dialog.allowedContentTypes = [.jpeg, .png, .svg]
            }
            if browsedFileType == .compress || browsedFileType == .resize{
                dialog.allowedContentTypes = [.jpeg, .png, .svg, .gif]
            }
            if browsedFileType == .crop{
                dialog.allowedContentTypes = [.jpeg, .png, .gif]
            }
        }else{
            dialog.allowsMultipleSelection = true
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
        }
        /*if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.urls
            self.fileURL?(result)
            self.dismiss(nil)
        } else {
            return
        }*/
        
        if dialog.runModal() == .OK {
                let result = dialog.urls
                
                // 🔒 Check if any locked file is selected
                for url in result {
                    do {
                        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                        if let fileSize = attrs[.size] as? NSNumber {
                            if fileSize.int64Value > 100 * 1024 * 1024 {
                                /*let alert = NSAlert()
                                alert.messageText = "File Too Large"
                                alert.informativeText = "The file \"\(url.lastPathComponent)\" is larger than 100 MB and cannot be used."
                                alert.addButton(withTitle: "OK")
                                alert.runModal()*/
                                Utility.dialogWithMsg(message: "The file \"\(url.lastPathComponent)\" is larger than 100 MB and cannot be used.", window: self.view.window ?? NSWindow())
                                return // stop here
                            }
                        }
                    }catch {
                        print("⚠️ Could not read file info: \(error)")
                    }
                    
                    if url.pathExtension.lowercased() == "pdf" {
                        if let pdfDoc = PDFDocument(url: url), pdfDoc.isEncrypted {
                            /*let alert = NSAlert()
                             alert.messageText = "Locked File Detected"
                             alert.informativeText = "The file \"\(url.lastPathComponent)\" is locked and cannot be used. Please unlock it first."
                             alert.addButton(withTitle: "OK")
                             alert.runModal()*/
                            Utility.dialogWithMsg(message: "The file \"\(url.lastPathComponent)\" is locked and cannot be used. Please unlock it first.", window: self.view.window ?? NSWindow())
                            return // stop here
                        }
                    }
                }
                
                // ✅ Only proceed if all files are valid
                self.fileURL?(result)
                self.dismiss(nil)
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
