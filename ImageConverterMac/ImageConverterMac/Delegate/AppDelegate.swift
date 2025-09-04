//
//  AppDelegate.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/08/2025.
//

import Cocoa
import StoreKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var products: Set<SKProduct> = [] // Holds the retrieved SKProducts
    var subScriptionsOffers: Set<String> = [weeklySubscription, monthlySubscription, yearlySubscription, yearlyOfferSubscription] // Set of subscription product identifiers

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        initialConfiguration()
        setUpRetrieveProducts()
        getPurchases()
        checkStatusOfPremiumUser()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return NSApplication.TerminateReply.terminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}
extension AppDelegate {
    
    // MARK: - Initial Configuration
    fileprivate func initialConfiguration() {
        if !(Utility.getDefaultObject(forKey: strFreeHitsCount).count > 0){
            Utility.saveDefaultObject(obj: "1", forKey: strFreeHitsCount)
        }
        if !(Utility.getDefaultObject(forKey: strDisplayMode).count > 0){
            Utility.saveDefaultObject(obj: DisplayModeOptions.System.rawValue, forKey: strDisplayMode)
        }
        if (ud.bool(forKey: strViewModeSetFromApp)) {
            if Utility.getDefaultObject(forKey: strDisplayMode) == DisplayModeOptions.System.rawValue {
                NSApp.appearance = nil
            }else if Utility.getDefaultObject(forKey: strDisplayMode) == DisplayModeOptions.Dark.rawValue {
                NSApp.appearance = NSAppearance(named: .darkAqua)
            }else{
                NSApp.appearance = NSAppearance(named: .aqua)
            }
        }
    }
    
}
// MARK: - Payment and Subscription Handling
extension AppDelegate {
    
    // MARK: - Check Premium User Status
    @objc func checkStatusOfPremiumUser() {
        if !(ud.bool(forKey: LIFE_TIME_USER)) { // Check if the user is a lifetime premium user
            if Utility.isNetworkAvailable() { // Ensure internet connection is available
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.verifyReceipt { isPro in
                        if isPro{
                            NotificationCenter.default.post(name: .PremiumPurchasedSuccessed, object: nil) // Notify premium purchase success
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Retrieve User Purchases
    func getPurchases() {
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            return true // Allow all store payments
        }
        
        // Complete any pending transactions
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction) // Finalize the transaction if needed
                    }
                    // Unlock the content for the user here
                case .failed, .purchasing, .deferred:
                    break // Do nothing for failed or pending transactions
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - Set Up and Retrieve In-App Products
    func setUpRetrieveProducts() {
        SwiftyStoreKit.retrieveProductsInfo(subScriptionsOffers) { [weak self] (results) in
            guard let self = self else { return }
            if results.retrievedProducts.count > 0 {
                self.products = results.retrievedProducts // Store the retrieved products
            }
        }
    }
}

// MARK: - Receipt Verification and Premium Status Management
extension AppDelegate {
    
    // MARK: - Verify In-App Purchase Receipt
    func verifyReceipt(_ completion: @escaping (_ isPro: Bool) -> Void) {
        let productIdentifiers = appDelegate.subScriptionsOffers // Get product identifiers for subscriptions
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: SharedSecret) // Create a receipt validator

        // Verify the receipt using the validator
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // Check the status of auto-renewable subscriptions in the receipt
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(ofType: .autoRenewable, productIds: productIdentifiers, inReceipt: receipt, validUntil: Date())
                switch purchaseResult {
                case .purchased(_, _):
                    ud.set(true, forKey: PREMIUM_USER) // Mark the user as premium
                    completion(true)
                case .expired(_, _):
                    ud.set(false, forKey: PREMIUM_USER) // Mark the user as non-premium
                    completion(false)
                case .notPurchased:
                    ud.set(false, forKey: PREMIUM_USER) // The user has not purchased the subscription
                    completion(false)
                case .billingRetry(expiryDate: _, items: _):
                    completion(ud.bool(forKey: PREMIUM_USER)) // Check if the user's premium status is retained
                }
            case .error(error: _):
                ud.set(false, forKey: PREMIUM_USER) // Handle receipt validation error
                completion(false)
            case .cancelError(error: _):
                ud.set(false, forKey: PREMIUM_USER) // Handle receipt validation cancellation
                completion(false)
            }
        }
    }
}
