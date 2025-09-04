//
//  CompressibleImage.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 21/08/2025.
//


struct CompressibleImage {
    let url: URL
    var image: NSImage
    let originalData: Data
    var compressedData: Data?
    
    var originalSizeString: String {
        formatSize(originalData.count)
    }
    
    var compressedSizeString: String {
        guard let compressedData = compressedData else { return "—" }
        return formatSize(compressedData.count)
    }
    
    private func formatSize(_ bytes: Int) -> String {
        let kb = Double(bytes) / 1024.0
        if kb < 1024 {
            return String(format: "%.2f KB", kb)
        } else {
            let mb = kb / 1024.0
            return String(format: "%.2f MB", mb)
        }
    }
}

