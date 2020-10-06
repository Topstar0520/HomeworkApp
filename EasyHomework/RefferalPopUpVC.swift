//
//  RefferalPopUpVC.swift
//  B4Grad
//
//  Created by Chauhan on 02/03/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse

protocol RefferalPopUpVCDelegate:class {
    func profileButtonTapped(_ sender: AnyObject?)
    func showEmptyView()
}

class RefferalPopUpVC: UIViewController {
    
    @IBOutlet weak var lblDesc: UILabel?
    @IBOutlet weak var btnCross: UIButton?

    var delegate: RefferalPopUpVCDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCross?.layer.borderColor = UIColor.white.cgColor
        setUpData()
        // Do any additional setup after loading the view.
    }
    
    func setUpData() {
        //You Received a Referral Point from your friend [user]!
        let userQuery: PFQuery = PFUser.query()!
        let refferId = UserDefaults.standard.value(forKey: "ReferralUserID") as! String
        userQuery.whereKey("objectId", equalTo: refferId)
        userQuery.findObjectsInBackground(block: {
            (user, error) -> Void in
            if user != nil {
                if (user?.count)! > 0 {
                    let obj = user![0] as! PFUser
                    let strName = obj.object(forKey: "displayName") as? String ?? "Student".localized()
                    self.lblDesc?.text = "You Received a Referral Point from your friend \(strName)!"
                }
            }
        })
    }
    
    @IBAction func doItLaterClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.delegate?.showEmptyView()
        })
    }
    
    @IBAction func createAccountClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.delegate?.showEmptyView()
            self.delegate?.profileButtonTapped(nil)
        })
    }

}
