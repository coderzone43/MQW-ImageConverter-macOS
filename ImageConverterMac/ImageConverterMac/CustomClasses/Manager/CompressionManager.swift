//
//  CompressionManager.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 21/08/2025.
//


class CompressionManager {
    static let shared = CompressionManager()
    private init() {}
    
    private var isCancelled = false
    
    func cancel() {
        isCancelled = true
    }
    
    func reset() {
        isCancelled = false
    }
    
    var cancelled: Bool {
        return isCancelled
    }
}