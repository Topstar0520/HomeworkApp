//
//  TimePickerViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-08-27.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

class TimePickerViewController: UIViewController {

    @IBOutlet var datePicker: CustomDatePickerView!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    var selectedDay: String!
    var weeklyEditingTVC: WeeklyEditingTableViewController!
    var weekdayCellIndex = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.weekdayCellIndex = self.weeklyEditingTVC.weekdayCellIndex
        
        self.confirmButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .selected)
        self.confirmButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .highlighted)
        self.cancelButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .selected)
        self.cancelButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .highlighted)
        
        //let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(sender:)))
        //self.navigationController?.navigationBar.topItem?.rightBarButtonItem = cancelButton
        
        if (self.title == "Start Time") {
            if (weeklyEditingTVC.dictionary[weekdayCellIndex]![1].timeArray![weeklyEditingTVC.indexOfLastTimeButtonTapped!] != Date(timeIntervalSince1970: 0)) {
                self.datePicker.date = weeklyEditingTVC.dictionary[weekdayCellIndex]![1].timeArray![weeklyEditingTVC.indexOfLastTimeButtonTapped!]
            } else {
                var dateComponents = DateComponents()
                dateComponents.hour = 7
                dateComponents.minute = 00
                dateComponents.second = 00
                self.datePicker.date = Calendar.current.date(from: dateComponents)!
            }
        } else {
            if (weeklyEditingTVC.dictionary[weekdayCellIndex]![2].timeArray![weeklyEditingTVC.indexOfLastTimeButtonTapped!] != Date(timeIntervalSince1970: 0)) {
                self.datePicker.date = weeklyEditingTVC.dictionary[weekdayCellIndex]![2].timeArray![weeklyEditingTVC.indexOfLastTimeButtonTapped!]
            } else {
                ///self.datePicker.date = weeklyEditingTVC.dictionary[2]![1].timeArray![weeklyEditingTVC.indexOfLastTimeButtonTapped!]
                let startDateTime = weeklyEditingTVC.dictionary[weekdayCellIndex]![1].timeArray![weeklyEditingTVC.indexOfLastTimeButtonTapped!]
                let calendar = Calendar(identifier: .gregorian)
                let endDateTime = calendar.date(byAdding: .hour, value: 1, to: startDateTime, wrappingComponents: false)
                self.datePicker.date = endDateTime!
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func cancel(sender: Any?) {
        //self.dismiss(animated: true, completion: {  })
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmTouchUpInside(_ sender: Any) {
        var pickerDate = self.datePicker.date
        var pickerDay = pickerDate.dayName()
        while (pickerDay != selectedDay) {
            pickerDate = pickerDate.addComponent(component: .day, withValue: 1)
            pickerDay = pickerDate.dayName()
        }
        
        
        let senderButton = sender as? UIButton
        senderButton?.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .normal)
        let section = weekdayCellIndex //3
        var row: Int!
        if (self.title == "Start Time") {
            row = 1
        } else {
            row = 2
        }
        self.weeklyEditingTVC.tableView.beginUpdates()
        if (self.weeklyEditingTVC.indexOfLastTimeButtonTapped != nil) {
            self.weeklyEditingTVC.dictionary[section]![row].timeArray![self.weeklyEditingTVC.indexOfLastTimeButtonTapped!] = pickerDate//self.datePicker.date
        }
        if (self.weeklyEditingTVC.dictionary[section]!.count == 3) {
            self.weeklyEditingTVC.dictionary[section]?[2].toggleArray?[self.weeklyEditingTVC.indexOfLastTimeButtonTapped!] = true
            self.weeklyEditingTVC.tableView.reloadRows(at: [IndexPath(row: 2, section: section)], with: .none)
        }
        self.weeklyEditingTVC.tableView.reloadRows(at: [IndexPath(row: 1, section: section)], with: .none)
        if (self.weeklyEditingTVC.dictionary[section]?.count == 2) {
            let newWeeklyEndTimeRow = ScheduleRowContent(identifier: "WeeklyEndTimeCell", defaultToggleArray: [false, false, false, false, false], usesTimeArray: true)
            newWeeklyEndTimeRow.toggleArray?[self.weeklyEditingTVC.indexOfLastTimeButtonTapped!] = true
            self.weeklyEditingTVC.dictionary[section]!.insert(newWeeklyEndTimeRow, at: 2)
            self.weeklyEditingTVC.tableView.insertRows(at: [IndexPath(row: 2, section: section)], with: .top)
        }
        self.weeklyEditingTVC.tableView.endUpdates()
        
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelTouchUpInside(_ sender: Any) {
        let senderButton = sender as? UIButton
        senderButton?.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .normal)
        self.cancel(sender: sender)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
