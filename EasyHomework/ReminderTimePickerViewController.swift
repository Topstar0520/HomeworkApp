//
//  ReminderTimePickerViewController.swift
//  B4Grad
//
//  Created by Pratik Patel on 1/9/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

protocol TimeSelectedDelegate {
    func didselectDate(selectedArray : [NSMutableDictionary])
}

class ReminderTimePickerViewController: UIViewController {
    
    var delegate : TimeSelectedDelegate?
    @IBOutlet var noStartTimeButton: UIButton!
    @IBOutlet var datePickerView: CustomDatePickerView!
    @IBOutlet var doneEditingButton: UIButton!
    @IBOutlet var informationalLabel: UILabel!
    @IBOutlet var informationalButton: UIButton!
    
    var selectedID : Int!
    var selectedName : String!
    var selectedArray : [NSMutableDictionary]!
    
    var task: RLMTask!
    var homeVC: HomeworkViewController? //if relevant
    var taskManager: UIViewController? //if relevant
    var cellEditingVC: CellEditingTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.iPhone4SLandscapeHandler()
        self.doneEditingButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .selected)
        self.doneEditingButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .highlighted)
        
        let gregorian = Calendar(identifier: .gregorian)
        var date = Date()
        
        //let date = self.task.dueDate!
        var selectedDate : Date? = nil
        for dict in selectedArray {
            let rowId = dict.value(forKey: "Id") as! Int
            if rowId == selectedID {
                selectedDate = dict.value(forKey: "date") as? Date
                break
            }
        }
        
        
        //let now = Date()
        //var nowComponents = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date as Date)
        components.hour = 9
        components.minute = 0
        components.second = 0
        let sameDateAsTaskAndBeginningOfCurrentHour = gregorian.date(from: components)!
        
        if selectedDate != nil {
            self.datePickerView.date = selectedDate!
        } else {
            self.datePickerView.setDate(sameDateAsTaskAndBeginningOfCurrentHour, animated: false)
        }
        
        self.title = (self.datePickerView.date as NSDate).toReadableTimeString()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.StartTimePickerValueChanged(self) //handles taking the datePickerView's time and saving it.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let timeCell = cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? StartTimeTableViewCell
        //Fixes bug where the cell remains unselected after setting a date.
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.0)
        timeCell?.selectedBackgroundView = selectedBackgroundView
    }
    
    //The methods used in the below IBActions are essentially C&P'd from DueDateVC with minor modifications.
    @IBAction func StartTimePickerValueChanged(_ sender: Any) {
        self.title = (self.datePickerView.date as NSDate).toReadableTimeString()
    }
    
    @IBAction func noStartTimeButtonTouchUpInside(_ sender: Any) {
        self.title = "Confirm Cancellation"
    }
    
    @IBAction func doneBtnTouchUpInside(_ sender: Any) {
        let senderButton = sender as? UIButton
        senderButton?.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .normal)
        
        if self.title == "Confirm Cancellation" {
            for dict in selectedArray {
                let rowId = dict.value(forKey: "Id") as! Int
                if rowId == selectedID {
                    selectedArray.removeObject(object: dict)
                    break
                }
            }
        } else {
            for dict in selectedArray {
                let rowId = dict.value(forKey: "Id") as! Int
                if rowId == selectedID {
                    selectedArray.removeObject(object: dict)
                    break
                }
            }
            let dict = NSMutableDictionary()
            dict.setValue(selectedID, forKey: "Id")
            dict.setValue(selectedName + "  (\((self.datePickerView.date as NSDate).toReadableTimeString()))", forKey: "name")
            dict.setValue(self.datePickerView.date, forKey: "date")
            selectedArray.append(dict)
            
            
        }
        self.navigationController?.popViewController(animated: true, {
            self.delegate?.didselectDate(selectedArray: self.selectedArray)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func iPhone4SLandscapeHandler() {
        if (UIScreen.main.bounds.size.height == 320) { //fix iPhone 4S layout bug.
            self.noStartTimeButton.isHidden = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if (UIScreen.main.bounds.size.height == 320) { //fix iPhone 4S layout bug.
            self.noStartTimeButton.isHidden = true
        } else if (UIScreen.main.bounds.size.height == 480) {
            self.noStartTimeButton.isHidden = false
        }
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
