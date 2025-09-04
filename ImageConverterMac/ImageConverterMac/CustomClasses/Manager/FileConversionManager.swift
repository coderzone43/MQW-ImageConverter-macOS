//
//  FileConversionManager.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 08/08/2025.
//

import Foundation
import Cocoa
import PDFKit
import ZIPFoundation

enum ConversionCategory {
    case imageToImage
    case imageToPDF
    case pdfToImage
}

// MARK: - CancellationToken

class CancellationToken {
    private var isCancelled = false
    private let lock = NSLock()

    func cancel() {
        lock.lock()
        isCancelled = true
        lock.unlock()
    }

    func cancelled() -> Bool {
        lock.lock()
        let result = isCancelled
        lock.unlock()
        return result
    }
}

// MARK: - FileConversionManager

class FileConversionManager {

    static func convert(
        files: [URL],
        conversionType: ConversionCategory,
        inputType: ItemType,
        outputType: ItemType,
        cancellationToken: CancellationToken? = nil,
        progress: @escaping (Double) -> Void,
        completion: @escaping ([URL]) -> Void
    ) {
        var outputURLs: [URL] = []

        DispatchQueue.global(qos: .userInitiated).async {
            for (index, fileURL) in files.enumerated() {
                // Cancel if requested
                if cancellationToken?.cancelled() == true {
                    print("Conversion cancelled by user.")
                    break
                }

                var result: [URL] = []

                switch conversionType {
                case .imageToImage:
                    if let converted = convertImageToImage(inputURL: fileURL, toType: outputType) {
                        result.append(converted)
                    }

                case .imageToPDF:
                    if let converted = convertImageToPDF(inputURL: fileURL) {
                        result.append(converted)
                    }

                case .pdfToImage:
                    if let converted = convertPDFToImages(inputURL: fileURL, toType: outputType){
                        result.append(converted)
                    }
                }

                outputURLs.append(contentsOf: result)

                // Report progress
                let percent = Double(index + 1) / Double(files.count)
                DispatchQueue.main.async {
                    progress(percent)
                }
            }

            // Final callback
            DispatchQueue.main.async {
                completion(outputURLs)
            }
        }
    }

    // MARK: - Image → Image

    private static func convertImageToImage(inputURL: URL, toType: ItemType) -> URL? {
        guard let image = NSImage(contentsOf: inputURL),
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData)
        else { return nil }

        let imageData: Data?
        var ext: String = ""

        switch toType {
        case .JPG:
            imageData = bitmap.representation(using: .jpeg, properties: [:])
            ext = "jpg"
        case .PNG:
            imageData = bitmap.representation(using: .png, properties: [:])
            ext = "png"
        case .TIFF:
            imageData = bitmap.representation(using: .tiff, properties: [:])
            ext = "tiff"
        case .GIF:
            imageData = bitmap.representation(using: .gif, properties: [:])
            ext = "gif"
        case .HEIC:
            imageData = bitmap.representation(using: .png, properties: [:])
            ext = "heic"
        case .HEIF:
            imageData = bitmap.representation(using: .png, properties: [:])
            ext = "heif"
        case .Webp:
            imageData = bitmap.representation(using: .png, properties: [:])
            ext = "webP"
        default:
            // HEIC/HEIF not supported via NSBitmapImageRep
            return nil
        }

        guard let data = imageData else { return nil }

        let outURL = tempOutputURL(basedOn: inputURL, newExtension: ext)
        try? data.write(to: outURL)
        return outURL
    }

    // MARK: - Image → PDF

    private static func convertImageToPDF(inputURL: URL) -> URL? {
        guard let image = NSImage(contentsOf: inputURL) else { return nil }
        guard let pdfPage = PDFPage(image: image) else { return nil }

        let pdfDoc = PDFDocument()
        pdfDoc.insert(pdfPage, at: 0)

        let outURL = tempOutputURL(basedOn: inputURL, newExtension: "pdf")
        pdfDoc.write(to: outURL)
        return outURL
    }

    // MARK: - PDF → Images

    private static func convertPDFToImages(inputURL: URL, toType: ItemType) -> URL? {
        guard let pdfDocument = PDFDocument(url: inputURL) else {
            print("Failed to load PDF.")
            return nil
        }
        
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        do {
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create temp dir: \(error)")
        }
        
        var imageFileURLs: [URL] = []
        
        for i in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: i) else { continue }
            let pageRect = page.bounds(for: .mediaBox)
            
            let img = NSImage(size: pageRect.size)
            img.lockFocus()
            
            guard let context = NSGraphicsContext.current?.cgContext else {
                print("Failed to get graphics context.")
                img.unlockFocus()
                continue
            }
            
            context.saveGState()
            context.setFillColor(NSColor.white.cgColor)
            context.fill(pageRect)
            
            // Flip context vertically
            //context.translateBy(x: 0, y: pageRect.height)
            //context.scaleBy(x: 1, y: -1)
            
            // Draw the PDF page
            page.draw(with: .mediaBox, to: context)
            context.restoreGState()
            
            img.unlockFocus()
            
            var ext = "jpg"
            var imgType: NSBitmapImageRep.FileType = .jpeg
            if toType == .PNG{
                ext = "png"
                imgType = .png
            }
            
            // Save as image
            if let tiffData = img.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiffData),
               let jpegData = bitmap.representation(using: imgType, properties: [.compressionFactor: 1.0]) {
                let imageURL = tempDir.appendingPathComponent("page_\(i + 1).\(ext)")
                do {
                    try jpegData.write(to: imageURL)
                    imageFileURLs.append(imageURL)
                } catch {
                    print("Failed to write image: \(error)")
                }
            }
        }
        
        //let baseName = inputURL.deletingPathExtension().lastPathComponent
        let zipFileURL = getDocumentsDirectory().appendingPathComponent("Archive_\(Int(Date().timeIntervalSince1970)).zip")
        if fileManager.fileExists(atPath: zipFileURL.path) {
            try? fileManager.removeItem(at: zipFileURL)
        }
        
        guard let archive = Archive(url: zipFileURL, accessMode: .create) else {
            print("Failed to create archive")
            return nil
        }
        
        for imageURL in imageFileURLs {
            do {
                try archive.addEntry(with: imageURL.lastPathComponent, relativeTo: tempDir)
            } catch {
                print("Failed to add \(imageURL.lastPathComponent) to zip: \(error)")
            }
        }

        return archive.url
    }
    
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    // MARK: - Helper

    private static func tempOutputURL(basedOn inputURL: URL, newExtension: String) -> URL {
        let fileName = inputURL.deletingPathExtension().lastPathComponent + "_converted." + newExtension
        return FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    }
}
