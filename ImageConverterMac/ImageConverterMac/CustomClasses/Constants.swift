//
//  Constants.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/08/2025.
//

import Foundation
import AppKit

let appName = "Image Converter"

let keyLaunchCount = "keyLaunchCount"
let strRating = "strRating"
let strFreeHitsCount = "strFreeHitsCount"
let strDisplayMode = "strDisplayMode"
let strNotificationsEnable = "strNotificationsEnable"
let strViewModeSetFromApp = "strViewModeSetFromApp"

// MARK: - Subscription
var weeklySubscription = ""
var monthlySubscription = ""
var yearlySubscription = ""

// MARK: - Shared Secret for App
let SharedSecret = ""
let appID = ""

let urlTerms = "https://sites.google.com/view/muhammadqasimwali/terms-of-use"
let urlPrivacy = "https://sites.google.com/view/muhammadqasimwali/privacy-policy"
//let urlSupport = "https://sites.google.com/view/muhammadqasimwali/customer-support"
let urlAppStore = "https://apps.apple.com/us/app/id\(appID)"
let urlRate = "https://apps.apple.com/app/id\(appID)?action=write-review"
let urlMoreApps = "https://apps.apple.com/developer/muhammad-qasim-wali/id1772758953"

let supportEmail = "muhammadqasimwali45@gmail.com"

// MARK: - Premium User Constants
let PREMIUM_USER = "PremiumUser"
let LIFE_TIME_USER = "LifeTimeUser"
let freeHitsIntValue:Int = 1

/// Checks if the user is a premium user
/// - Returns: A Boolean value indicating whether the user is premium or not
func isPremiumUser() -> Bool {
    var isPro = false
    if ud.bool(forKey: LIFE_TIME_USER) {
        isPro = true
    }
    if ud.bool(forKey: PREMIUM_USER) {
        isPro = true
    }
    return isPro
}

let ud = UserDefaults.standard
let appDelegate = NSApp.delegate as! AppDelegate
var hud: MBProgressHUD!

var splitMainViewController: NSSplitViewController = {
    let viewController = NSSplitViewController()
    return viewController
}()

enum DisplayModeOptions: String{
    case System = "System"
    case Dark = "Dark"
    case Light = "Light"
}

let alertTitleNoInternet = "No Internet Connection"
let alertTitleError = "Error"
let alertTitleNormal = "Alert"
let alertTitleCongratulation = "Congratulation"
let alertMsgNoInternet = "Your device is not connected to the internet. Please connect to a WLAN network."

extension Notification.Name {
    static let PremiumPurchasedSuccessed = Notification.Name("PremiumPurchasedSuccessed")
    static let ContentUpdated = NSNotification.Name("ContentUpdated")
    static let NotificationsStateChanged = NSNotification.Name("NotificationsStateChanged")
}

enum ExportType : String, CaseIterable, Sendable{
  case SaveAsPDF
  case SaveAsPNG
  case SaveAsJPEG
  var nameString: String{
    switch self {
    case .SaveAsPDF:
      "Save as PDF"
    case .SaveAsPNG:
      "Save as PNG"
    case .SaveAsJPEG:
      "Save as JPEG"
    }
  }
  var scalingFactor: CGFloat {
    switch self {
    case .SaveAsPDF:
      return 3.0 // Higher scaling for PDF
    case .SaveAsPNG:
      return 2.0 // High quality for PNG
    case .SaveAsJPEG:
      return 2.0 // Lower quality for JPEG (scaled)
    }
  }
  var quality: CGFloat {
    switch self {
    case .SaveAsPDF:
      return 1.0 // High quality for PDF
    case .SaveAsPNG:
      return 1.0 // High quality for PNG
    case .SaveAsJPEG:
      return 0.5 // Lower quality for JPEG
    }
  }
}
