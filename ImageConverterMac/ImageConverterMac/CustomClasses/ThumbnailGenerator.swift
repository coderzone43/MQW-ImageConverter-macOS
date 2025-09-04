//
//  ThumbnailGenerator.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 07/08/2025.
//


import Cocoa
import Quartz
import ImageIO

// Result Struct
struct ThumbnailResult {
    let image: NSImage?
    let fileName: String
}

class ThumbnailGenerator {
    
    // Detects ItemType based on extension
    private static func detectItemType(for url: URL) -> ItemType {
        let ext = url.pathExtension.lowercased()
        
        switch ext {
        case "pdf":
            return .PDF
        case "jpg", "jpeg":
            return .JPG
        case "png":
            return .PNG
        case "webp":
            return .Webp
        case "heic":
            return .HEIC
        case "heif":
            return .HEIF
        case "tiff", "tif":
            return .TIFF
        case "gif":
            return .GIF
        default:
            return .image
        }
    }
    
    // Public Method (type auto-detected)
    static func generateThumbnailWithName(for url: URL, size: NSSize = NSSize(width: 50, height: 50)) -> ThumbnailResult {
        let type = detectItemType(for: url)
        let thumbnail = generateThumbnail(for: url, type: type, size: size)
        let fileName = url.lastPathComponent
        return ThumbnailResult(image: thumbnail, fileName: fileName)
    }
    
    // Internal Thumbnail Dispatcher
    private static func generateThumbnail(for url: URL, type: ItemType, size: NSSize) -> NSImage? {
        switch type {
        case .PDF:
            return generatePDFThumbnail(for: url, size: size)
        case .JPG, .PNG, .Webp, .HEIC, .HEIF, .TIFF, .image:
            return generateImageThumbnail(for: url, size: size)
        case .GIF:
            return generateGIFThumbnail(for: url, size: size)
        default:
            return nil
        }
    }

    // PDF Thumbnail
    private static func generatePDFThumbnail(for url: URL, size: NSSize) -> NSImage? {
        guard let pdfDocument = PDFDocument(url: url),
              let page = pdfDocument.page(at: 0) else { return nil }
        return page.thumbnail(of: size, for: .cropBox)
    }

    // Static Image Thumbnail
    private static func generateImageThumbnail(for url: URL, size: NSSize) -> NSImage? {
        guard let image = NSImage(contentsOf: url) else { return nil }
        return resizeImage(image, to: size)
    }

    // GIF Thumbnail (first frame)
    private static func generateGIFThumbnail(for url: URL, size: NSSize) -> NSImage? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let firstFrame = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            return nil
        }
        let image = NSImage(cgImage: firstFrame, size: size)
        return resizeImage(image, to: size)
    }

    // Resize Helper
    private static func resizeImage(_ image: NSImage, to targetSize: NSSize) -> NSImage? {
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: targetSize),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}

