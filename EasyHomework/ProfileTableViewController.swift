//
//  ProfileTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-14.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse
import MessageUI
import RealmSwift

class ProfileTableViewController: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    //var cells = ["ProfileImageTableViewCell", "EmailTableViewCell", "PasswordTableViewCell"]
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTableViewCell: PasswordTableViewCell!
    @IBOutlet var backgroundTableViewCell: BackgroundTableViewCell!
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var remindersTableViewCell: UITableViewCell!
    @IBOutlet var subscriptionStatusTableViewCell: UITableViewCell!
    @IBOutlet var subscriptionStatusLabel: UILabel!
    @IBOutlet weak var subscriptionStatusImageView: UIImageView!
    @IBOutlet weak var gradlockerTableViewCell: GradLockerTableViewCell!
    
    
    @IBOutlet var lockBtnOnBackgroundTableViewCell: UIButton!
    @IBOutlet var lockBtnOnRemindersTableViewCell: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        //self.tableView.estimatedRowHeight = 140
        //self.tableView.rowHeight = UITableViewAutomaticDimension
        self.emailTextField.delegate = self
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Ex) jbob2@uwo.ca", attributes: [ NSAttributedStringKey.foregroundColor : UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.3) ])
        self.emailTextField.text = PFUser.current()!.email
        self.usernameLabel.text = PFUser.current()?.object(forKey: "displayName") as? String
        
        if (UserDefaults.standard.bool(forKey: "isSubscribed") == true) {
            lockBtnOnBackgroundTableViewCell.isHidden = true
            lockBtnOnRemindersTableViewCell.isHidden = true
            subscriptionStatusLabel.text = "You are currently using B4Grad Premium!"
            subscriptionStatusImageView.image = UIImage(named: "B4Grad App Icon Alternate - With Gold Star")
            backgroundTableViewCell.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator"))
            remindersTableViewCell.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator"))
            gradlockerTableViewCell.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator"))
            subscriptionStatusTableViewCell.isUserInteractionEnabled = false
        } else {
            //backgroundTableViewCell.accessoryType = .none
            //remindersTableViewCell.accessoryType = .none
            lockBtnOnBackgroundTableViewCell.isHidden = true
            lockBtnOnRemindersTableViewCell.isHidden = true
            subscriptionStatusLabel.text = "You are currently using a Free Trial. Subscribe Now!"
            backgroundTableViewCell.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator"))
            remindersTableViewCell.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator"))
            gradlockerTableViewCell.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator"))
            
            subscriptionStatusTableViewCell.accessoryType = .disclosureIndicator
            subscriptionStatusTableViewCell.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator"))
            
        }
        
        passwordTableViewCell.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator"))
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.doneBarButtonItem.isEnabled = false
        self.tableView.allowsSelection = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let user = PFUser.current()!
        user.email = self.emailTextField.text
        user.username = self.emailTextField.text
        user.saveInBackground(block: { (succeed, error) -> Void in
            if (error == nil) {
                textField.resignFirstResponder()
            } else {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error!.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
        })
        //Show loading indicator and then a response. If successful, then resignFirstResponder. Otherwise tell the user their changes could not be saved.
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.doneBarButtonItem.isEnabled = true
        self.tableView.allowsSelection = true
    }

    @IBAction func doneBarButtonItemTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: { })
    }
    
    @IBAction func logOutButtonItemTapped(_ sender: AnyObject) {
        let logOutBarButton = sender as! UIBarButtonItem
        logOutBarButton.isEnabled = false
        //Show loading indicator.
        PFUser.logOutInBackground(block: {(error) -> Void in
            if (error == nil) {
                logOutBarButton.isEnabled = true
                self.dismiss(animated: true, completion: nil)
            } else {
                logOutBarButton.isEnabled = true
                let errorVC = UIAlertController(title: "Oops..", message: "You Cannot Log Out at the Moment.", preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            
        })
    }
    
    
    @IBAction func changeUsernameButtonTapped(_ sender: AnyObject) {
        let alertVC = UIAlertController(title: "Change Username", message: "", preferredStyle: .alert)
        //alertVC.addTextFieldWithConfigurationHandler({ textField in textField.placeholder = NSLocalizedString("University", comment: "University")})
        alertVC.addTextField(configurationHandler: { textField in textField.placeholder = NSLocalizedString("Username", comment: "Username")
            textField.text = PFUser.current()?.object(forKey: "displayName") as? String
            textField.keyboardType = .asciiCapable
            textField.keyboardAppearance = .dark
            textField.autocapitalizationType = .words
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in }))
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let usernameString = alertVC.textFields?.last?.text
            if (usernameString!.length < 5 || usernameString!.length > 17) {
                let errorVC = UIAlertController(title: "Oops..", message: "Your display name must be atleast 5 letters long.", preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in }))
                self.present(errorVC, animated: true, completion: { })
                return
            }
            if (Int(String(usernameString!.characters.first!)) != nil) {
                let errorVC = UIAlertController(title: "Oops..", message: "Your display name must begin with a letter.", preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in }))
                self.present(errorVC, animated: true, completion: { })
                return
            }
            let user = PFUser.current()!
            user.setObject(usernameString!, forKey: "displayName")
            //Update displayname as long as it is valid, otherwise display an error.
            user.saveInBackground(block: { (succeed, error) -> Void in
                if (error == nil) {
                    self.usernameLabel?.text = usernameString
                    let confirmVC = UIAlertController(title: "Success.", message: "Your Username has been updated!", preferredStyle: .alert)
                    confirmVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in }))
                    self.present(confirmVC, animated: true, completion: { })
                } else {
                    let errorVC = UIAlertController(title: "Oops..", message: error!.localizedDescription, preferredStyle: .alert)
                    errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in }))
                    self.present(errorVC, animated: true, completion: { })
                    return
                }
            })
        }))
        self.present(alertVC, animated: true, completion: { })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*cell.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
        if (cell.contentView.backgroundColor != UIColor.clear) {
            cell.backgroundColor = cell.contentView.backgroundColor
        }*/
        cell.contentView.backgroundColor = nil //since iOS13
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        if self.subscriptionStatusTableViewCell.isSelected {
            if (UserDefaults.standard.bool(forKey: "isSubscribed") == true) {
                cell?.setSelected(false, animated: true)
            } else {
                let storyboard = UIStoryboard(name: "Subscription", bundle: nil)
                let subscriptionPlansVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlansViewController")
                self.present(subscriptionPlansVC, animated: true, completion: nil)
                cell?.setSelected(false, animated: true)
            }
        }
        
        if let backgroundCell = cell as? BackgroundTableViewCell {
            //if (UserDefaults.standard.bool(forKey: "isSubscribed") == true) {
                let storyboard = UIStoryboard(name: "Profile", bundle: nil)
                let backgroundVC = storyboard.instantiateViewController(withIdentifier: "CustomBackgroundViewController")
                self.navigationController!.pushViewController(backgroundVC, animated: true)
            /*} else {
                let storyboard = UIStoryboard(name: "Subscription", bundle: nil)
                let subscriptionPlansVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlansViewController")
                self.present(subscriptionPlansVC, animated: true, completion: nil)
                cell?.setSelected(false, animated: true)
            }*/
        }
        
        if let shopCell = cell as? GradLockerTableViewCell {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            //let backgroundVC = storyboard.instantiateViewController(withIdentifier: "CustomBackgroundViewController")
            //self.navigationController!.pushViewController(backgroundVC, animated: true)
            UIApplication.shared.open(URL(string: "https://mygradlocker.com")!, options: [:], completionHandler: nil)
            
            //let webVC = storyboard.instantiateViewController(withIdentifier: "WKWebViewController")
            //self.navigationController!.pushViewController(webVC, animated: true)
            
            cell?.setSelected(false, animated: true)
        }
        
        if let remindersCell = cell as? ReminderSettingsTableViewCell {
            //if (UserDefaults.standard.bool(forKey: "isSubscribed") == true) {
                let storyboard = UIStoryboard(name: "Profile", bundle: nil)
                let remindersVC = storyboard.instantiateViewController(withIdentifier: "RemindersSettingsTableViewController")
                self.navigationController!.pushViewController(remindersVC, animated: true)
            /*} else {
                let storyboard = UIStoryboard(name: "Subscription", bundle: nil)
                let subscriptionPlansVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlansViewController")
                self.present(subscriptionPlansVC, animated: true, completion: nil)
                cell?.setSelected(false, animated: true)
            }*/
        }
        
        if (cell?.reuseIdentifier == "ReviewTableViewCell") {
            let now = Date()
            let thirtyDaysBeforeNow = Calendar.current.date(byAdding: .day, value: -30, to: now)!
            let realm = try! Realm()
            let tasksCount = realm.objects(RLMTask.self).filter("scope = 'Regular' AND createdDate >= %@", thirtyDaysBeforeNow).count
            if (tasksCount < 3 || UserDefaults.standard.bool(forKey: "isSubscribed") == true) {
                if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "id1352751059") {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)

                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            cell?.setSelected(false, animated: true)
            /*if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }*/
        }
        
        if (cell?.reuseIdentifier == "ShareTableViewCell") {
            let text = "Hey all, want to stop procrastinating on homework? Try B4Grad on the app store at www.B4Grad.com"
            let textShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
            cell?.setSelected(false, animated: true)
        }
        
        if (cell?.reuseIdentifier == "FeedbackTableViewCell") {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["contact@b4grad.com"])
                mail.setSubject("Could you help me with this..")
                //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

                present(mail, animated: true) //does not work in simulator
            } else {
                // show failure alert
            }
            cell?.setSelected(false, animated: true)
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    
    // MARK: - Table view data source

    /*override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
     
     
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (cells[indexPath.row] == "ProfileImageTableViewCell") {
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileImageTableViewCell", forIndexPath: indexPath) as! ProfileImageTableViewCell
            
            
            return cell
        }
        
        if (cells[indexPath.row] == "EmailTableViewCell") {
            let cell = tableView.dequeueReusableCellWithIdentifier("EmailTableViewCell", forIndexPath: indexPath) as! EmailTableViewCell
            
            
            return cell
        }
        
        if (cells[indexPath.row] == "PasswordTableViewCell") {
            let cell = tableView.dequeueReusableCellWithIdentifier("PasswordTableViewCell", forIndexPath: indexPath) as! PasswordTableViewCell
            
            
            return cell
        }
        
        return UITableViewCell()
    }*/
    

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
