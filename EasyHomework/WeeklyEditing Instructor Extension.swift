//
//  WeeklyEditing Extension.swift
//  B4Grad
//
//  Created by ScaRiLiX on 10/15/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import RealmSwift
import Foundation
import MessageUI

extension WeeklyEditingTableViewController
{
    func fetchInstructors()
    {
        //instructors = course.instructors
        //insertInstructorsRowInDictionary()
        //tableView.reloadData()
        //insertInstructorsRowInDictionary()
    }
    
    /*func insertInstructorsRowInDictionary()
    {
        dictionary[2] = [ ScheduleRowContent(identifier: "NewInstructorCell") ]
        //dictionary[2] = dictionary[2]!.filter { $0.identifier != "InstructorCell" }
        var counter = 1
        for instructor in self.instructors {
            let InstructorCell = ScheduleRowContent(identifier: "InstructorCell")
            dictionary[2]!.insert(InstructorCell, at: counter)
            counter += 1
        }
    }*/
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cellContent = dictionary[indexPath.section]![indexPath.row]
        return cellContent.identifier == "InstructorCell"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            let instructor = self.dictionary[2]![indexPath.row].instructor
            
            tableView.beginUpdates()
            let realm = try! Realm()
            realm.beginWrite()
            realm.delete(instructor!)
            do {
                try realm.commitWrite()
            } catch let error {
                print(error.localizedDescription)
            }
            
            self.dictionary[2]!.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .left)
            //fetchInstructors()
            tableView.endUpdates()
        }
    }
}


extension WeeklyEditingTableViewController: ContactActionsDelegate
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
            if UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.openURL(url)
            }
            else
            {
                let alert = UIAlertController(title: "Oops", message: "Sorry, you can't send an email at the moment", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                present(alert, animated: true, completion: nil)
            }
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

extension WeeklyEditingTableViewController: MFMessageComposeViewControllerDelegate
{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Emailing Extension

extension WeeklyEditingTableViewController: MFMailComposeViewControllerDelegate
{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
