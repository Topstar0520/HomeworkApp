//
//  ReceiptHandler.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2020-04-11.
//  Copyright © 2020 Anthony Giugno. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class ReceiptHandler: NSObject, SKRequestDelegate {
    
    let receiptURL = Bundle.main.appStoreReceiptURL
    var isInitialPurchase = false //true if currently validating a receipt for a purchase just completed
    var productPrice: NSDecimalNumber?

    func handleAppReceipt() {
        guard let receiptURL = receiptURL else {  /* receiptURL is nil, it would be very weird to end up here */  return }
        do {
            let receipt = try Data(contentsOf: receiptURL)
            validateAppReceipt(receipt)
        } catch {
            // there is no app receipt, don't panic, ask apple to refresh it
            UserDefaults.standard.set(false, forKey: "isSubscribed")
            /*let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.setRemindersNotifications()*/
            
            /*let appReceiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
            appReceiptRefreshRequest.delegate = self
            appReceiptRefreshRequest.start()*/
            
            // If all goes well control will land in the requestDidFinish() delegate method.
            // If something bad happens control will land in didFailWithError.
        }
    }

    /*func requestDidFinish(_ request: SKRequest) {
        // a fresh receipt should now be present at the url
        do {
            let receipt = try Data(contentsOf: receiptURL!) //force unwrap is safe here, control can't land here if receiptURL is nil
            validateAppReceipt(receipt)
        } catch {
            // still no receipt, possible but unlikely to occur since this is the "success" delegate method
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) { //Could not fetch receipt + No local receipt present
        print("app receipt refresh request did fail with error: \(error)")
        UserDefaults.standard.set(false, forKey: "isSubscribed")
        // for some clues see here: https://samritchie.net/2015/01/29/the-operation-couldnt-be-completed-sserrordomain-error-100/
        
    }*/
    
    func validateAppReceipt(_ receipt: Data) {
        
        var forceRefresh = false
        if (UserDefaults.standard.double(forKey: "ExpiryDateOfLastPurchase") != 0 && UserDefaults.standard.double(forKey: "ExpiryDateOfLastPurchase") != nil) {
            let expiryDate = UserDefaults.standard.double(forKey: "ExpiryDateOfLastPurchase")
            //if (expiryDate < Date().timeIntervalSinceReferenceDate) { //we check if the receipt is already past expiry, no need to check if it's not.
            forceRefresh = true //forceRefresh = true because we know this user has purchased the app before, and they typically stay logged in to the app store.
            //}
        }
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "2f8899aef07d4e59990de45d74bb9068")
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: forceRefresh) { result in
            switch result {
            case .success(let receipt):
                
                var isSubscribed = false
                var expiryDateNumberOfSecondsSinceReferenceDate: TimeInterval?
                
                //
                let productId1 = "com.b4grad.yearlySubscription"
                // Verify the purchase of a Subscription
                let purchaseResult1 = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId1,
                    inReceipt: receipt)
                    
                switch purchaseResult1 {
                case .purchased(let expiryDate, let items):
                    print("\(productId1) is valid until \(expiryDate)\n\(items)\n")
                    isSubscribed = true
                    expiryDateNumberOfSecondsSinceReferenceDate = expiryDate.timeIntervalSinceReferenceDate
                    if (self.isInitialPurchase) {
                        self.sendPurchaseEvent(name: "Yearly Subscription", price: self.productPrice)
                    }
                case .expired(let expiryDate, let items):
                    print("\(productId1) is expired since \(expiryDate)\n\(items)\n")
                    expiryDateNumberOfSecondsSinceReferenceDate = expiryDate.timeIntervalSinceReferenceDate
                case .notPurchased:
                    print("The user has never purchased \(productId1)")
                }
                //
                
                //
                let productId2 = "com.b4grad.monthlySubscription"
                let purchaseResult2 = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId2,
                    inReceipt: receipt)
                    
                switch purchaseResult2 {
                case .purchased(let expiryDate, let items):
                    print("\(productId2) is valid until \(expiryDate)\n\(items)\n")
                    isSubscribed = true
                    expiryDateNumberOfSecondsSinceReferenceDate = expiryDate.timeIntervalSinceReferenceDate
                    if (self.isInitialPurchase) {
                        self.sendPurchaseEvent(name: "Monthly Subscription", price: self.productPrice)
                    }
                case .expired(let expiryDate, let items):
                    print("\(productId2) is expired since \(expiryDate)\n\(items)\n")
                    expiryDateNumberOfSecondsSinceReferenceDate = expiryDate.timeIntervalSinceReferenceDate
                case .notPurchased:
                    print("The user has never purchased \(productId2)")
                }
                //
                
                //
                let productId3 = "com.b4grad.weekly"
                let purchaseResult3 = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId3,
                    inReceipt: receipt)
                    
                switch purchaseResult3 {
                case .purchased(let expiryDate, let items):
                    print("\(productId3) is valid until \(expiryDate)\n\(items)\n")
                    isSubscribed = true
                    expiryDateNumberOfSecondsSinceReferenceDate = expiryDate.timeIntervalSinceReferenceDate
                    if (self.isInitialPurchase) {
                        self.sendPurchaseEvent(name: "Weekly Subscription", price: self.productPrice)
                    }
                case .expired(let expiryDate, let items):
                    print("\(productId3) is expired since \(expiryDate)\n\(items)\n")
                    expiryDateNumberOfSecondsSinceReferenceDate = expiryDate.timeIntervalSinceReferenceDate
                case .notPurchased:
                    print("The user has never purchased \(productId3)")
                }
                //
                
                //
                let productId4 = "com.b4grad.yearlyDiscountSubscription"
                let purchaseResult4 = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId4,
                    inReceipt: receipt)
                    
                switch purchaseResult4 {
                case .purchased(let expiryDate, let items):
                    print("\(productId4) is valid until \(expiryDate)\n\(items)\n")
                    isSubscribed = true
                    expiryDateNumberOfSecondsSinceReferenceDate = expiryDate.timeIntervalSinceReferenceDate
                    if (self.isInitialPurchase) {
                        self.sendPurchaseEvent(name: "Yearly Discount Subscription", price: self.productPrice)
                    }
                case .expired(let expiryDate, let items):
                    print("\(productId4) is expired since \(expiryDate)\n\(items)\n")
                    expiryDateNumberOfSecondsSinceReferenceDate = expiryDate.timeIntervalSinceReferenceDate
                case .notPurchased:
                    print("The user has never purchased \(productId4)")
                }
                //
                
                //
                let productId5 = "com.b4grad.onetime"
                let purchaseResult5 = SwiftyStoreKit.verifyPurchase(
                    productId: productId5,
                    inReceipt: receipt)
                    
                switch purchaseResult5 {
                case .purchased(let receiptItem):
                    print("\(productId5) is purchased: \(receiptItem)")
                    isSubscribed = true
                    //expiryDateNumberOfSecondsSinceReferenceDate = expiryDate.timeIntervalSinceReferenceDate
                    UserDefaults.standard.set(true, forKey: "LifetimePurchaser")
                    if (self.isInitialPurchase) {
                        self.sendPurchaseEvent(name: "Lifetime", price: self.productPrice)
                    }
                case .notPurchased:
                    print("The user has never purchased \(productId5)")
                }
                //
                
                UserDefaults.standard.set(isSubscribed, forKey: "isSubscribed") //will be true if atleast one out of the 3 are purchased and not expired.
                if (isSubscribed == true) {
                    UserDefaults.standard.set(expiryDateNumberOfSecondsSinceReferenceDate, forKey: "ExpiryDateOfLastPurchase")
                   // print(Date(timeIntervalSinceReferenceDate: expiryDateNumberOfSecondsSinceReferenceDate!).description) //causes crash
                    
                    NotificationCenter.default.post(name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil) //to update backgroundView if necessary
                    
                    /*let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    appdelegate.setRemindersNotifications()*/
                }
                

            case .error(let error):
                print("Receipt verification failed: \(error)")
                UserDefaults.standard.set(false, forKey: "isSubscribed")
                NotificationCenter.default.post(name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil) //to update backgroundView if necessary
                
                /*UIApplication.shared.cancelAllLocalNotifications()
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()*/
            }
        }
        
    }
    
    
    //Use Kochava to send a purchase event.
    func sendPurchaseEvent(name: String, price: NSDecimalNumber?) {
        if let event = KochavaEvent(eventTypeEnum: .purchase) {
            event.nameString = name //"Monthly Subscription"
            if (price != nil) {
                event.priceDecimalNumber = price //9.99
            } else {
                event.priceDecimalNumber = 0
            }
            //Sending the Receipt below is commented because it hasn't been tested in sandbox. If it works, uncomment.
            /*guard let receiptURL = receiptURL else {
                    return
            }
            do {
                let receipt = try Data(contentsOf: receiptURL)
                let receiptbase64EncodedString = receipt.base64EncodedString(options: [])
                event.appStoreReceiptBase64EncodedString = receiptbase64EncodedString
            } catch {
                print("Cannot find/use receipt for Kochava.")
            }*/
                    
            KochavaTracker.shared.send(event)
        }
    }
    
}
