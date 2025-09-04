//
//  HistoryManager.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 28/08/2025.
//

struct FileInfo: Codable {
    var name: String
    var size: Int
    var path: String
    var conversionType: FileTypes
    var fileExtension: String
    var historyID: String
}

enum HistoryError: Error {
    case notFound
    case duplicateName
    case fileSystemError(Error)
}

import Foundation

class HistoryManager {
    static let shared = HistoryManager()

    private var downloadHistory: [FileInfo] = []

    private init() {
        loadHistoryFromDefaults() // Load history on initialization
    }

    // Add a new downloaded file to history
    func addDownloadHistory(fileInfo: FileInfo) {
        downloadHistory.append(fileInfo)
        saveHistoryToDefaults() // Save after adding
    }

    // Retrieve all download history
    func getDownloadHistory() -> [FileInfo] {
        // Remove any files that no longer exist
        /*downloadHistory = downloadHistory.filter { fileInfo in
            return FileManager.default.fileExists(atPath: fileInfo.path)
        }*/
        loadHistoryFromDefaults()
        return downloadHistory
    }
    
    //Get File size
    func getFileSize(bytes: Int) -> String {
        let kb = 1024
        let mb = kb * 1024
        let gb = mb * 1024
        
        if bytes < kb {
            return "\(bytes) B"
        } else if bytes < mb {
            let sizeInKB = Double(bytes) / Double(kb)
            return String(format: "%.2f KB", sizeInKB)
        } else if bytes < gb {
            let sizeInMB = Double(bytes) / Double(mb)
            return String(format: "%.2f MB", sizeInMB)
        } else {
            let sizeInGB = Double(bytes) / Double(gb)
            return String(format: "%.2f GB", sizeInGB)
        }
    }

    // Rename a file in history
    /*func renameFile(at index: Int, newName: String) {
        guard index >= 0 && index < downloadHistory.count else { return }
        
        // Check if the new name already exists in the history
        if downloadHistory.contains(where: { $0.name == newName }) {
            print("❌ Error: A file with the name \(newName) already exists.")
            showAlert(message: "A file with the name \(newName) already exists. Please choose a different name.")
            return
        }
        
        var fileInfo = downloadHistory[index]
        
        // Create a URL from the file path
        let fileURL = URL(fileURLWithPath: fileInfo.path)
        
        // Get the new path by deleting the last component and appending the new name
        let newPath = fileURL.deletingLastPathComponent().appendingPathComponent(newName).path
        
        // Rename the file in the file system
        let oldURL = fileURL
        let newURL = URL(fileURLWithPath: newPath)
        
        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            
            // Update the history with the new name and path
            fileInfo.name = newName
            fileInfo.path = newPath
            downloadHistory[index] = fileInfo
            
            // Save the updated history
            saveHistoryToDefaults()
            
            print("✅ File renamed successfully")
        } catch {
            print("❌ Rename failed: \(error)")
            showAlert(message: "File renaming failed. Please try again.")
        }
    }

    // Delete a file from history and file system
    func deleteFile(at index: Int) {
        guard index >= 0 && index < downloadHistory.count else { return }
        let fileInfo = downloadHistory[index]
        
        // Delete the file from the file system
        let fileURL = URL(fileURLWithPath: fileInfo.path)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            
            // Remove from history
            downloadHistory.remove(at: index)
            saveHistoryToDefaults()
            
            print("✅ File deleted successfully")
        } catch {
            print("❌ Deletion failed: \(error)")
            showAlert(message: "File deletion failed. Please try again.")
        }
    }*/
    
    // Rename file using historyID
    func renameFile(historyID: String, newName: String, completion: @escaping (Result<FileInfo, HistoryError>) -> Void) {
        guard let index = downloadHistory.firstIndex(where: { $0.historyID == historyID }) else {
            completion(.failure(.notFound))
            return
        }
        
        if downloadHistory.contains(where: { $0.name == newName }) {
            completion(.failure(.duplicateName))
            return
        }
        
        var fileInfo = downloadHistory[index]
        let fileURL = URL(fileURLWithPath: fileInfo.path)
        let newPath = fileURL.deletingLastPathComponent().appendingPathComponent(newName).path
        let newURL = URL(fileURLWithPath: newPath)
        
        do {
            try FileManager.default.moveItem(at: fileURL, to: newURL)
            fileInfo.name = newName
            fileInfo.path = newPath
            downloadHistory[index] = fileInfo
            saveHistoryToDefaults()
            completion(.success(fileInfo))
        } catch {
            completion(.failure(.fileSystemError(error)))
        }
    }
    
    
    // Delete file using historyID
    func deleteFile(historyID: String, completion: @escaping (Result<Void, HistoryError>) -> Void) {
        guard let index = downloadHistory.firstIndex(where: { $0.historyID == historyID }) else {
            completion(.failure(.notFound))
            return
        }
        
        let fileInfo = downloadHistory[index]
        let fileURL = URL(fileURLWithPath: fileInfo.path)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            downloadHistory.remove(at: index)
            saveHistoryToDefaults()
            completion(.success(()))
        } catch {
            completion(.failure(.fileSystemError(error)))
        }
    }
    
    func downloadFile(at index: Int) {
        guard index >= 0 && index < downloadHistory.count else { return }
        let fileInfo = downloadHistory[index]
        
        // Create a URL from the file path
        let fileURL = URL(fileURLWithPath: fileInfo.path)
        
        // Show Save Panel to let the user select a location
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = fileInfo.name  // Default name in the save panel
        
        // Open the save panel
        savePanel.begin { response in
            if response == .OK, let destinationURL = savePanel.url {
                do {
                    // Copy the file to the selected location
                    try FileManager.default.copyItem(at: fileURL, to: destinationURL)
                    print("✅ File saved at \(destinationURL.path)")
                    
                    // Optionally, update your history to reflect the new location (if needed)
                    // For example, you could add the file path to your history or perform other actions
                } catch {
                    print("❌ Failed to save the file: \(error)")
                    // Optionally, show an alert to the user if saving fails
                    let alert = NSAlert()
                    alert.messageText = "Save failed"
                    alert.informativeText = "There was an error saving the file."
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }
    }

    // Save the history to UserDefaults
    private func saveHistoryToDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(downloadHistory) {
            UserDefaults.standard.set(encoded, forKey: "downloadHistory")
        }
    }

    // Load the history from UserDefaults
    private func loadHistoryFromDefaults() {
        if let savedHistory = UserDefaults.standard.object(forKey: "downloadHistory") as? Data {
            let decoder = JSONDecoder()
            if let loadedHistory = try? decoder.decode([FileInfo].self, from: savedHistory) {
                downloadHistory = loadedHistory
            }
        }
    }

    // Optionally, clear the history
    func clearHistory() {
        downloadHistory.removeAll()
        saveHistoryToDefaults()
    }
    
    // Show an alert to the user
    private func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
