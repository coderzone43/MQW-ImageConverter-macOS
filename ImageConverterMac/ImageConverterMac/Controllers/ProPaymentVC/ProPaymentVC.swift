//
//  ProPaymentVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 06/08/2025.
//

import Cocoa
import StoreKit

enum PlanType{
    case Weekly
    case Monthly
    case Yearly
}

class ProPaymentVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var collectionPayment: NSCollectionView!
    @IBOutlet weak var lblFreeTrial: NSTextField!
    @IBOutlet weak var btnContinue: NSButton!
    @IBOutlet weak var btnRestore: NSButton!
    @IBOutlet weak var btnClose: NSButton!
    @IBOutlet weak var viewSeperatorContinueFree: NSView!
    @IBOutlet weak var btnContinueFree: NSButton!
    
    var subscriptionPlanList: [String] = [weeklySubscription, monthlySubscription, yearlySubscription]
    var currentSelectedProduct: SKProduct?
    var selectedPlan = 1
    var plans = ["Weekly", "Monthly", "Yearly"]
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    //MARK: Setup View
    func setupView() {
        collectionPayment.hideVerticalScroller()
        
        setupNotificationObservers()
        retriveProducts()
    }
    
    //MARK: Utility Methods
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkPremium), name: .PremiumPurchasedSuccessed, object: nil)
    }
    
    //MARK: Button Action
    @IBAction func btnCloseAction(_ sender: Any) {
        dismiss(nil)
    }
    @IBAction func btnContinueAction(_ sender: Any) {
        Utility.showHud(controller: self.view.window?.contentViewController?.view ?? NSView())
        currentSelectedProduct = self.getProductFromStore(productID: subscriptionPlanList[selectedPlan])
        if currentSelectedProduct != nil {
            buyPlan(product: currentSelectedProduct!)
        }
    }
    @IBAction func btnRestoreAction(_ sender: Any) {
        restorePurchase()
    }
    @IBAction func btnTermsAction(_ sender: Any) {
        guard let window = self.view.window else { return }
        window.contentViewController?.openURLinExternalBrowser(url: urlTerms)
    }
    @IBAction func btnPrivacyAction(_ sender: Any) {
        guard let window = self.view.window else { return }
        window.contentViewController?.openURLinExternalBrowser(url: urlPrivacy)
    }
    
    //MARK: API Methods
    
    //MARK: DELEGATE METHODS
    
    //MARK: TableView
    
    //MARK: CollectionView
    
    //MARK: Segment Control
    
    //MARK: Alert View
    
    //MARK: TextField
    
}
extension ProPaymentVC: NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscriptionPlanList.count
    }
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell  = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ProPaymentCVC"), for: indexPath) as! ProPaymentCVC
        
        if let product = self.getProductFromStore(productID: subscriptionPlanList[indexPath.item]){
            cell.lblPrice.stringValue = product.localizedPrice!
            cell.lblPackageName.stringValue = plans[indexPath.item]
            
            if product.introductoryPrice != nil{
                cell.lblSave.textColor = NSColor.appWhiteOnly
                cell.viewSave.fillColor = NSColor.proPurple
            }else{
                if indexPath.item == 0{
                    cell.lblSave.textColor = NSColor.black1
                    cell.viewSave.fillColor = NSColor.white3
                }else{
                    cell.lblSave.textColor = NSColor.appWhiteOnly
                    cell.viewSave.fillColor = NSColor.proGreen
                }
            }
            
            var plan:PlanType = .Weekly
            if indexPath.item == 0{
                plan = .Weekly
            }else if indexPath.item == 1{
                plan = .Monthly
            }else if indexPath.item == 2{
                plan = .Yearly
            }
            
            if let baseProduct = getProductFromStore(productID: self.subscriptionPlanList.first!){
                if indexPath.item == 0 {
                    //let weeklySave = baseProduct.price.doubleValue * 2
                    cell.lblSave.stringValue = "Basic"
                    let weekly_save_currency = convertPricePerPlan(price: (Double(truncating: product.price)/7), product: product, plan: "/" + plans[0], isLifeTime: false, period: "Day")
                    cell.lblPerDayPrice.attributedStringValue = weekly_save_currency
                }
                if indexPath.item == 1 {
                    cell.lblSave.stringValue = "Free Trial"
                    cell.lblPerDayPrice.attributedStringValue = self.convertPricePerPlan(price: (Double(truncating: product.price)/30), product: product, plan: "/" + plans[0], isLifeTime: false, period: "Week")
                }
                if indexPath.item == 2{
                    let discountInPercentage = self.getPercentageOffOnPlan(basePrice: Double(truncating: baseProduct.price), discountPrice: Double(truncating: product.price), for: plan)
                    cell.lblSave.stringValue = "Save" + " " + "\(Int(discountInPercentage))%"
                    cell.lblPerDayPrice.attributedStringValue = self.convertPricePerPlan(price: (Double(truncating: product.price)/12), product: product, plan: "/" + plans[0], isLifeTime: false, period: "Month")
                }
                
                if indexPath.item == selectedPlan {
                    cell.imgRadio.image = NSImage(resource: ImageResource.imgRadioSelected)
                    cell.viewContainer.borderColor = NSColor.primary1
                    cell.viewContainer.borderWidth = 2
                    if product.introductoryPrice != nil {
                        //will use later
                        self.btnContinue.title = "Start For Free"
                        self.setupUnlimitedFreeAccessLbl(product: product)
                    } else {
                        //will use later
                        self.btnContinue.title = "C O N T I N U E"
                        self.setupDiscountPriceLbl(product: product)
                    }
                    
                }else{
                    cell.imgRadio.image = NSImage(resource: ImageResource.imgRadio)
                    cell.viewContainer.borderColor = NSColor.white3
                    cell.viewContainer.borderWidth = 1
                }
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let index = indexPaths.first else{ return}
        selectedPlan = index.item
        collectionPayment.reloadData()
    }
}
// MARK: - @objc Methods
extension ProPaymentVC {

    // Retrieve product information from StoreKit
    func retriveProducts() {
        if appDelegate.products.count > 0 && appDelegate.products.count == subscriptionPlanList.count {
            self.collectionPayment.reloadData()
        } else {
            Utility.showHud(controller: self.view.window?.contentViewController?.view ?? NSView())
            //(controller: self, title: "", subtitle: "")
            SwiftyStoreKit.retrieveProductsInfo(appDelegate.subScriptionsOffers) { [weak self] result in
                guard let self = self else { return }
                let products = result.retrievedProducts
                if products.count > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                        Utility.hideHud()
                    }
                    appDelegate.products = products
                    collectionPayment.reloadData()
                }
            }
        }
    }

    // Check if the user has purchased premium
    @objc func checkPremium() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            guard let self = self else { return }
            if isPremiumUser() {
                dismiss(nil)
            }
        }
    }
    
}

// MARK: - StoreKit Helper Methods
extension ProPaymentVC {

    // Get product from StoreKit based on product identifier
    func getProductFromStore(productID: String) -> SKProduct? {
        return appDelegate.products.first { $0.productIdentifier == productID }
    }

    // Convert price per plan with appropriate format and currency
    func convertPricePerPlan(price: Double, product: SKProduct, plan: String, isLifeTime: Bool, period: String) -> NSMutableAttributedString {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        let tempPrice = numberFormatter.string(from: NSNumber(value: price)) ?? ""
        //let attributeString = NSMutableAttributedString(string: "\(tempPrice) per week")
        let attributeString = NSMutableAttributedString(string: "\(tempPrice)/\(period)")
        if isLifeTime {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.appRed, range: NSMakeRange(0, attributeString.length))
        }
        return attributeString
    }

    // Calculate the percentage discount for subscription plans
    func getPercentageOffOnPlan(basePrice: Double, discountPrice: Double, for duration: PlanType) -> Int {
        if duration == .Yearly {
            return Int(100 - (discountPrice / (basePrice * 52)) * 100)
        }
        if duration == .Monthly {
            return Int(100 - (discountPrice / (basePrice * 4)) * 100)
        }
        return 0
    }

    // Configure the label for free trial and subscription pricing
    func setupUnlimitedFreeAccessLbl(product: SKProduct) {
        var subscriptionType = ""
        switch product.productIdentifier {
        case weeklySubscription:
            subscriptionType = "week"
        case monthlySubscription:
            subscriptionType = "month"
        case yearlySubscription:
            subscriptionType = "year"
        default:
            break
        }

        let priceString = product.localizedPrice ?? "$0.00"
        let subscriptionPeriod = "per" + " \(subscriptionType)"

        let firstString = NSMutableAttributedString(string: "Try Free For 3 Days,", attributes: [.foregroundColor: NSColor.labelColor])
        let secondString = NSAttributedString(string: " then" + " \(priceString) \(subscriptionPeriod)", attributes: [.foregroundColor: NSColor.labelColor])

        firstString.append(secondString)
        //will use later
        lblFreeTrial.attributedStringValue = firstString
    }
    
    func setupDiscountPriceLbl(product: SKProduct) {
        
        var subscriptionType = ""
        switch product.productIdentifier {
        case weeklySubscription:
            subscriptionType = "week"
        case monthlySubscription:
            subscriptionType = "month"
        case yearlySubscription:
            subscriptionType = "year"
        default:
            break
        }
        
        if let baseProduct = getProductFromStore(productID: self.subscriptionPlanList.first!){
            
            let priceString = product.localizedPrice ?? "$0.00"
            let subscriptionPeriod = "per" + " \(subscriptionType)"
            
            var plan:PlanType = .Weekly
            if selectedPlan == 0{
                plan = .Weekly
                //let discountInPercentage = self.getPercentageOffOnPlan(basePrice: Double(truncating: baseProduct.price), discountPrice: Double(truncating: product.price), for: plan)
                let strOff = "45% Off,"
                
                let firstString = NSMutableAttributedString(string: strOff, attributes: [.foregroundColor: NSColor.labelColor])
                let secondString = NSAttributedString(string: " then" + " \(priceString) \(subscriptionPeriod)", attributes: [.foregroundColor: NSColor.labelColor])
                
                firstString.append(secondString)
                self.lblFreeTrial.attributedStringValue = firstString
                
            }
            if selectedPlan == 2{
                plan = .Yearly
                let discountInPercentage = self.getPercentageOffOnPlan(basePrice: Double(truncating: baseProduct.price), discountPrice: Double(truncating: product.price), for: plan)
                let strOff = "Save" + " "  + "\(Int(discountInPercentage))%,"
                
                let firstString = NSMutableAttributedString(string: strOff, attributes: [.foregroundColor: NSColor.labelColor])
                let secondString = NSAttributedString(string: " then" + " \(priceString) \(subscriptionPeriod)", attributes: [.foregroundColor: NSColor.labelColor])
                
                firstString.append(secondString)
                self.lblFreeTrial.attributedStringValue = firstString
                
            }
        }
    }

    // Purchase a subscription plan
    func buyPlan(product: SKProduct){
        SwiftyStoreKit.purchaseProduct(product.productIdentifier, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                    Utility.hideHud()
                }
                ud.set(true, forKey: PREMIUM_USER)
                NotificationCenter.default.post(name: .PremiumPurchasedSuccessed, object: nil)
            case .error(let error):
                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                    Utility.hideHud()
                }
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
                //Utility.showAlert(caller: self, title: "Error", message: "Could not complete the process")
                //let alert = showAlert(title: alertTitleError, message: "Could not complete the process")
                //self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                    Utility.dialogWithMsg(message: "Could not complete the process", window: self?.view.window ?? NSWindow())
                }
            case .restored(purchase: let purchase):
                DispatchQueue.main.async {
                    Utility.hideHud()
                    if purchase.productId == product.productIdentifier{
                        ud.set(true, forKey: PREMIUM_USER)
                        //Utility.showAlert(caller: self, title: "Congratulation", message: "You have purchased Successfully")
                        //let alert = showAlert(title: alertTitleCongratulation, message: "You have purchased Successfully")
                        //self.present(alert, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                            Utility.dialogWithMsg(message: "You have purchased Successfully", window: self?.view.window ?? NSWindow())
                        }
                        NotificationCenter.default.post(name: .PremiumPurchasedSuccessed, object: nil)
                        //will use later
                        //NotificationCenter.default.post(name: .PremiumScreenDismissed, object: nil)
                    }
                }
                break
            }
        }
    }

    // Restore purchases for the user
    func restorePurchase(){
        Utility.showHud(controller: self.view.window?.contentViewController?.view ?? NSView())
        SwiftyStoreKit.restorePurchases {[weak self](results) in
            guard let self = self else {return}
            if results.restoredPurchases.count > 0 {
                DispatchQueue.main.async{
                    Utility.hideHud()
                }
                let restoredPurchases = results.restoredPurchases
                //will use in future
                //let filteredRestorePurchaes = restoredPurchases.unique{$0.productId}
                ud.set(true, forKey: PREMIUM_USER)
                NotificationCenter.default.post(name: .PremiumPurchasedSuccessed, object: nil)
                //will use later
                //NotificationCenter.default.post(name: .PremiumScreenDismissed, object: nil)
            }else if results.restoreFailedPurchases.count > 0 {
                DispatchQueue.main.async{
                    Utility.hideHud()
                }
                //Utility.showAlert(caller: self, title: "Error", message: "Restore Failed")
                //let alert = showAlert(title: alertTitleError, message: "Restore Failed")
                //self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.async{
                    Utility.dialogWithMsg(message: "Restore Failed", window: self.view.window ?? NSWindow())
                }
                ud.set(false, forKey: PREMIUM_USER)
            }else{
                DispatchQueue.main.async{
                    Utility.hideHud()
                }
                //Utility.showAlert(caller: self, title: "Error", message: "Nothing to Restore")
                //let alert = showAlert(title: alertTitleError, message: "Nothing to Restore")
                //self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.async{
                    Utility.dialogWithMsg(message: "Nothing to Restore", window: self.view.window ?? NSWindow())
                }
                ud.set(false, forKey: PREMIUM_USER)
            }
        }
    }
}
