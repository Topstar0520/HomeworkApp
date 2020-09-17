//
//  ForgotPasswordTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-18.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse

class ForgotPasswordTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var descriptionCell: UITableViewCell!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var emailCell: UITableViewCell!
    @IBOutlet var sendMeInstructionsCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.descriptionCell.preservesSuperviewLayoutMargins = false
        self.descriptionCell.separatorInset = UIEdgeInsets.zero
        self.descriptionCell.layoutMargins = UIEdgeInsets.zero
        
        self.emailCell.preservesSuperviewLayoutMargins = false
        self.emailCell.separatorInset = UIEdgeInsets.zero
        self.emailCell.layoutMargins = UIEdgeInsets.zero
        
        self.sendMeInstructionsCell.preservesSuperviewLayoutMargins = false
        self.sendMeInstructionsCell.separatorInset = UIEdgeInsets.zero
        self.sendMeInstructionsCell.layoutMargins = UIEdgeInsets.zero
        
        self.emailTextField.delegate = self
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.emailTextField) {
            self.resetPassword()
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        if (cell == self.sendMeInstructionsCell) {
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.resetPassword()
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

    func resetPassword() {
        self.sendMeInstructionsCell.isUserInteractionEnabled = false
        PFUser.requestPasswordResetForEmail(inBackground: self.emailTextField.text!, block: { (succeed, error) -> Void in
            if (error == nil) {
                self.dismiss(animated: true, completion: {
                    //let successVC = UIAlertController(title: "Password Reset", message: "Success: Please check your inbox (including junkmail).", preferredStyle: .Alert)
                    //successVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in }))
                    //self.presentViewController(successVC, animated: true, completion: nil)
                })
            } else {
                let errorVC = UIAlertController(title: "Oops..", message: error!.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
                self.sendMeInstructionsCell.isUserInteractionEnabled = true
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
