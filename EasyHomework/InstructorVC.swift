//
//  InstructorVC.swift
//  B4Grad
//
//  Created by ScaRiLiX on 10/14/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit
import Eureka
import MessageUI
import RealmSwift
import Hero

///InstructorVC: class responsible for view-only mode of the instructor

class InstructorVC: FormViewController {

    var instructor: RLMInstructor?
    var course: RLMCourse!
    var type: String!
    var weeklyEditingVC: WeeklyEditingTableViewController?
    
    fileprivate func buildForm() {
        form +++ Section()
            <<< InstructorViewingModeInfoRow() { row in
                row.value = instructor
                }.cellUpdate({ (cell, row) in
                    cell.delegate = self
                    row.value = self.instructor
                })
            +++ Section("Contact") { section in
                
                if let location = self.instructor?.location, !location.isEmpty
                {
                    section <<< InstructorContactRow() { row in
                        row.value = location
                        }.cellUpdate({ (cell, row) in
                            row.value = location
                            cell.infoType = .location
                        }).cellSetup({ (cell, row) in
                            row.value = location
                            cell.infoType = .location
                        })
                }
                
                if let hours = self.instructor?.hours, !hours.isEmpty
                {
                    section <<< LabelRow() { row in
                        row.title = "Hours"
                        row.value = hours
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = .white
                            row.value = hours
                        })
                }
                self.instructor?.emails.enumerated().forEach { (index, email) in
                    section <<< InstructorContactRow() { row in
                        row.value = email
                        }.cellUpdate({ (cell, row) in
                            row.value = email
                            cell.infoType = .email
                        }).cellSetup({ (cell, row) in
                            row.value = email
                            cell.infoType = .email
                        })
                }
                
                self.instructor?.phonenumbers.enumerated().forEach { (index, phonenumber) in
                    section <<< InstructorContactRow() { row in
                        row.value = phonenumber
                        }.cellUpdate({ (cell, row) in
                            row.value = phonenumber
                            cell.infoType = .phoneNumber
                        }).cellSetup({ (cell, row) in
                            row.value = phonenumber
                            cell.infoType = .phoneNumber
                        })
                }
                
                self.instructor?.websites.enumerated().forEach { (index, website) in
                    section <<< InstructorContactRow() { row in
                        row.value = website
                        }.cellUpdate({ (cell, row) in
                            row.value = website
                            cell.infoType = .website
                        }).cellSetup({ (cell, row) in
                            row.value = website
                            cell.infoType = .website
                        })
                }
            }
            <<< InstructorNoteRow() { row in
                row.value = instructor
                }.cellUpdate({ (cell, row) in
                    row.value = self.instructor
                }).cellSetup({ (cell, row) in
                    row.value = self.instructor
                    cell.notesTextView.delegate = self
                })
        
        form.allRows.forEach { $0.baseCell.backgroundColor = #colorLiteral(red: 0.08341478556, green: 0.0834178254, blue: 0.08341617137, alpha: 1) }
        form.allRows.forEach {
            $0.baseCell.selectedBackgroundView = UIView()
            $0.baseCell.selectedBackgroundView?.backgroundColor = UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tableView.separatorColor = #colorLiteral(red: 0.4977670276, green: 0.5461138019, blue: 0.5126940554, alpha: 0.4513739224)
        navigationItem.title = "Instructor"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(switchToEditing))
        
        buildForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        form.removeAll()
        buildForm()
    }
    
    @objc func switchToEditing()
    {
        let editInstructorVC = InstructorEditingModeVC()
        editInstructorVC.editingMode = .editing
        editInstructorVC.instructor = self.instructor
        editInstructorVC.course = self.course
        editInstructorVC.type = self.type
        editInstructorVC.weeklyEditingVC = self.weeklyEditingVC
        self.navigationController?.fade(to: editInstructorVC)
    }
}

extension InstructorVC: ContactActionsDelegate
{
    func call(_ number: String) {
        if number.isValid(regex: .phone)
        {
            if number.canCall() { number.call() }
            else
            {
                let alert = UIAlertController(title: "Oops", message: "Sorry, Can't Call at the moment...", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            let alert = UIAlertController(title: "Number is invalid", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func text(_ number: String) {
        if MFMessageComposeViewController.canSendText()
        {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            controller.recipients = [number]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Oops", message: "Sorry, you can't send a text at the moment", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func email(_ email: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            present(mail, animated: true)
        } else {
            // show failure alert
            let alert = UIAlertController(title: "Oops", message: "Sorry, you can't send an email at the moment", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func website(_ website: String) {
        if let url = URL(string: website)
        {
            UIApplication.shared.openURL(url)
        }
        else
        {
            let alert = UIAlertController(title: "Not a valid URL", message: "Sorry, but the used website text is not a valid URL", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}


//MARK:- Texting Extension

extension InstructorVC: MFMessageComposeViewControllerDelegate
{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Emailing Extension

extension InstructorVC: MFMailComposeViewControllerDelegate
{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

//MARK:- Call extension

// Fetched from here: https://stackoverflow.com/questions/40078370/how-to-make-phone-call-in-ios-10-using-swift/40079079

extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func canCall() -> Bool
    {
        if let url = URL(string: "tel://\(self.onlyDigits())")
        {
            return UIApplication.shared.canOpenURL(url)
        }
        else
        {
            return false
        }
    }
    
    func call() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

//MAKR:- Notes Textview delegate
extension InstructorVC: UITextViewDelegate
{
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = textView.text.count > 0
        }
        instructor?.add(notes: textView.text)
    }
}
