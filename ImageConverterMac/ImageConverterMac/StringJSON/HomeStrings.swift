//
//  HomeStrings.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/08/2025.
//

import Foundation

enum FileTypes: String, Codable {
    case JPG, PNG, Webp, PDF, HEIC, HEIF, TIFF, GIF, tools, image
}

enum ToolTypes: String, Codable {
    case resize, watermark, rotate, compress, zip, crop, extractText
}

enum ItemType: String, Codable {
    case JPG, PNG, Webp, PDF, HEIC, HEIF, TIFF, GIF, tools, image
    case resize, watermark, rotate, compress, zip, crop, extractText
}

struct homeObj: Codable {
    let title: String
    let conversionType: FileTypes
    let arr: [listItem]
}
struct listItem: Codable {
    let title: String
    let img: String
    let type: ItemType
}

func homeDecodeJSON() -> [homeObj]? {
    do {
        let jsonDecoder = JSONDecoder()
        let styles = try jsonDecoder.decode([homeObj].self, from: homeJson.data(using: .utf8)!)
        return styles
    } catch {
        print("Decoding error: \(error)")
        return nil
    }
}

//let homeJsonData = homeJson.data(using: .utf8)!
let homeJson: String = """
[
    {
        "title": "JPG Conversions",
        "conversionType": "JPG",
        "arr": [
            { "title": "PNG to JPG", "type": "PNG", "img": "PNGtoJPG" },
            { "title": "HEIC to JPG", "type": "HEIC", "img": "HEICtoJPG" },
            { "title": "HEIF to JPG", "type": "HEIF", "img": "HEIFtoJPG" },
            { "title": "TIFF to JPG", "type": "TIFF", "img": "TIFFtoJPG" },
            { "title": "GIF to JPG", "type": "GIF", "img": "GIFtoJPG" },
            { "title": "WebP to JPG", "type": "Webp", "img": "WebPtoJPG" },
            { "title": "PDF to JPG", "type": "PDF", "img": "PDFtoJPG" }
        ]
    },
    {
        "title": "PNG Conversions",
        "conversionType": "PNG",
        "arr": [
            { "title": "JPG to PNG", "type": "JPG", "img": "JPGtoPNG" },
            { "title": "HEIC to PNG", "type": "HEIC", "img": "HEICtoPNG" },
            { "title": "HEIF to PNG", "type": "HEIF", "img": "HEIFtoPNG" },
            { "title": "TIFF to PNG", "type": "TIFF", "img": "TIFFtoPNG" },
            { "title": "GIF to PNG", "type": "GIF", "img": "GIFtoPNG" },
            { "title": "WebP to PNG", "type": "Webp", "img": "WebPtoPNG" },
            { "title": "PDF to PNG", "type": "PDF", "img": "PDFtoPNG" }
        ]
    },
    {
        "title": "Webp Conversions",
        "conversionType": "Webp",
        "arr": [
            { "title": "PNG to WebP", "type": "PNG", "img": "PNGtoWebP" },
            { "title": "JPG to WebP", "type": "JPG", "img": "JPGtoWebP" }
        ]
    },
    {
        "title": "PDF Conversions",
        "conversionType": "PDF",
        "arr": [
            { "title": "image to PDF", "type": "image", "img": "imagetoPDF" },
            { "title": "JPG to PDF", "type": "JPG", "img": "JPGtoPDF" },
            { "title": "PNG to PDF", "type": "PNG", "img": "PNGtoPDF" },
            { "title": "GIF to PDF", "type": "GIF", "img": "GIFtoPDF" },
            { "title": "TIFF to PDF", "type": "TIFF", "img": "TIFFtoPDF" },
            { "title": "WebP to PDF", "type": "Webp", "img": "WebPtoPDF" },
            { "title": "HEIC to PDF", "type": "HEIC", "img": "HEICtoPDF" },
            { "title": "HEIF to PDF", "type": "HEIF", "img": "HEIFtoPDF" }
        ]
    },
    {
        "title": "Tools",
        "conversionType": "tools",
        "arr": [
            { "title": "Resize Image", "type": "resize", "img": "ResizeImage" },
            { "title": "Watermark", "type": "watermark", "img": "Watermark" },
            { "title": "Rotate Image", "type": "rotate", "img": "RotateImage" },
            { "title": "Compress", "type": "compress", "img": "Compress" },
            { "title": "Convert to Zip", "type": "zip", "img": "ConverttoZip" },
            { "title": "Crop Image", "type": "crop", "img": "CropImage" },
            { "title": "Extract Text", "type": "extractText", "img": "ExtractText" }
        ]
    }
]
"""

