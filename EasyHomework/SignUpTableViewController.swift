//
//  SignUpTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-16.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse

class SignUpTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var descriptionCell: UITableViewCell!
    @IBOutlet var emailCell: UITableViewCell!
    @IBOutlet var passwordCell: UITableViewCell!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signUpCell: UITableViewCell!
    @IBOutlet var belowSignUpCell: UITableViewCell!
    @IBOutlet var termsOfUseCell: UITableViewCell!
    @IBOutlet var privacyPolicyCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.descriptionCell.preservesSuperviewLayoutMargins = false
        self.descriptionCell.separatorInset = UIEdgeInsets.zero
        self.descriptionCell.layoutMargins = UIEdgeInsets.zero
        self.passwordCell.preservesSuperviewLayoutMargins = false
        self.passwordCell.separatorInset = UIEdgeInsets.zero
        self.passwordCell.layoutMargins = UIEdgeInsets.zero
        self.belowSignUpCell.preservesSuperviewLayoutMargins = false
        self.belowSignUpCell.separatorInset = UIEdgeInsets.zero
        self.belowSignUpCell.layoutMargins = UIEdgeInsets.zero
        self.termsOfUseCell.preservesSuperviewLayoutMargins = false
        self.termsOfUseCell.separatorInset = UIEdgeInsets.zero
        self.termsOfUseCell.layoutMargins = UIEdgeInsets.zero
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Keep private", attributes: [ NSAttributedStringKey.foregroundColor : UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.2) ])
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Ex) jbob2@uwo.ca", attributes: [ NSAttributedStringKey.foregroundColor : UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.2) ])
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
    
    var signingUpOccurring = false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.emailTextField) {
            self.passwordTextField.becomeFirstResponder()
            return false
        }
        
        if (textField == self.passwordTextField) {
            if (signingUpOccurring == true) { return false }
            signingUpOccurring = true
            self.signUp()
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)! as UITableViewCell
        if (cell == self.signUpCell) {
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.signUp()
        }
        
        if (cell == self.termsOfUseCell) {
            let touVC = self.storyboard!.instantiateViewController(withIdentifier: "TOUViewController") as! TOUViewController
            self.show(touVC, sender: self.termsOfUseCell)
        }
        
        if (cell == self.privacyPolicyCell) {
            let ppVC = self.storyboard!.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            self.show(ppVC, sender: self.privacyPolicyCell)
        }
    }

    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
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
    
    func signUp() {
        self.signUpCell.isUserInteractionEnabled = false
        let user = PFUser()
        user.username = self.emailTextField.text
        user.password = self.passwordTextField.text
        user.email = self.emailTextField.text
        if (self.emailTextField.text == "" || self.passwordTextField.text == "" || self.emailTextField.text == "") {
            self.signingUpOccurring = false
            let errorVC = UIAlertController(title: "Oops..", message: "Type an email and password.", preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
            self.signUpCell.isUserInteractionEnabled = true
            return
        }
        user.signUpInBackground(block: { (succeed, error) -> Void in
            if (error == nil) {
                let user = PFUser.current()!
                PFUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: { (succeed, error) -> Void in
                    if (error == nil) {
                        self.signingUpOccurring = false
                        self.dismiss(animated: true, completion: nil)
                        self.tableView.endEditing(true)
                    } else {
                        self.signingUpOccurring = false
                        let errorVC = UIAlertController(title: "Success", message: "Please proceed to log in with your newly created account. Tap the Login button to get started.", preferredStyle: .alert)
                        errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                        self.present(errorVC, animated: true, completion: nil)
                        self.signUpCell.isUserInteractionEnabled = true
                        self.tableView.endEditing(true)
                    }
                })
            } else {
                let errorVC = UIAlertController(title: "Oops..", message: error!.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
                self.signUpCell.isUserInteractionEnabled = true
            }
        })
    }
    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
