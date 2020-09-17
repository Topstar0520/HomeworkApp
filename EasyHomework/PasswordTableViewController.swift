//
//  PasswordTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-07-04.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse

class PasswordTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var passwordTextField: B4GradTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
        if (cell.contentView.backgroundColor != UIColor.clear) {
            cell.backgroundColor = cell.contentView.backgroundColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.endEditing(true)
    }

    var passwordSaving = false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (passwordSaving == true) { return false }
        passwordSaving = true
        let user = PFUser.current()!
        user.password = self.passwordTextField.text
        user.saveInBackground(block: { (succeed, error) -> Void in
            if (error == nil) {
                PFUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: { (succeed, error) -> Void in
                    if (error == nil) {
                        self.passwordSaving = false
                        textField.resignFirstResponder()
                    } else {
                        self.passwordSaving = false
                        let errorVC = UIAlertController(title: "Success", message: "We recommend that you restart your application and login again.", preferredStyle: .alert)
                        errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                        self.present(errorVC, animated: true, completion: nil)
                    }
                })
            } else {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error!.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
        })
        return false
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
