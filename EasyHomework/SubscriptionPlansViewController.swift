//
//  SubscriptionPlansViewController.swift
//  B4Grad
//
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyStoreKit
import Parse
import XCDYouTubeKit
import AVKit

class ProductPlan: NSObject {
    var productIdentifier:String?
    var productPrice:String?
    var productDuration:String?
    var freeTrial:String?
}

var products = ["com.b4grad.yearlySubscription","com.b4grad.monthlySubscription","com.b4grad.weekly", "com.b4grad.onetime"]

class SubscriptionPlansViewController: UIViewController, UITextViewDelegate, AVPlayerViewControllerDelegate {

    private var plans:Array<ProductPlan> = []
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var yearlyPlanPurchaseButton: UIButton! {
        didSet {
            yearlyPlanPurchaseButton.isSelected = true
        }
    }
    @IBOutlet weak var gradcapLabel: UILabel!
    @IBOutlet weak var monthlyPlanPurchaseButton: UIButton!
    @IBOutlet weak var weeklyPlanPurchaseButton: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    @IBOutlet var buttons: Array<RoundEdgedButton>!
    @IBOutlet weak var txtDisclamer: UITextView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var headlineLabel: UILabel!
    private var progressIndicator:MBProgressHUD?
    private let privacyURL = "http://www.privacy.com"
    private let EULAURL = "http://www.eula.com"
    var completionCallback:((Bool)->())?
    var customHeadlineText: String?
    @IBOutlet var bannerImageView: UIImageView!
    var selectedPlanTag = 0
    @IBOutlet var referralButton: UIButton!
    @IBOutlet var videoPlayer: AVPlayer!
    @IBOutlet var playImageView: UIImageView!
    
    @IBOutlet var countdownLabel: UILabel!
    var countdownTimer: Timer?
    var startingSeconds = 0
    
    private func presentAlertController(alertTitle: String, alertMessage:String, alertActions:Array<UIAlertAction>) -> UIAlertController {
        let alertController:UIAlertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        for action:UIAlertAction in alertActions {
            alertController.addAction(action)
        }
        return alertController
    }
    
    @objc func finishRestorePurchase() {
    }
    
    @objc func purchaseFailed() {
        self.hideActivityIndicator()
    }
    
    private func getProductPriceFrom(product:SKProduct) -> String?{
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        let formattedPrice = numberFormatter.string(from: product.price)
        return formattedPrice
    }
    
    @IBAction func referralBtnTouchUpInside(_ sender: Any) {
        if (PFUser.current()?.email == "" || PFUser.current()?.email == nil) {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpTableViewController") as! SignUpTableViewController
            self.show(signUpVC, sender: self)
            let alert = UIAlertController(title: "!!!",
                                         message: "Please Sign Up or Login to Reveal the Surprise!",
                                         preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            signUpVC.present(alert, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let rewardsVC = storyboard.instantiateViewController(withIdentifier: "RewardsViewController") as! RewardsViewController
            self.show(rewardsVC, sender: self)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (customHeadlineText != nil) {
            self.headlineLabel.text = customHeadlineText
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UserDefaults.standard.set(self.startingSeconds, forKey: "TimeIntervalSinceTimerLastSeen")
        UserDefaults.standard.set(Date()?.timeIntervalSinceReferenceDate, forKey: "DateSinceTimerLastSeen")
        
        self.countdownTimer?.invalidate()
        self.timer?.invalidate()
    }
    
    var countdownExpired = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let timerExpired = UserDefaults.standard.bool(forKey: "TimerExpired")
        if (timerExpired == true) {
            self.countdownLabel.text = "To Help Assist Students at this Time, we have Extended Our Discount Period beyond 24 Hours. 🙂"
            //return
        }
        
        if (self.countdownTimer == nil && timerExpired == false) {
            self.startingSeconds = 86400 //30
            if (UserDefaults.standard.integer(forKey: "TimeIntervalSinceTimerLastSeen") != nil && UserDefaults.standard.integer(forKey: "TimeIntervalSinceTimerLastSeen") > 0) {
                self.startingSeconds = UserDefaults.standard.integer(forKey: "TimeIntervalSinceTimerLastSeen")
                
                if (UserDefaults.standard.integer(forKey: "DateSinceTimerLastSeen") != nil && UserDefaults.standard.integer(forKey: "DateSinceTimerLastSeen") > 0) {
                    let difference: Int = Int(Date().timeIntervalSinceReferenceDate) - Int(Date(timeIntervalSinceReferenceDate: TimeInterval(UserDefaults.standard.integer(forKey: "DateSinceTimerLastSeen"))).timeIntervalSinceReferenceDate)
                    self.startingSeconds -= Int(difference)
                    UserDefaults.standard.set(self.startingSeconds, forKey: "TimeIntervalSinceTimerLastSeen")
                    if (self.startingSeconds <= 0) { self.startingSeconds = 0; UserDefaults.standard.set(true, forKey: "TimerExpired") }
                }
            }
            
            self.countdownLabel.text = "Only \(self.timeString(time: TimeInterval(self.startingSeconds))) Hours until your Discount Offer Expires."
            self.countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
            RunLoop.main.add(self.countdownTimer!, forMode: RunLoopMode.commonModes)
            
        }
        
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { timer in
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [UIViewAnimationOptions.curveEaseOut], animations: { self.yearlyPlanPurchaseButton.transform = CGAffineTransform(scaleX: 1.03, y: 1.03); }, completion: {
        finished in
                UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.yearlyPlanPurchaseButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97) }, completion: {
            finished in
                    UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.yearlyPlanPurchaseButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) }, completion: { finished in
            })
            })
        })
        }
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.commonModes)
        
    }
    var timer: Timer?
    
    @objc func updateTimer() {
        if (countdownExpired) {
            UserDefaults.standard.set(0, forKey: "TimeIntervalSinceTimerLastSeen")
            self.countdownLabel.text = "To Help Assist Students at this Time, we have Extended Our Discount Period beyond 24 Hours. 🙂"
            UserDefaults.standard.set(true, forKey: "TimerExpired")
            return
        }
        if (startingSeconds >= 1) {
            self.startingSeconds -= 1     //This will decrement (count down) the seconds.
            //Save in NSUserDefaults the date (or TimeInterval) since the timer was last modified.
            UserDefaults.standard.set(self.startingSeconds, forKey: "TimeIntervalSinceTimerLastSeen")
            self.countdownLabel.text = "Only \(self.timeString(time: TimeInterval(self.startingSeconds))) Hours until your Discount Offer Expires." //This will update the label.
        } else {
            UserDefaults.standard.set(0, forKey: "TimeIntervalSinceTimerLastSeen")
            self.countdownLabel.text = "To Help Assist Students at this Time, we have Extended Our Discount Period beyond 24 Hours. 🙂"
            UserDefaults.standard.set(true, forKey: "TimerExpired")
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
    }
    
    @objc func productsFromItunes(notification:Notification) {
        let products:Array<SKProduct>? = notification.object as? Array<SKProduct>
        DispatchQueue.main.async {
            if let _products = products, _products.isEmpty == false {
                for plan in self.plans{
                    for product in _products {
                        if plan.productIdentifier == product.productIdentifier {
                            plan.productPrice = self.getProductPriceFrom(product: product)
                            if #available(iOS 11.2, *),
                                let period = product.introductoryPrice?.subscriptionPeriod {
                                if let desc = period.unit.description(capitalizeFirstLetter: false, numberOfUnits: period.numberOfUnits) {
                                    plan.freeTrial = desc
                                }
                            }
                            self.updateButtonText(productDuration: plan.productDuration, productPrice: plan.productPrice, freeTrialDuration: plan.freeTrial)
                        }
                    }
                }
            }
            self.hideButtonActivityIndicator()
            self.scrollView.isHidden = false
            self.updateDisclamerText(with: self.plans[0].productDuration ?? "", priceValue: self.plans[0].productPrice ?? "", freeTrial: self.plans[0].freeTrial)
        }
    }
    
    private func hideButtonActivityIndicator(){
        for button in buttons {
            button.activityView?.stopAnimating()
            button.activityView?.removeFromSuperview()
        }
    }
    
    private func updateButtonText(productDuration:String?, productPrice:String?, freeTrialDuration:String?) {
        if productDuration == "year" {
            if let _freeTrialDuration = freeTrialDuration {
                self.yearlyPlanPurchaseButton.setTitle("   \(_freeTrialDuration) FREE, then \(productPrice ?? "$29.99")", for: .normal)
                self.yearlyPlanPurchaseButton.setTitle("   \(_freeTrialDuration) FREE, then \(productPrice ?? "$29.99")", for: .selected)
            }
            else {
                self.yearlyPlanPurchaseButton.setTitle("   \(productPrice ?? "$29.99")/\(productDuration ?? "year")", for: .normal)
                self.yearlyPlanPurchaseButton.setTitle("   \(productPrice ?? "$29.99")/\(productDuration ?? "year")", for: .selected)
            }
        }
        else if productDuration == "month" {
            if let _freeTrialDuration = freeTrialDuration {
                self.monthlyPlanPurchaseButton.setTitle("   \(productPrice ?? "$9.99")/\(productDuration ?? "month") after \(_freeTrialDuration) free trial", for: .normal)
                self.monthlyPlanPurchaseButton.setTitle("   \(productPrice ?? "$9.99")/\(productDuration ?? "month") after \(_freeTrialDuration) free trial", for: .selected)
            }
            else {
                self.monthlyPlanPurchaseButton.setTitle("   \(productPrice ?? "$9.99")/\(productDuration ?? "month")", for: .normal)
                self.monthlyPlanPurchaseButton.setTitle("   \(productPrice ?? "$9.99")/\(productDuration ?? "month")", for: .selected)
            }
        }
        else if productDuration == "week" {
            if let _freeTrialDuration = freeTrialDuration {
                self.weeklyPlanPurchaseButton.setTitle("   \(productPrice ?? "$2.99")/\(productDuration ?? "week") after \(_freeTrialDuration) free trial", for: .normal)
                self.weeklyPlanPurchaseButton.setTitle("   \(productPrice ?? "$2.99")/\(productDuration ?? "week") after \(_freeTrialDuration) free trial", for: .selected)
            }
            else {
                self.weeklyPlanPurchaseButton.setTitle("   \(productPrice ?? "$2.99")/\(productDuration ?? "week")", for: .normal)
                self.weeklyPlanPurchaseButton.setTitle("   \(productPrice ?? "$2.99")/\(productDuration ?? "week")", for: .selected)
            }
        }
        else if productDuration == "keep forever" {
            if let _freeTrialDuration = freeTrialDuration {
                self.weeklyPlanPurchaseButton.setTitle("   \(productPrice ?? "$2.99")/\(productDuration ?? "One-Time")", for: .normal)
                self.weeklyPlanPurchaseButton.setTitle("   \(productPrice ?? "$2.99")/\(productDuration ?? "One-Time")", for: .selected)
            }
            else {
                self.weeklyPlanPurchaseButton.setTitle("   \(productPrice ?? "$2.99")/\(productDuration ?? "One-Time")", for: .normal)
                self.weeklyPlanPurchaseButton.setTitle("   \(productPrice ?? "$2.99")/\(productDuration ?? "One-Time")", for: .selected)
            }
        }
        
        if (calculationCompleted == false) {
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .currency
            currencyFormatter.locale = Locale.current
            var yearlyDividedBy12: Double?
            var yearlyDividedBy12Number: NSNumber?
            var yearlyDividedBy12String: String?
            if (productPrice != nil) {
                yearlyDividedBy12Number = currencyFormatter.number(from: productPrice!)
                if (yearlyDividedBy12Number != nil) {
                    yearlyDividedBy12 = yearlyDividedBy12Number!.doubleValue / 12
                    yearlyDividedBy12Number = NSNumber(value: yearlyDividedBy12!)
                    yearlyDividedBy12String = currencyFormatter.string(from: yearlyDividedBy12Number!)
                }
            }
            self.gradcapLabel.text = "The yearly plan is only \(yearlyDividedBy12String ?? "$1.65")/ per month!"
            self.calculationCompleted = true
        }
    }
    
    var calculationCompleted = false
    
    
    @objc func iTunesConnectErrorNotification(notification:Notification) {
        self.hideActivityIndicator()
        let okAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
        }
        let userInfo:Dictionary<String, Any>? = notification.userInfo as? Dictionary<String, Any>
        var errorMessage = "Unable to connect to iTunes Store"
        if userInfo != nil {
            if let notificationErrorMessage = userInfo!["errorMessage"] as? String {
                errorMessage = notificationErrorMessage
            }
        }
        let iTunesConnectErrorAlert:UIAlertController = self.presentAlertController(alertTitle: "", alertMessage: errorMessage, alertActions: [okAction])
        self.present(iTunesConnectErrorAlert, animated: true, completion: nil)
    }
    
    @objc func restorePurchaseFailed() {
        self.hideActivityIndicator()
        let okAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
        }
        let failedRestorePurchaseAlert:UIAlertController = self.presentAlertController(alertTitle: "Restore Purchase", alertMessage: "Unable to restore your purchase this time. Please make sure you are using same Apple ID that was used while purchase. If still facing issues, please contact Apple.", alertActions: [okAction])
        self.present(failedRestorePurchaseAlert, animated: true, completion: nil)
    }
    
    @objc func processPurchaseCompletionCallbackData(notification:Notification) {
        let userInfoDict:Dictionary<String, Any>? = notification.userInfo as? Dictionary<String, Any>
        if userInfoDict != nil {
            let isSuccessFullyPurchased:Bool? = userInfoDict?["success"] as? Bool
            if isSuccessFullyPurchased != nil && isSuccessFullyPurchased! {
                StoreKitManager.shared.updateTransactionInfoWithUser(response: { (isSuccess) in
                    self.hideActivityIndicator()
                    DispatchQueue.main.async {
                        if isSuccess == true {
                            
                            //Local verification (code below) also occurs in TransactionPurchased/PurchaseRestoration!
                            let receiptHandler = ReceiptHandler()
                            let price = self.plans[self.selectedPlanTag].productPrice
                            receiptHandler.productPrice = self.priceStringToDecimalNumber(productPrice: price)
                            receiptHandler.isInitialPurchase = true
                            receiptHandler.handleAppReceipt()
                            
                            self.dismissViewControllers()
                            
                            let alertViewController = UIAlertController(title: "Thank You",
                                                                        message: "Please restart the app or your device for the best experience. You may also email us at contact@b4grad.com for any further questions. Enjoy!",
                                                                        preferredStyle: .alert)
                            let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                                alertViewController.dismiss(animated: true, completion: nil)
                            })
                            alertViewController.addAction(okButton)
                            self.view.window!.rootViewController?.present(alertViewController, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    func dismissViewControllers() {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func showAlert(notification:NSNotification) {
        let userInfoDict:Dictionary<String, Any> = notification.userInfo as! Dictionary<String, Any>
        let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
            self.hideActivityIndicator()
        }
        let paymentErrorAlert:UIAlertController = self.presentAlertController(alertTitle: userInfoDict["title"] as? String ?? "", alertMessage: userInfoDict["message"] as? String ?? "", alertActions: [okAction])
        self.present(paymentErrorAlert, animated: true, completion: nil)
    }

    @objc  func showProgressPaymentProcess() {
    }
    
    private func fecthProductFromItunes(){
        self.scrollView.isHidden = false
        StoreKitManager.shared.validateProductIdentifiers(products)
    }
    
    @objc func processRestorePurchaseCompetionCallbackData(notification:NSNotification) {
        StoreKitManager.shared.updateTransactionInfoWithUser(response: { (isSuccess) in
            self.hideActivityIndicator()
            DispatchQueue.main.async {
                if isSuccess == true {
                    //Local verification (code below) also occurs in TransactionPurchased/PurchaseRestoration!
                    let receiptHandler = ReceiptHandler()
                    receiptHandler.handleAppReceipt()
                    
                    self.dismissViewControllers()
                }
            }
        })
    }
    
    @objc func processRestoreWithZeroTransactionCallbackData(notification:NSNotification) {
        self.hideActivityIndicator()
        let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
        }
        let restorePurchaseErrorAlert:UIAlertController = self.presentAlertController(alertTitle: "No Purchase Found", alertMessage: "We were unable to find a previous transaction on your iTunes account. Please check your iTunes credentials and try again.", alertActions: [okAction])
        self.present(restorePurchaseErrorAlert, animated: true, completion: nil)
    }
    
    private func addNotificationObserver (){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRestorePurchaseCompletionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishRestorePurchase), name: NSNotification.Name(rawValue: kRestorePurchaseCompletionNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPurchaseFailedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(purchaseFailed), name: NSNotification.Name(rawValue: kPurchaseFailedNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kiTunesConnectErrorNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(iTunesConnectErrorNotification), name: NSNotification.Name(rawValue: kiTunesConnectErrorNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kRestorePurchaseFailedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restorePurchaseFailed), name: NSNotification.Name(rawValue: kRestorePurchaseFailedNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPurchaseCompletionNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processPurchaseCompletionCallbackData(notification:)), name: NSNotification.Name(rawValue: kPurchaseCompletionNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPurchaseInProcessNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showProgressPaymentProcess), name: NSNotification.Name(rawValue: kPurchaseInProcessNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kShowAlertNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert(notification:)), name: NSNotification.Name(rawValue: kShowAlertNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPurchaseRestoreNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processRestorePurchaseCompetionCallbackData(notification:)), name: NSNotification.Name(rawValue: kPurchaseRestoreNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPurchaseRestoreWithZeroTransaction), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processRestoreWithZeroTransactionCallbackData(notification:)), name: NSNotification.Name(rawValue: kPurchaseRestoreWithZeroTransaction), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kGetProductsFromItunes), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(productsFromItunes(notification:)), name: NSNotification.Name(rawValue: kGetProductsFromItunes), object: nil)
    }
    
    private func fillPlanArray() {
        let plan1 = ProductPlan.init()
        plan1.productIdentifier = "com.b4grad.yearlySubscription"
        plan1.productDuration = "year"
        //          //
        //Locale.current.regionCode == "GB"
        if (UserDefaults.standard.bool(forKey: "HasDiscount") == true) {
            products[0] = "com.b4grad.yearlyDiscountSubscription"
            plan1.productIdentifier = "com.b4grad.yearlyDiscountSubscription"
            plan1.productDuration = "year"
        }
        //Testing $19.99 Price
        products[0] = "com.b4grad.yearlyDiscountSubscription"
        plan1.productIdentifier = "com.b4grad.yearlyDiscountSubscription"
        plan1.productDuration = "year"
        //          //
        plans.append(plan1)
        let plan2 = ProductPlan.init()
        plan2.productIdentifier = "com.b4grad.monthlySubscription"
        plan2.productDuration = "month"
        plans.append(plan2)
        let plan3 = ProductPlan.init()
        plan3.productIdentifier = "com.b4grad.onetime"
        plan3.productDuration = "keep forever"
        plans.append(plan3)
        /*plan3.productIdentifier = "com.b4grad.weekly"
        plan3.productDuration = "week"
        plans.append(plan3)*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNotificationObserver()
        self.fillPlanArray()
        self.fecthProductFromItunes()
        
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        if let completion = self.completionCallback {
            completion(true) //send purchase information if required.
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func restorePurchaseAction(_ sender: Any) {
        let okAction:UIAlertAction = UIAlertAction(title: "OK", style: .default) { (okAction) in
            self.showActivityIndicator(with:"Restoring your purchase")
            /*StoreKitManager.shared.isProductPurchased = false
            StoreKitManager.shared.restorePreviousTransaction()*/
            SwiftyStoreKit.restorePurchases(atomically: true) { results in
                if results.restoreFailedPurchases.count > 0 {
                    print("Restore Failed: \(results.restoreFailedPurchases)")
                    self.hideActivityIndicator()
                }
                else if results.restoredPurchases.count > 0 {
                    print("Restore Success: \(results.restoredPurchases)")
                    let receiptHandler = ReceiptHandler()
                    receiptHandler.handleAppReceipt()
                    self.hideActivityIndicator()
                }
                else {
                    print("Nothing to Restore")
                    self.hideActivityIndicator()
                }
            }
        }
        let cancelction:UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelction) in
        }
        let paymentErrorAlert:UIAlertController = self.presentAlertController(alertTitle: "Restore Purchase", alertMessage: "By restoring your purchase with this account, it will immediately be removed on any other active account. Please try to login to your other account first if you remember the account credentials. Would you like to continue with the restoration or cancel?", alertActions: [cancelction, okAction])
        self.present(paymentErrorAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func buttonAction(_ sender: RoundEdgedButton) {
        if sender.tag >= 0 && sender.tag < plans.count {
            self.selectedPlanTag = sender.tag
            if sender.isSelected {
                makePurchase(with: plans[sender.tag].productIdentifier ?? "")
            } else {
                for button in buttons {
                    button.isSelected = false
                }
                self.updateDisclamerText(with: plans[sender.tag].productDuration ?? "", priceValue: plans[sender.tag].productPrice ?? "", freeTrial: plans[sender.tag].freeTrial)
                sender.isSelected = true
            }
        } else {
            assertionFailure("Plan button tag is bigger than the plans' count. Check sender tag")
        }
    }
    
    private func showActivityIndicator(with loaderText:String?) {
        progressIndicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        if loaderText != nil {
            progressIndicator?.label.text = loaderText!
        }
    }
    
    private func hideActivityIndicator() {
        progressIndicator?.hide(animated: true)
    }

    private func makePurchase(with planIdentifier:String) {
        self.showActivityIndicator(with: "Processing your payment")
        StoreKitManager.shared.fetchAvailableProductsForProdcutIdentifier(pId: planIdentifier)
    }
    
    private func updateDisclamerText(with priceDuration:String ,priceValue:String, freeTrial:String?){
        var freeTrialText = ""
        if let _freeTrial = freeTrial {
            freeTrialText = "After \(_freeTrial) free trial this subscription"
        }
        else {
            freeTrialText = "This subscription"
        }
        let string = "\(freeTrialText) automatically renews for \(priceValue) until you turn it off. This trial automatically renews into a paid subscription and will continue to automatically renew until you cancel. You may cancel any time, however you must cancel at least 24 hours before the end of the trial or any subscription period to avoid being charged. Any unused portion of a trial period shall be forfeited. You can manage and cancel your subscription by going to your account settings on the App Store after purchase. For more information, please see our Privacy Policy and EULA."
        let attributedString = NSMutableAttributedString(string: string)
        let foundRangeOfPrivacyPolicy = attributedString.mutableString.range(of: "Privacy Policy")
        let foundRangeOfEULA = attributedString.mutableString.range(of: "EULA")
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .justified
        attributedString.addAttribute(NSAttributedStringKey.link, value: privacyURL, range: foundRangeOfPrivacyPolicy)
        attributedString.addAttribute(NSAttributedStringKey.link, value: EULAURL, range: foundRangeOfEULA)
        attributedString.addAttributes([NSAttributedStringKey.font : txtDisclamer.font! ,NSAttributedStringKey.foregroundColor : txtDisclamer.textColor!,NSAttributedString.Key.paragraphStyle: paragraph], range: NSRange(location: 0, length: string.count))
        self.txtDisclamer.linkTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue  : txtDisclamer.textColor!,
            NSAttributedString.Key.underlineColor.rawValue: txtDisclamer.textColor!,
            NSAttributedStringKey.underlineStyle.rawValue  : NSUnderlineStyle.styleSingle.rawValue
        ]
        self.txtDisclamer.attributedText = attributedString
    }
    private func openPrivacyPolicyPage(){
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let ppVC = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        self.show(ppVC, sender: nil)
    }
    
    private func openEULAPage(){
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let touVC = storyboard.instantiateViewController(withIdentifier: "TOUViewController") as! TOUViewController
        self.show(touVC, sender: nil)
 
    }
    
    @available(iOS, deprecated: 10.0)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (URL.absoluteString == privacyURL) {
            self.openPrivacyPolicyPage()
        }
        else if (URL.absoluteString == EULAURL) {
            self.openEULAPage()
        }
        return false
    }
    
    //For iOS 10
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if (url.absoluteString == privacyURL) {
            self.openPrivacyPolicyPage()
        }
        else if (url.absoluteString == EULAURL) {
            self.openEULAPage()
        }
        return false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    var playtimeTimer = Timer()
    var appearedOnce = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        //
        if (appearedOnce == false) {
            appearedOnce = true
        
            let playerViewController = AVPlayerViewController()
            var secondsCount = 0
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                secondsCount += 1
                if (secondsCount < 28) {
                    
                } else {
                    timer.invalidate()
                    playerViewController.dismiss(animated: true, completion: nil)
                }
            }
            //timer = Timer.scheduledTimer(timeInterval: 26, target: self, selector: (#selector(countDown)), userInfo: nil, repeats: false)
            if #available(iOS 11.0, *) {
                playerViewController.showsPlaybackControls = false
                playerViewController.exitsFullScreenWhenPlaybackEnds = true
            }
            self.present(playerViewController, animated: true, completion: nil)
            XCDYouTubeClient.default().getVideoWithIdentifier("9SDFThJS1Gw") { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in
                if let streamURL = (video?.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??
                                video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ??
                    video?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ??
                    video?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue]) {
                    playerViewController!.player = AVPlayer(url: streamURL)
                    //playerViewController!.delegate = self
                    playerViewController!.player?.play()
                }// else {
                //    self.dismiss(animated: true, completion: nil)
                //}
            }
        }
        
    }
    
    /*@objc func countDown() {
        self.playtimeTimer.invalidate()
        playerViewController.dismiss(animated: true, completion: nil)
    }*/
    
    /*func playerViewController(
        _ playerViewController: AVPlayerViewController,
        willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
        ) {
        status.insert([.beingDismissed])
        delegate?.playerViewControllerCoordinatorWillDismiss(self)
        
        coordinator.animate(alongsideTransition: nil) { context in
            self.status.remove(.beingDismissed)
            if !context.isCancelled {
                self.status.remove(.fullScreenActive)
            }
        }
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? SubsctionFeaturesViewController {
            pageControl.numberOfPages = vc.subViewControllers.count
            vc.pageChangeCallback = { [weak self] (index) in
                guard let safeSelf = self else { return }
                safeSelf.pageControl.currentPage = index
            }
        }
    }
    
    func priceStringToDecimalNumber(productPrice: String?) -> NSDecimalNumber? {
        if (productPrice == nil) { return nil }
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        var priceNumber: NSNumber?
        var priceDecimalNumber: NSDecimalNumber?
        if (productPrice != nil) {
            priceNumber = currencyFormatter.number(from: productPrice!)
            priceDecimalNumber = NSDecimalNumber(decimal: priceNumber!.decimalValue)
            return priceDecimalNumber
        }
        return nil
    }
    
    
    @IBAction func playButtonTouchDownInside(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.playImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { (finished) in
            UIView.animate(withDuration: 0.4, animations: {
                self.playImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (finished) in }
        }
    }
    
    @IBAction func playButtonTouchUpInside(_ sender: Any) {
        let playerViewController = AVPlayerViewController()
        if #available(iOS 11.0, *) {
            playerViewController.exitsFullScreenWhenPlaybackEnds = true
        }
        self.present(playerViewController, animated: true, completion: nil)
        XCDYouTubeClient.default().getVideoWithIdentifier("9SDFThJS1Gw") { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in
            if let streamURL = (video?.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??
                                video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ??
                video?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ??
                video?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue]) {
                playerViewController!.player = AVPlayer(url: streamURL)
                //playerViewController!.delegate = self
                playerViewController!.player?.play()
            }
        }
    }
    
}

@available(iOS 11.2, *)
extension SKProduct.PeriodUnit {
    func description(capitalizeFirstLetter: Bool = false, numberOfUnits: Int? = nil) -> String? {
        let period:String = {
            switch self {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            }
        }()
        
        var numUnits = ""
        var plural = ""
        if let numberOfUnits = numberOfUnits {
            numUnits = "\(numberOfUnits) " // Add space for formatting
            plural = ""//numberOfUnits > 1 ? "s" : ""
            return "\(numUnits)-\(capitalizeFirstLetter ? period.capitalized : period)\(plural)".replacingOccurrences(of: " ", with: "")
        }
        return nil
    }
}
