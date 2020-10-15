//
//  RewardsViewController.swift
//  B4Grad
//
//  Created by Chauhan on 06/02/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit
import Firebase
import EFQRCode
import Parse

class RewardsViewController: UIViewController {

    @IBOutlet var btnCopyLink: UIButton!
    @IBOutlet var imgQR: UIImageView!
    @IBOutlet var imgPoints: UIImageView!
    @IBOutlet var lblPoints: UILabel!
    @IBOutlet var lblPopUp: UILabel!
    @IBOutlet var qrLoader: UIActivityIndicatorView!
    @IBOutlet var vwPop: UIView!

    var strLink: String?
    //MARK: -- ViewCycle&ClassHelper --

    override func viewDidLoad() {
        super.viewDidLoad()
        vwPop.isHidden = true
//        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
//        visualEffectView.frame = vwPop.bounds
//        vwPop.addSubview(visualEffectView)
        btnCopyLink.layer.borderColor = UIColor.white.cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
   
    func setUpData() {
        qrLoader.startAnimating()
    //    codeLoader.startAnimating()
        let userO = PFUser.current()!
        let userQuery: PFQuery = PFQuery(className: "Referral")
        userQuery.whereKey("Id", equalTo: userO.objectId!)
        userQuery.findObjectsInBackground(block: {
            (user, error) -> Void in
            self.qrLoader.stopAnimating()
            //    self.codeLoader.stopAnimating()
            self.qrLoader.removeFromSuperview()
            //     self.codeLoader.removeFromSuperview()
            if user != nil {
                if (user!.count <= 0) {
                    let follow = PFObject(className: "Referral")
                    follow["ReferralPoint"] = 0
                    guard let link = URL(string: "https://www.b4grad.com/?userId=\(PFUser.current()!.objectId ?? "1")") else {
                        return
                    }
                    let domainURIPRefix = "https://b4grad.page.link"
                    let linkBuilder = DynamicLinkComponents.init(link: link, domainURIPrefix: domainURIPRefix)
                    linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "test.EasyHomework")
                    linkBuilder?.iOSParameters?.appStoreID = "1352751059"
                    linkBuilder?.iOSParameters?.minimumAppVersion = "1.0.3"
                    guard let longDynamicLink = linkBuilder?.url else { return }
                    DynamicLinkComponents.shortenURL(longDynamicLink, options: nil) { url, warnings, error in
                        if url != nil  {
                            follow["ReferralLink"] = url?.absoluteString
                            follow["Id"] = userO.objectId ?? "1"
                            follow.saveInBackground { (success, error) -> Void in
                                if error == nil {
                                    let userO = PFUser.current()!
                                    let userQuery: PFQuery = PFQuery(className: "Referral")
                                    userQuery.whereKey("Id", equalTo: userO.objectId!)
                                    userQuery.findObjectsInBackground(block: {
                                        (user, error) -> Void in
                                        if (user != nil) {
                                            self.doTheRest(user: user)
                                        }
                                    })
                                }
                            }
                        }
                    }
                } else { self.doTheRest(user: user) }
                /*let objectN = user![0]
                if  let userLink = objectN.object(forKey: "ReferralLink") as? String {
                    self.setQrCode(userLink: userLink)
                } else {
                    AppDelegate.createDynamicLink(completion: { (linkUrl) -> (Void) in
                        if linkUrl != nil {
                            self.setQrCode(userLink: "\(linkUrl!)")
                            AppDelegate.setDynamicLink(linkUrl!, forUser: objectN as! PFUser)
                        }
                    })
                }
                if  let point = objectN.object(forKey: "ReferralPoint") {
                    if (point as! Int) > 1 {
                        self.lblPoints.text = "You Currently have \(point) Points."
                    } else {
                        self.lblPoints.text = "You Currently have \(point) Points."
                    }
                    
                    if ((point as! Int) >= 25) {
                        UserDefaults.standard.set(true, forKey: "HasDiscount")
                        let alert = UIAlertController(title: "WOW! Congratulations!",
                                                      message: "You Have Unlocked a Free Year of Premium! If you have already registered a B4Grad account, please email contact@b4grad.com with your email address contained in the email. Otherwise, create an account first then email us with the above information. We will send you a code to redeem on the App Store.",
                                                      preferredStyle: .alert)
                         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                        // Show the alert by presenting it

                        self.present(alert, animated: true)
                    } else if ((point as! Int) >= 12) {
                        UserDefaults.standard.set(true, forKey: "HasDiscount")
                        let alert = UIAlertController(title: "Congratulations!",
                                                      message: "You Have Unlocked your Discount! Please close B4Grad in the iOS multitasker, leave us a rating on the App Store, and launch the app again. The subscription screen will have its yearly price updated. For any help, email support and we can activate it manually.",
                                                      preferredStyle: .alert)
                         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                        // Show the alert by presenting it

                        self.present(alert, animated: true)
                    }
                    
                    self.updateRewardImage((point as! Int))
                }*/
            }
        })
    }
    
    func doTheRest(user: [PFObject]?) {
        let objectN = user![0] //user![0]
        if  let userLink = objectN.object(forKey: "ReferralLink") as? String {
            self.setQrCode(userLink: userLink)
        } else {
            AppDelegate.createDynamicLink(completion: { (linkUrl) -> (Void) in
                if linkUrl != nil {
                    self.setQrCode(userLink: "\(linkUrl!)")
                    AppDelegate.setDynamicLink(linkUrl!, forUser: objectN as! PFUser)
                }
            })
        }
        if  let point = objectN.object(forKey: "ReferralPoint") {
            if (point as! Int) > 1 {
                self.lblPoints.text = "You Currently have \(point) Points."
            } else {
                self.lblPoints.text = "You Currently have \(point) Points."
            }
            
            if ((point as! Int) >= 25) {
                UserDefaults.standard.set(true, forKey: "HasDiscount")
                let alert = UIAlertController(title: "WOW! Congratulations!",
                                              message: "You Have Unlocked a Free Year of Premium! If you have already registered a B4Grad account, please email contact@b4grad.com with your email address contained in the email. Otherwise, create an account first then email us with the above information. We will send you a code to redeem on the App Store.",
                                              preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                // Show the alert by presenting it

                self.present(alert, animated: true)
            } else if ((point as! Int) >= 12) {
                UserDefaults.standard.set(true, forKey: "HasDiscount")
                let alert = UIAlertController(title: "Congratulations!",
                                              message: "You Have Unlocked your Discount! Please close B4Grad in the iOS multitasker, leave us a rating on the App Store, and launch the app again. The subscription screen will have its yearly price updated. For any help, email support and we can activate it manually.",
                                              preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                // Show the alert by presenting it

                self.present(alert, animated: true)
            }
            
            self.updateRewardImage((point as! Int))
        }
    }
    
    func setQrCode(userLink: String) {
        self.imgQR.image = self.createQR(for: userLink)
        self.imgQR.layer.magnificationFilter = kCAFilterNearest
        self.strLink = userLink
    }
    
    func updateRewardImage(_ award: Int) {
        var imgStr = ""
        if award >= 5 &&  award < 12 {
            imgStr = "step-main4-v2"
        } else if award >= 12 &&  award < 25 {
            imgStr = "step-main4-v3"
        } else if award  >= 25 {
            imgStr = "step-main4-v4"
        } else {
            imgStr = "step-main4-v1"
        }
        self.imgPoints.image = UIImage(named: imgStr)
    }
    
    //MARK: -- Button Action --
    
    @IBAction func printQRCode(_ sender: AnyObject) {

//        let printInfo = UIPrintInfo(dictionary:nil)
//        printInfo.outputType = UIPrintInfoOutputType.general
//        printInfo.jobName = "My Print Job"
//
//        // Set up print controller
//        let printController = UIPrintInteractionController.shared
//        printController.printInfo = printInfo
//
//        // Assign a UIImage version of my UIView as a printing iten
//        printController.printingItem = self.imgQR.toImage()
//
//        // If you want to specify a printer
//        guard let printerURL = URL(string: "LANIERCOLOR315 [00:80:A3:95:2D:41]._ipp._tcp.local") else { return }
//        guard let currentPrinter = UIPrinter(url: printerURL) as? UIPrinter else { return }
//        printController.print(to: currentPrinter, completionHandler: nil)
//        // Do it
//        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
        
//        let formatter = UIMarkupTextPrintFormatter(markupText: "")
//        formatter.perPageContentInsets = UIEdgeInsets(top: 2, left: 2,
//                                                      bottom: 2, right: 2)
//
//
//        let printController = UIPrintInteractionController.shared
//        printController.printInfo = printInfo
//        printController.printingItem = imgQR.image
//        printController.showsNumberOfCopies = true
//        printController.printFormatter = formatter
//        printController.present(animated: true, completionHandler: nil)
        
//        let printHtmlString = "<html lang=\"en\"><body><div style=\"margin: 0 auto;display: table; margin-top: 16px;\" class=\"squareBackground\"><!-- <div class=\"squareBackground\"> --><img src=\"file://\(qrCodeImagePath)\" alt=\"Qr_code\" width=\"90\" height=\"90\" align=\"middle\" style=\"padding:5px;\"><!-- </div> --></div></body></html>"
       // "https://" + tfLink.text!
      //  let formatter = TicketPrintPageRenderer(receipt: strLink ?? "")
        
//        let printInfo = UIPrintInfo(dictionary:nil)
//        printInfo.outputType = UIPrintInfoOutputType.photo
//        printInfo.jobName = "Print QR"
//        printInfo.orientation = .portrait
        
        let printController = UIPrintInteractionController.shared
        printController.showsNumberOfCopies = true
//        printController.printInfo = printInfo
        printController.showsPageRange = false
        printController.printingItem = self.imgQR.toImage()
//        let imageData: Data = UIImagePNGRepresentation(self.imgQR.image!)!
//        let strInfo = "Get the best iPhone App for Students Now!' and some small text below that that says 'Homework has never been this easy to organize."
//        let strData = strInfo.data(using: String.Encoding.utf8)
//        printController.printingItems = [imageData,strData]
//
//        let formatter = UIMarkupTextPrintFormatter()
//        formatter.perPageContentInsets = UIEdgeInsets(top: 2, left: 2,
//                                                      bottom: 2, right: 2)
//       addPrintFormatter(formatter, startingAtPageAt: 0)
//
//        printController.printFormatter = formatter
        printController.present(animated: true) { (controller, success, errorMsg) in
            if success {
                print("***** Print Successfully")
            } else {
                print("***** Print Failed : \(errorMsg?.localizedDescription)")
            }
        }
    }
    
    @IBAction func copyReferralLink(_ sender: AnyObject) {
        UIPasteboard.general.string = strLink ?? ""
        UIView.transition(with: vwPop, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.vwPop.isHidden = false
        })
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(closePopUp), userInfo: nil, repeats: false)
    }

    @IBAction func doneBarButtonItemTapped(_ sender: AnyObject) {
        
    }
    
    @objc func closePopUp(timer: Timer) {
        UIView.transition(with: vwPop, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.vwPop.isHidden = true
        })
    }
}

extension RewardsViewController {
    
    func createQR(for qrString: String?) -> UIImage? {
        
        let qrSize = EFIntSize(
            width: Int(imgQR.frame.size.width),
            height: Int(imgQR.frame.size.height))
        let icSize = EFIntSize(
            width: Int(imgQR.frame.size.width/2.5),
            height: Int(imgQR.frame.size.height/2.5))
        if let tryImage = EFQRCode.generate(content: qrString!, size: qrSize, backgroundColor: CGColor.EFBlack(), foregroundColor: CGColor.EFWhite(), watermark: nil, watermarkMode: .center, inputCorrectionLevel: .h, icon: UIImage(named: "AppIcon")?.toCGImage(), iconSize: icSize, allowTransparent: false, pointShape: .square, mode: .none, binarizationThreshold: 1, magnification: nil, foregroundPointOffset: 0) {
            return UIImage(cgImage: tryImage)
        } else {
            return nil
        }
        
//        if let tryImage = EFQRCode.generate(
//            content: qrString!,
//            watermark: UIImage(named: "Graduation Cap White")?.toCGImage()
//            ) {
//            print("Create QRCode image success: \(tryImage)")
//            return UIImage(cgImage: tryImage)
//        } else {
//            print("Create QRCode image failed!")
//            return nil
//        }
//        let stringData: Data? = qrString?.data(using: .isoLatin1)
//        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
//        qrFilter?.setValue(stringData, forKey: "inputMessage")
//        let cmage = qrFilter?.outputImage
//        let context:CIContext = CIContext.init(options: nil)
//        let cgImage:CGImage = context.createCGImage(cmage!, from: cmage!.extent)!
//        let image:UIImage = UIImage(cgImage: cgImage)
//        return image
    }
}

class TicketPrintPageRenderer: UIPrintPageRenderer {
    let receipt: String
    
    init(receipt: String) {
        self.receipt = receipt
        super.init()
        
        self.headerHeight = 0.0
        self.footerHeight = 0.0 // default
        
        let formatter = UIMarkupTextPrintFormatter(markupText: receipt)
        formatter.perPageContentInsets = UIEdgeInsets(top: 2, left: 2,
                                                      bottom: 2, right: 2)
        addPrintFormatter(formatter, startingAtPageAt: 0)
    }
}

extension UIView {
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension Data {
    func hex(separator:String = "") -> String {
        return (self.map { String(format: "%02X", $0) }).joined(separator: separator)
    }
}
