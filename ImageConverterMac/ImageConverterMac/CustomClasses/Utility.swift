//
//  Utility.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/08/2025.
//

import Cocoa
import Reachability
import Foundation

class Utility: NSObject {
    //MARK: Reachability
    class func isNetworkAvailable()->Bool{
        do {
            let reachability = try Reachability()
            
            switch reachability.connection{
            case .unavailable:
                return false
            default:
                return true
            }
            
        }catch{
            return false
        }
    }
    //MARK: Alerts
    class func dialogWithMsg(message: String, window: NSWindow) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .warning
        
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: window)
    }
    class func showAlert(message: String, info: String = "", firstButtonText:String, secondButtonText :String = "" , window: NSWindow) -> Bool{
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = info
        alert.alertStyle = .warning
        alert.addButton(withTitle: firstButtonText)
        if secondButtonText != ""{
            alert.addButton(withTitle: secondButtonText)
        }
        alert.beginSheetModal(for: window)
        return alert.runModal() == .alertFirstButtonReturn
    }
    class func showOneTextfieldAlert(
        messageTest: String,
        informativeText: String = "",
        window: NSWindow,
        completion: ((String?) -> Void)?
    ) {
        let alert = NSAlert()
        alert.informativeText = informativeText
        alert.messageText = messageTest
        alert.addButton(withTitle: "Confirm".localized())
        alert.addButton(withTitle: "Cancel".localized())
        
        let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        inputTextField.focusRingType = .none
        inputTextField.placeholderString = ("Enter chat name".localized())
        alert.accessoryView = inputTextField
        alert.beginSheetModal(for: window) { modalResponse in
            if modalResponse == .alertFirstButtonReturn {
                completion?(inputTextField.stringValue)
            }
        }
    }
    
    class func showAlertSheet(
        message: String,
        information: String,
        firstButtonTitle: String,
        secondButtonTitle: String,
        window: NSWindow,
        completion: @escaping (Bool) -> Void
    ) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .warning
        alert.informativeText = information
        alert.addButton(withTitle: firstButtonTitle)
        alert.addButton(withTitle: secondButtonTitle)
        alert.beginSheetModal(for: window) { modalResponse in
            let response = modalResponse == .alertFirstButtonReturn
            completion(response)
        }
    }
    //MARK: Create Unique ID
    class func generateUnixTimeStamp() -> String{
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en")
        let dateString = formatter.string(from: now)
        let dt = formatter.date(from: dateString)
        print(Int64(dt!.timeIntervalSince1970))
        return "\(Int64(dt!.timeIntervalSince1970))"
    }
    //MARK: Check launch count
    class func incrementLaunchCountAndCheck() -> Bool {
        var count = ud.integer(forKey: keyLaunchCount)
        count += 1
        ud.set(count, forKey: keyLaunchCount)
        
        return count % 3 == 0 // true on every third launch
    }
    //MARK: Get & Set Methods For UserDefaults
    
    class func saveDefaultObject(obj:String,forKey strKey:String){
        ud.set(obj, forKey: strKey)
    }
    
    class func getDefaultObject(forKey strKey:String) -> String {
        if let obj = ud.value(forKey: strKey) as? String{
            let obj2 = ud.value(forKey: strKey) as! String
            return obj2
        }else{
            return ""
        }
    }
    
    class func deleteDefaultObject(forKey strKey:String) {
        ud.set(nil, forKey: strKey)
    }
    
    //MARK: Hud show hide
    
    class func showHud(controller: NSView) {
        hud = MBProgressHUD.showAdded(to: controller, animated: true)
    }
    
    class func hideHud(){
        hud?.hide(true)
    }
    
    //MARK: Open Email
    class func openEmail(address: String, subject: String, body: String) {
        var deviceName = ""
        let deviceStr = "MacBook Pro" //Host.current().localizedName
        if let device = deviceStr.components(separatedBy: "'s ").last {
            deviceName = device
        }
        
        var buildVersion = ""
        let pro = (isPremiumUser()) == true ? "Subscribed" : "Free"
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String , let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildVersion = "\(version) (\(build))"
        }
        
        let html = NSString.init(format: "<br> <br> <br> <br><br> %@ <br>%@<br><b>OSX Versoin :</b> %@ <br> <b>Device Type :</b> %@ <br> This information will help us to find your issue.", body, appName , ProcessInfo.processInfo.operatingSystemVersionString, deviceName)
        
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)
        service?.recipients = [address]
        service?.subject = "\(appName) | MAC | \(buildVersion) | \(pro)"
        
        service?.perform(withItems: [String.init(html).convertHtml()])
    }
    
    //MARK: Increase Free Hits
    class func increaseFreeHitsCount() {
        var count = Utility.getDefaultObject(forKey: strFreeHitsCount)
        count = "\(Int(count)! + 1)"
        Utility.saveDefaultObject(obj: count, forKey: strFreeHitsCount)
    }
    //MARK: Check File name
    class func sanitizeFileName(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Replace spaces with underscores
        var sanitized = trimmed.replacingOccurrences(of: " ", with: "_")

        // Remove all characters that are not letters, digits, underscores, or dashes
        let allowedCharacters = CharacterSet.alphanumerics.union(.init(charactersIn: "_-"))
        sanitized = String(sanitized.unicodeScalars.filter { allowedCharacters.contains($0) })

        // Prevent empty name
        return sanitized.isEmpty ? "untitled_file" : sanitized
    }
    //MARK: Save Files in Finder
    /*class func saveFilesToSelectedLocation(
        fileURLs: [URL],
        completion: @escaping (Bool, [Error]) -> Void
    ) {
        let panel = NSOpenPanel()
        panel.title = "Select Destination Folder"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        
        panel.begin { response in
            var errors: [Error] = []
            
            guard response == .OK, let destinationFolder = panel.url else {
                // User cancelled
                completion(false, [])
                return
            }
            
            for fileURL in fileURLs {
                let destinationURL = destinationFolder.appendingPathComponent(fileURL.lastPathComponent)
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.copyItem(at: fileURL, to: destinationURL)
                } catch {
                    errors.append(error)
                }
            }
            
            // Call back when done
            completion(errors.isEmpty, errors)
        }
    }*/
    
    class func saveFilesToSelectedLocation(
        fileURLs: [URL],
        completion: @escaping (Bool, [Error]) -> Void
    ) {
        let panel = NSOpenPanel()
        panel.title = "Select Destination Folder"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true

        panel.begin { response in
            var errors: [Error] = []
            var existingFiles = [URL]()

            guard response == .OK, let destinationFolder = panel.url else {
                // User cancelled
                completion(false, [])
                return
            }

            // Check if any files already exist in the destination folder
            for fileURL in fileURLs {
                let destinationURL = destinationFolder.appendingPathComponent(fileURL.lastPathComponent)
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    existingFiles.append(destinationURL)
                }
            }

            // If there are files that already exist, ask for confirmation
            if !existingFiles.isEmpty {
                let alert = NSAlert()
                alert.messageText = "File Already Exist"
                alert.informativeText = "File already exist at this location. Do you want to overwrite?"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "Overwrite")
                alert.addButton(withTitle: "Cancel")

                let alertResponse = alert.runModal()

                // If user clicks "Cancel", abort the operation
                if alertResponse == .alertSecondButtonReturn {
                    completion(false, [])
                    return
                }
            }

            // Proceed with overwriting the files
            for fileURL in fileURLs {
                let destinationURL = destinationFolder.appendingPathComponent(fileURL.lastPathComponent)
                do {
                    // Remove the existing file before copying if needed
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.copyItem(at: fileURL, to: destinationURL)
                } catch {
                    errors.append(error)
                }
            }

            // Call back when done
            completion(errors.isEmpty, errors)
        }
    }

    
    //MARK: Make Txt files
    
    class func saveTextFile(_ text: String, for imageURL: URL) -> URL? {
        let fileName = imageURL.deletingPathExtension().lastPathComponent + ".txt"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try text.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("Failed to save text file: \(error)")
            return nil
        }
    }
}
