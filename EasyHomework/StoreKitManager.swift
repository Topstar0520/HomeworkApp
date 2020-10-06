//
//  StoreKitManager.swift
//  B4Grad
//
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import Foundation
import StoreKit
import Parse

let kShowAlertNotification = "kShowAlertNotification"
let kPurchaseFailedNotification = "kPurchaseFailedNotification"
let kPurchaseCompletionNotification = "kPurchaseCompletionNotification"
let kPurchaseRestoreNotification = "kPurchaseRestoreNotification"
let kRestorePurchaseFailedNotification = "kRestorePurchaseFailedNotification"
let kPurchaseInProcessNotification = "kPurchaseInProcessNotification"
let kRestorePurchaseCompletionNotification = "kRestorePurchaseCompletionNotification"
let kPurchaseRestoreWithZeroTransaction = "kPurchaseRestoreWithZeroTransaction"
let kiTunesConnectErrorNotification = "kiTunesConnectErrorNotification"
let kGetProductsFromItunes = "kGetProductsFromItunes"

class StoreKitManager: NSObject, SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    static let shared: StoreKitManager = {
        let instance = StoreKitManager()
        SKPaymentQueue.default().add(instance)
        return instance
    }()

    var generatesNotifications: Bool = true
    var validProducts:Array<Any> = []
    var isProductPurchased:Bool = false
    var productIdentifier:String?
    private var productsRequest:SKProductsRequest?
    private var isPurchaseInitated:Bool = false
    
    func checkIfUserHasPremium() -> Bool {
        if let isSubscribed = UserDefaults.standard.value(forKey: "isSubscribed") {
            return isSubscribed as! Bool
        }
         return false
    }
    
    func fetchUserSubscriptionInfo() {
        /*PFUser.current()?.fetchInBackground(block: { (obj, error) in
            if obj != nil  {
                if let isSubscribed = obj?.value(forKey: "HasPremium") {
                    UserDefaults.standard.set(isSubscribed, forKey: "isSubscribed")
                }
                else{
                    UserDefaults.standard.set(false, forKey: "isSubscribed")
                }
            }
        })*/
    }

    func updateTransactionInfoWithUser(response: @escaping ((_ isSuccess:Bool) -> Void)) {
        response(true) //TEMPORARY
        /*let receiptData = try? Data(contentsOf: Bundle.main.appStoreReceiptURL!)
        if let receiptData = receiptData {
            PFCloud.callFunction(inBackground: "UserPurchased", withParameters: ["receiptData":receiptData]) { (succees, error) in
                if error == nil {
                    PFUser.current()?.fetchInBackground(block: { (obj, error) in
                        /*obj?.setValue(true, forKey: "HasPremium") //this value is now set on the server which is more secure
                        do {
                            try obj?.save()
                        } catch {
                            print(error)
                        }*/
                        if (PFUser.current()?["HasPremium"] as? Bool == true) {
                            UserDefaults.standard.set(true, forKey: "isSubscribed")
                        } else {
                            UserDefaults.standard.set(false, forKey: "isSubscribed")
                        }
                        response(true)
                    })
                } else {
                    UserDefaults.standard.set(false, forKey: "isSubscribed")
                    response(false)
                }
            }
        } else {
            response(false)
        }*/
    }
    
    //Same as above method, but modified to not do anything if anything like a network connection fails. The source of truth will always be whether the user has its 'HasPremium' field set to true or not. No pariular reason updateTransactionInfoWithUser is kept, except it is more strict.
    /*func verifyReceiptAndCheckExpiry(response: @escaping ((_ isSuccess:Bool) -> Void)) {
        let receiptData = try? Data(contentsOf: Bundle.main.appStoreReceiptURL!)
        if let receiptData = receiptData {
            PFCloud.callFunction(inBackground: "UserPurchased", withParameters: ["receiptData":receiptData]) { (succees, error) in
                //The above line will update the PFUser's 'HasPremium' field with the correct value based on the receipt stored locally.
                PFUser.current()?.fetchInBackground(block: { (obj, error) in
                    if (PFUser.current()?["HasPremium"] as? Bool == true) {
                        UserDefaults.standard.set(true, forKey: "isSubscribed")
                    } else {
                        UserDefaults.standard.set(false, forKey: "isSubscribed")
                    }
                    response(true)
                })
            }
        } else {
            PFUser.current()?.fetchInBackground(block: { (obj, error) in
                if (PFUser.current()?["HasPremium"] as? Bool == true) {
                    UserDefaults.standard.set(true, forKey: "isSubscribed")
                } else {
                    UserDefaults.standard.set(false, forKey: "isSubscribed")
                }
                response(true)
            })
        }
    }*/
    
    /**
     *  Method to show alert
     *
     *  @param title   title to be shown
     *  @param message message to be shown
     */
    func showAlertWithTitle(title: String,  message messageStr:String) {
        let dic = ["title": title,"message":messageStr]
        postNotification(name: NSNotification.Name(rawValue: kShowAlertNotification), object: nil, userInfo: dic)
    }
    
    /**
     *  Method to restore all completed transactions for user
     */
    func restorePreviousTransaction() {
        if (canMakePurchases()) {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
        else {
            postNotification(name: NSNotification.Name(rawValue: kPurchaseFailedNotification), object: nil, userInfo: nil)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        postNotification(name: NSNotification.Name(rawValue: kPurchaseFailedNotification), object: nil, userInfo: nil)
    }
    
    /**
     *  Method to determine whether user can make purchase
     *
     *  @return BOOL value with determination
     */
    func canMakePurchases() -> Bool{
        return SKPaymentQueue.canMakePayments()
    }
    
    /**
     *  Method to initiate purchase product
     *
     *  @param product valid SKProduct to be purchased
     */
    func purchaseProduct(product:SKProduct){
        if (canMakePurchases()) {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
        else{
            showAlertWithTitle(title: "Purchases are disabled in your device", message: "")
        }
    }
    
    /**
     *  Method to initiate purchase for valid product
     */
    func initiatePurchase(){
        for transaction:SKPaymentTransaction in SKPaymentQueue.default().transactions
        {
            if transaction.transactionState == SKPaymentTransactionState.purchased
            {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            else if (transaction.transactionState == SKPaymentTransactionState.failed) {
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
        purchaseProduct(product: validProducts[0] as! SKProduct)
    }
    
    
    /**
     *  Method to fetch product from iTunes for product identifier
     *
     *  @param pId product identifier
     */
    func fetchAvailableProductsForProdcutIdentifier(pId: String){
        if (canMakePurchases()) {
            self.isPurchaseInitated = true
            let productIdentifiers:NSSet = NSSet(object: pId);
            self.productIdentifier = pId
            productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productsRequest?.delegate = self
            productsRequest?.start()
        }
        else {
            postNotification(name: NSNotification.Name(rawValue: kPurchaseFailedNotification), object: nil, userInfo: nil)
        }
    }
    
    /**
     Method to manage the transaction and receipt
     
     @param transaction SKPaymentTransaction
     @param receiptData transaction receipt
     */
    func getTransaction(transaction: SKPaymentTransaction, andReceiptData receiptData: NSData?){
        switch transaction.transactionState
        {
        case .purchased:
            if transaction.transactionIdentifier != nil && receiptData != nil {
                var transactionId:String = transaction.transactionIdentifier!
                if transaction.original != nil {
                    if transaction.original?.transactionIdentifier != nil {
                        transactionId = transaction.original!.transactionIdentifier!
                    }
                }
                let userInfo:Dictionary<String, Any>  = ["success": true, "transactionId":transactionId,"receiptData":receiptData!, "productIdentifier":transaction.payment.productIdentifier]
                postNotification(name: NSNotification.Name(rawValue: kPurchaseCompletionNotification), object: nil, userInfo: userInfo)
            }
            break
        case .restored :
            if transaction.original != nil {
                if ((transaction.original!.transactionIdentifier != nil) && receiptData != nil) {
                    let userInfo:Dictionary<String, Any>  = ["success": true, "transactionId":transaction.original!.transactionIdentifier!,"receiptData":receiptData!, "productIdentifier":transaction.payment.productIdentifier]
                    postNotification(name: NSNotification.Name(rawValue: kPurchaseRestoreNotification), object: nil, userInfo: userInfo)
                }
                else if (transaction.original!.transactionIdentifier != nil) {
                    let userInfo:Dictionary<String, Any>  = ["success": true, "transactionId":transaction.original!.transactionIdentifier!,"productIdentifier":transaction.payment.productIdentifier]
                    postNotification(name: NSNotification.Name(rawValue: kPurchaseRestoreNotification), object: nil, userInfo: userInfo)
                }
                else {
                    SKPaymentQueue.default().finishTransaction(transaction)
                    postNotification(name: NSNotification.Name(rawValue: kRestorePurchaseFailedNotification), object: nil, userInfo: nil)
                }
            }
            else {
                SKPaymentQueue.default().finishTransaction(transaction)
                postNotification(name: NSNotification.Name(rawValue: kRestorePurchaseFailedNotification), object: nil, userInfo: nil)
            }
            break
        default:
            break
        }
    }
    
    //MARK: StoreKit Delegate methods
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var totalNumberOfPurchasedProducts = 0
        for transaction:AnyObject in transactions {
            if transaction.transactionState == SKPaymentTransactionState.purchased {
                totalNumberOfPurchasedProducts = totalNumberOfPurchasedProducts + 1;
            }
        }
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchasing:
                    postNotification(name: NSNotification.Name(rawValue:kPurchaseInProcessNotification), object: nil, userInfo: nil)
                    break
                case .purchased:
                    if (transaction.payment.productIdentifier == self.productIdentifier && isTheTransactionCurrentTransaction(transaction: transaction as! SKPaymentTransaction, withTotalPurchasedTransactions:totalNumberOfPurchasedProducts)) {
                        self.isProductPurchased = true
                        let receiptURL = Bundle.main.appStoreReceiptURL
                        let receipt:NSData? = NSData(contentsOf:receiptURL!)
                        getTransaction(transaction: transaction as! SKPaymentTransaction, andReceiptData:receipt)
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    }
                    else {
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        postNotification(name: NSNotification.Name(rawValue: kPurchaseFailedNotification), object: nil, userInfo: nil)
                    }
                    break
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    postNotification(name: NSNotification.Name(rawValue: kPurchaseFailedNotification), object: nil, userInfo: nil)
                    self.isProductPurchased = false
                    break
                case .restored :
                    let receiptURL:URL? = Bundle.main.appStoreReceiptURL
                    if receiptURL != nil && !self.isProductPurchased {
                        self.isProductPurchased = true
                        let receiptData:NSData? = NSData(contentsOf: receiptURL!)
                        getTransaction(transaction: transaction as! SKPaymentTransaction, andReceiptData: receiptData)
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        postNotification(name: NSNotification.Name(rawValue: kRestorePurchaseCompletionNotification), object: nil, userInfo: nil)
                    }
                    else {
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        postNotification(name: NSNotification.Name(rawValue: kPurchaseFailedNotification), object: nil, userInfo: nil)
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue){
        if (queue.transactions.count == 0) {
            postNotification(name: NSNotification.Name(rawValue: kPurchaseRestoreWithZeroTransaction), object: nil, userInfo: nil)
        }
    }
    
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let count : Int = response.products.count
        if self.isPurchaseInitated == true {
            self.isPurchaseInitated = false
            if (count > 0) {
                self.validProducts = response.products
                initiatePurchase()
            }
            else {
                showAlertWithTitle(title: "No Products Available!", message: "There are no products available for subscription on iTunes.")
                postNotification(name: NSNotification.Name(rawValue: kPurchaseFailedNotification), object: nil, userInfo: nil)
            }
        }
        else{
            if (count > 0) {
                self.validProducts = response.products
                postNotification(name: NSNotification.Name(rawValue: kGetProductsFromItunes), object: self.validProducts, userInfo: nil)
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        let userInfo:Dictionary<String, String> = ["errorMessage": error.localizedDescription]
        postNotification(name: NSNotification.Name(rawValue: kiTunesConnectErrorNotification), object: nil, userInfo: userInfo)
    }
    
    func isTheTransactionCurrentTransaction(transaction: SKPaymentTransaction, withTotalPurchasedTransactions totalPurchasedTransactions:Int) ->Bool {
        if (totalPurchasedTransactions == 1) {
            return true
        }
        else if (transaction.transactionDate != nil) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            dateFormatter.locale = NSLocale(localeIdentifier: "US") as Locale
            let now = NSDate()
            let dateAsString:String = dateFormatter.string(from: now as Date)
            let utcDate: NSDate = dateFormatter.date(from: dateAsString)! as NSDate
            let secs = utcDate.timeIntervalSince(transaction.transactionDate!)
            if (secs <= 120) {
                return true
            }
        }
        return false
    }
    
    private func postNotification(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        if generatesNotifications {
            NotificationCenter.default.post(name: aName, object: anObject, userInfo: aUserInfo)
        }
    }
    
    func validateProductIdentifiers(_ productIdentifiers: [String]) {
        let productsRequest = SKProductsRequest(productIdentifiers: Set<String>(productIdentifiers))
        // Keep a strong reference to the request.
        productsRequest.delegate = self
        productsRequest.start()
    }
}
