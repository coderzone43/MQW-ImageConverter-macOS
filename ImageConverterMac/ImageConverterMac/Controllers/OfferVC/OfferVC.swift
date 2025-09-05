//
//  OfferVC.swift
//  ImageConverterMac
//
//  Created by MacBook Pro on 05/09/2025.
//

import Cocoa
import StoreKit

class OfferVC: NSViewController {

    //MARK: Outlets
    @IBOutlet weak var btnClose: NSButton!
    @IBOutlet weak var lblInfo: NSTextField!
    @IBOutlet weak var lblInfo2: NSTextField!
    @IBOutlet weak var viewSeperatorContinueFree: NSView!
    @IBOutlet weak var btnContinueFree: NSButton!
    @IBOutlet weak var lblTimer: NSTextField!
    @IBOutlet weak var lblOfferDetail: NSTextField!
    @IBOutlet weak var lblPerDayPrice: NSTextField!
    
    var currentSelectedProduct: SKProduct?
    var selectedPlan = 0
    var plans = ["Weekly", "Monthly", "Yearly"]
    var subscriptionPlanList: [String] = [yearlyOfferSubscription]
    
    let timeDifferent = 599
    var timeEnd = Date()
    var curentData = Double()
    
    //MARK: View Life Cycle Start here...
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupView()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        ud.set(curentData, forKey: strCurrentTimeForOfferScreen)
    }
    
    //MARK: Setup View
    func setupView() {
        setupLabels()
        setupNotificationObservers()
        setUpTimer()
        retriveProducts()
    }
    
    //MARK: Utility Methods
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkPremium), name: .PremiumPurchasedSuccessed, object: nil)
    }
    
    func setAttributedString(text: String, font: NSFont, color: NSColor) -> NSAttributedString {
        let attributedString: NSAttributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
        return attributedString
    }
    
    func setupLabels() {
        let attrStr1 = NSMutableAttributedString()
        attrStr1.append(self.setAttributedString(text: "Upgrade with" + " ", font: NSFont.systemFont(ofSize: 32, weight: .bold), color: .black1))
        attrStr1.append(self.setAttributedString(text: "50%", font: NSFont.systemFont(ofSize: 38, weight: .heavy), color: .primary1 ))
        self.lblInfo.attributedStringValue = attrStr1
        
        let attrStr2 = NSMutableAttributedString()
        attrStr2.append(self.setAttributedString(text: "off your first year", font: NSFont.systemFont(ofSize: 32, weight: .bold), color: .black1))
        self.lblInfo2.attributedStringValue = attrStr2
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
extension OfferVC{
    // MARK: - Time Function
    func setUpTimer() {
        if let OldDate = ud.object(forKey: strCurrentTimeForOfferScreen){
            let oldDate = floor(OldDate as! Double)
            if oldDate == 0 {
                timeEnd = Date(timeIntervalSinceNow:TimeInterval((timeDifferent)))
            }else{
                timeEnd = Date(timeIntervalSinceNow:(OldDate) as! TimeInterval)
            }
        }else{
            timeEnd = Date(timeIntervalSinceNow:TimeInterval((timeDifferent)))
        }
        
        setupTimeLabel()
        
        // Start timer
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.setupTimeLabel), userInfo: nil, repeats: true)
    }
    
    
    @objc func setupTimeLabel() {
        let timeNow = Date()
        if timeEnd.compare(timeNow) == ComparisonResult.orderedDescending {
            let interval = timeEnd.timeIntervalSince(timeNow)
            let minutes = Int(interval / 60) // Extracting minutes from the interval
            let seconds = Int(interval.truncatingRemainder(dividingBy: 60)) // Extracting seconds
            
            // Format the minutes and seconds into "6 : 23" format
            let timeString = "\(minutes) : \(String(format: "%02d", seconds))"
            
            // Display the formatted time
            lblTimer.stringValue = timeString
            
            // Change the time to 9:30:00 in your locale
            curentData = interval
        }
    }
}
extension OfferVC {

    // Retrieve product information from StoreKit
    func retriveProducts() {
        if appDelegate.products.count > 0 && appDelegate.products.count == subscriptionPlanList.count {
            self.setupYearlyPlanView()
        } else {
            Utility.showHud(controller: self.view.window?.contentViewController?.view ?? NSView())
            SwiftyStoreKit.retrieveProductsInfo(appDelegate.subScriptionsOffers) { [weak self] result in
                guard let self = self else { return }
                let products = result.retrievedProducts
                if products.count > 0 {
                    Utility.hideHud()
                    appDelegate.products = products
                    self.setupYearlyPlanView()
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
extension OfferVC {

    // Get product from StoreKit based on product identifier
    func getProductFromStore(productID: String) -> SKProduct? {
        return appDelegate.products.first { $0.productIdentifier == productID }
    }

    // Convert price per plan with appropriate format and currency
    func convertPricePerPlan(price: Double, product: SKProduct, plan: String, isLifeTime: Bool) -> NSMutableAttributedString {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        let tempPrice = numberFormatter.string(from: NSNumber(value: price)) ?? ""
        let attributeString = NSMutableAttributedString(string: "\(tempPrice)\(plan)")
        if isLifeTime {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        }
        return attributeString
    }

    // Calculate the percentage discount for subscription plans
    func getPercentageOffOnPlan(basePrice: Double, discountPrice: Double, for duration: PlanType) -> Int {
        if duration == .Yearly {
            return Int(100 - (discountPrice / (basePrice * 52)) * 100)
        } else if duration == .Monthly {
            return Int(100 - (discountPrice / (basePrice * 4)) * 100)
        }
        return 0
    }
    
    func setupYearlyPlanView(){
        if Utility.isNetworkAvailable() {
            if appDelegate.products.count > 0 {
                if let prod = self.getProductFromStore(productID: subscriptionPlanList[0]) {
                    let localizedPrice = prod.localizedPrice ?? ""
                    var localizedIntroPrice = ""

                    if let discount = prod.introductoryPrice {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .currency
                        formatter.locale = discount.priceLocale
                        localizedIntroPrice = formatter.string(from: discount.price) ?? ""
                    }

                    let attributedString = NSMutableAttributedString()
                    attributedString.append(NSAttributedString(
                        string: "only".localized() + " " + localizedIntroPrice + " " + "for 1 year, then".localized() + " " + localizedPrice + " " + "per".localized() + " " + "year".localized()
                    ))



                    lblOfferDetail.attributedStringValue = attributedString

                    lblPerDayPrice.attributedStringValue = priceWithOff(
                        originalPrice: Double(truncating: prod.introductoryPrice?.price ?? 0) / 365,
                        product: prod,
                        line: false
                    )

                    /* Uncomment and use if needed
                    if prod.introductoryPrice != nil {
                        tryForFreeLabel.text = "Start For Free".localized()
                    } else {
                        tryForFreeLabel.text = "C O N T I N U E".localized()
                    }
                    */
                }

            }
        }
    }
    
    func priceWithOff(originalPrice : Double, product: SKProduct, line: Bool) -> NSAttributedString {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        let tempPrice = numberFormatter.string(from: NSNumber(value: originalPrice)) ?? ""
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: String("\(tempPrice)"))
        if line{
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0,attributeString.length))
        }else{
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0,0))
        }
        return attributeString
    }
    
    func getOrignalPrice(offPrice:Double, percentageOff:Double) ->Double{
        let onePercentPrice = offPrice/percentageOff
        let oneHundredrPercentage = Double(100)
        return onePercentPrice*oneHundredrPercentage
        
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
}
