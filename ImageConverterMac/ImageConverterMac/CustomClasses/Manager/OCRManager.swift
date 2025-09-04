//
//  OCRManager.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 20/08/2025.
//


import Cocoa
import Vision

class OCRManager {
    // Extract text from multiple images with progress
    func extractText(from imageURLs: [URL], progressHandler: @escaping (Double) -> Void, completion: @escaping ([String]) -> Void) {
        var results: [String] = Array(repeating: "", count: imageURLs.count)
        
        let total = imageURLs.count
        var completed = 0
        
        let dispatchGroup = DispatchGroup()
        
        for (index, url) in imageURLs.enumerated() {
            dispatchGroup.enter()
            
            if let image = NSImage(contentsOf: url),
               let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                
                let request = VNRecognizeTextRequest { (request, error) in
                    defer {
                        completed += 1
                        let progress = Double(completed) / Double(total)
                        DispatchQueue.main.async {
                            progressHandler(progress)
                        }
                        dispatchGroup.leave()
                    }
                    
                    if let observations = request.results as? [VNRecognizedTextObservation] {
                        let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
                        results[index] = text
                    }
                }
                
                request.recognitionLanguages = ["en-US"] // add more languages if needed
                request.usesLanguageCorrection = true
                
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try requestHandler.perform([request])
                    } catch {
                        print("Error performing OCR: \(error)")
                        dispatchGroup.leave()
                    }
                }
            } else {
                completed += 1
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(results)
        }
    }
}
