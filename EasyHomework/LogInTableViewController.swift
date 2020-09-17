//
//  LogInTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-17.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse

class LogInTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var welcomeBackCell: UITableViewCell!
    @IBOutlet var emailCell: UITableViewCell!
    @IBOutlet var passwordCell: UITableViewCell!
    @IBOutlet var logInCell: UITableViewCell!
    @IBOutlet var forgotYourPasswordCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.welcomeBackCell.preservesSuperviewLayoutMargins = false
        self.welcomeBackCell.separatorInset = UIEdgeInsets.zero
        self.welcomeBackCell.layoutMargins = UIEdgeInsets.zero

        self.logInCell.preservesSuperviewLayoutMargins = false
        self.logInCell.separatorInset = UIEdgeInsets.zero
        self.logInCell.layoutMargins = UIEdgeInsets.zero
        
        self.forgotYourPasswordCell.preservesSuperviewLayoutMargins = false
        self.forgotYourPasswordCell.separatorInset = UIEdgeInsets.zero
        self.forgotYourPasswordCell.layoutMargins = UIEdgeInsets.zero
        
        self.passwordCell.preservesSuperviewLayoutMargins = false
        self.passwordCell.separatorInset = UIEdgeInsets.zero
        self.passwordCell.layoutMargins = UIEdgeInsets.zero
        
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Keep private", attributes: [ NSAttributedStringKey.foregroundColor : UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.2) ])
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Ex) jbob2@uwo.ca", attributes: [ NSAttributedStringKey.foregroundColor : UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.2) ])
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let selectedRowIndexPath = self.tableView.indexPathForSelectedRow
        if ((selectedRowIndexPath) != nil) {
            self.tableView.deselectRow(at: selectedRowIndexPath!, animated: true)
            self.transitionCoordinator?.notifyWhenInteractionEnds({ context in
                if (context.isCancelled) {
                    self.tableView.selectRow(at: selectedRowIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.emailTextField) {
            self.passwordTextField.becomeFirstResponder()
            return false
        }
        
        if (textField == self.passwordTextField) {
            self.login()
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        if (cell == self.logInCell) {
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.login()
        }
        
        if (cell == self.forgotYourPasswordCell) {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 21/255, green: 21/255, blue: 21/255, alpha: 1.0)
        if (cell.contentView.backgroundColor != UIColor.clear) {
            cell.backgroundColor = cell.contentView.backgroundColor
        }
    }

    func login() {
        self.logInCell.isUserInteractionEnabled = false
        PFUser.logInWithUsername(inBackground: self.emailTextField.text!, password: self.passwordTextField.text!, block: { (user, error) -> Void in
            if (error == nil) {
                self.tableView.endEditing(true)
                self.dismiss(animated: true, completion: { })
            } else {
                self.logInCell.isUserInteractionEnabled = true
                let errorVC = UIAlertController(title: "Oops..", message: error!.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
