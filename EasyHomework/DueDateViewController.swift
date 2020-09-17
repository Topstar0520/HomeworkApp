//
//  DueDateViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-23.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class DueDateViewController: UIViewController {

    @IBOutlet var noDueDateButton: UIButton!
    @IBOutlet var datePickerView: CustomDatePickerView!
    var semesterDates = [String:Array<Date>]()
    var minimumDate : Date!
    var maximumDate : Date!
    @IBOutlet var doneEditingButton: UIButton!
    @IBOutlet var informationalLabel: UILabel!
    @IBOutlet var informationalButton: UIButton!
    
    var task: RLMTask!
    var homeVC: HomeworkViewController? //if relevant
    var taskManager: UIViewController? //if relevant
    var cellEditingVC: CellEditingTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.iPhone4SLandscapeHandler()
        self.doneEditingButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .selected)
        self.doneEditingButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .highlighted)
        self.determineMinAndMaxDatesForSemester()
        self.minimumDate = self.semesterDates["Summer"]![0] //temporary.
        self.maximumDate = self.semesterDates["Summer"]![1] //temporary.
        //Get maximum & minimum dates for semester from the course.
        
        self.informationalLabel.isHidden = true
        self.informationalButton.isHidden = true
        if (self.task.dueDate == nil) {
            //self.title = "No Due Date"
            //if (self.task.timeSet == false) {
            self.datePickerView.setDate(Date(), animated: false)
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.long
            let dateString = formatter.string(from: self.datePickerView.date)
            self.title = dateString
        } else {
            self.datePickerView.setDate(self.task.dueDate! as Date, animated: false)
            self.title = self.task.dueDate!.toReadableString()
            if (self.datePickerView.date.overScopeThreshold(task: self.task)) {
                self.updateInformationalLabelText()
                self.informationalLabel.isHidden = false
                self.informationalButton.isHidden = false
            }
        }
        
        self.noDueDateButton.setTitle("This " + self.task.type + " has no due date?", for: UIControlState.normal)

        //self.datePickerView.minimumDate = self.minimumDate
        //self.datePickerView.maximumDate = self.maximumDate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.datePickerValueChanged(self) //handles taking the datePickerView's time and saving it.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let dueDateCell = cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DueDateTableViewCell
        //Fixes bug where the cell remains unselected after setting a date.
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.0)
        dueDateCell?.selectedBackgroundView = selectedBackgroundView
        //
        if (self.task.dueDate == nil) {
            if (self.task.type == "Assignment") {
                dueDateCell?.dueDateLabel.text = "Due Date"
            } else {
                dueDateCell?.dueDateLabel.text = "Date"
            }
            dueDateCell?.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
            dueDateCell?.iconImageView.image = #imageLiteral(resourceName: "CalendarBW")
        } else {
            dueDateCell?.dueDateLabel.text = self.task.dueDate?.toReadableString()
            dueDateCell?.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            dueDateCell?.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func datePickerValueChanged(_ sender: AnyObject) {
        if (self.cellEditingVC?.helperObject is HomeworkCellEditingHelperObject) {
            self.datePickerValueChanged_Using_HomeworkHelper()
        }
        if (self.cellEditingVC?.helperObject is SchedulesCellEditingHelperObject) {
            self.datePickerValueChanged_Using_SchedulesHelper()
        }
        if (self.cellEditingVC?.helperObject is WeeklyCellEditingHelperObject) {
            self.datePickerValueChanged_Using_WeeklyHelper()
        }
        
        //Add any additional VCs using a CellEditing Helper.
    }
    
    @IBAction func noDueDateButtonTouchUp(_ sender: AnyObject) {
        if (self.cellEditingVC?.helperObject is HomeworkCellEditingHelperObject) {
            self.noDueDateButtonTouchUp_Using_HomeworkHelper()
        }
        if (self.cellEditingVC?.helperObject is SchedulesCellEditingHelperObject) {
            self.noDueDateButtonTouchUp_Using_SchedulesHelper()
        }
        if (self.cellEditingVC?.helperObject is WeeklyCellEditingHelperObject) {
            self.noDueDateButtonTouchUp_Using_WeeklyHelper()
        }
        
        //Add any additional VCs using a CellEditing Helper.
    }
    
    func datePickerValueChanged_Using_HomeworkHelper() {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        let dateString = formatter.string(from: self.datePickerView.date)
        self.title = dateString
        let oldDate = self.task.dueDate
        
        if (self.datePickerView.date.overScopeThreshold(task: self.task)) {
            self.updateInformationalLabelText()
            self.informationalLabel.isHidden = false
            self.informationalButton.isHidden = false
            //(self.cellEditingVC?.homeVC != nil)'s purpose is to check if the Agenda (Home) is where cellEditingVC came from. If SchedulesViewController is where cellEditingVC came from, then DO NOT execute what is in this if statement.
            if (self.cellEditingVC?.helperObject.taskManagerVC == nil) { print("ERROR IN datePickerValueChanged(..) & noDueDateButtonTouchUp of DueDateVC") }
            if (self.cellEditingVC?.helperObject.mode == .Edit && self.cellEditingVC?.helperObject.taskManagerVC is HomeworkViewController) {
                //Now let's set the task dateOfExtension to != nil.
                let realm = try! Realm()
                realm.beginWrite()
                self.task.dateOfExtension = Date() as NSDate
                do {
                    try realm.commitWrite()
                } catch let error {
                    let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                    errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                    self.present(errorVC, animated: true, completion: nil)
                }
            }
        } else {
            self.informationalLabel.isHidden = true
            self.informationalButton.isHidden = true
        }
        
        //update dueDateCell in CellEditingVC
        let dueDateCell = cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DueDateTableViewCell
        dueDateCell?.dueDateLabel.text = (self.datePickerView.date as NSDate).toReadableString()
        dueDateCell?.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        dueDateCell?.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
        if (self.cellEditingVC?.helperObject.dictionary[0]?.count == 2) {
            //Insert StartTime Cell.
            self.cellEditingVC?.helperObject.dictionary[0]?.insert(ScheduleRowContent(identifier: "StartTimeCell"), at: 2)
            self.cellEditingVC?.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .none)
            //Insert Repeats Cell.
            //Crash
           //self.insertRepeatsCell()
        }
        
        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.dueDate = self.datePickerView.date as NSDate
            if (self.task.timeSet == false) {
                self.task.dueDate = self.datePickerView.date.convertToLatestPossibleTimeOfDay() as NSDate
            }
            if (self.task.endDateAndTime != nil) {
                self.task.endDateAndTime = (self.task.endDateAndTime! as Date).useSameDayAs(correctDate: self.datePickerView.date as Date) as NSDate
            }
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }
        
        let origIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        let cell = self.homeVC?.tableView.cellForRow(at: origIndexPathOfHWCell!) as? HomeworkTableViewCell
        
        //Add Extended Section if needed.
        self.homeVC?.tableView.beginUpdates()
        if (self.datePickerView.date.overScopeThreshold(task: self.task) == true && self.homeVC?.extendedTasks.count == 0) { //&& self.homeVC?.extendedTasks.count == 0
            if self.homeVC?.sections.first(where: { $0 == "Extended" }) == nil && self.homeVC?.sections.first(where: { $0 == "Completed Today" }) == nil {
                self.homeVC?.sections.insert("Extended", at: 1)
                self.homeVC?.tableView.insertSections([1], with: .automatic)
            } else if self.homeVC?.sections.first(where: { $0 == "Extended" }) == nil && self.homeVC?.sections.first(where: { $0 == "Completed Today" }) != nil {
                self.homeVC?.sections.insert("Extended", at: 2)
                self.homeVC?.tableView.insertSections([2], with: .automatic)
            }
        }
        self.homeVC?.tableView.endUpdates()
        //
        
        //move and reload rows at the same time not possible, so I manually edited the cell http://stackoverflow.com/a/9642438/6051635
        //this behaviour also occurs in the method below.
        
        //if cell is nil, we could reload it here since cell? would be nil. But I don't think it is needed, since the cell would be selected. (thus stored in memory of UITableView possibly)
        
        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()
        
        //var tempDueDate: NSDate?
        //if (self.task.dueDate != nil) { tempDueDate = self.task.dueDate }
        
        let realm = try! Realm()
        realm.beginWrite()
        self.task.dueDate = self.datePickerView.date as NSDate?
        if (self.task.timeSet == false) {
            self.task.dueDate = self.datePickerView.date.convertToLatestPossibleTimeOfDay() as NSDate
        }
        if (self.task.endDateAndTime != nil) {
            self.task.endDateAndTime = (self.task.endDateAndTime! as Date).useSameDayAs(correctDate: self.datePickerView.date as Date) as NSDate
        }
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        /*if (tempDueDate != nil && origIndexPathOfHWCell?.section == 0 && self.task.tempVisible == false)  {
            if (self.task.scope == "Event") {
                self.task.tempDueDate = tempDueDate!
            }
        }*/
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        
        //Handle Events that had their dueDates changed to sometime in the past.
        /*if (self.task.scope == "Event") {
            //Events in Agenda that take place in the past should always be in Agenda View, therefore should always be tempVisible = true.
            if (self.cellEditingVC?.helperObject.homeVC?.indexOfTask(task: self.task) == nil && self.task.tempVisible == false) {
                let realm = try! Realm()
                realm.beginWrite()
                self.task.tempVisible = true
                //self.task.dateOfExtension = nil
                do {
                    try realm.commitWrite()
                } catch let error {}
            }
        }*/
        //
        
        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell != nil && indexPathOfHWCell != nil) {
            self.homeVC?.tableView.moveRow(at: origIndexPathOfHWCell!, to: indexPathOfHWCell!)
        }
        self.homeVC?.heightAtIndexPath.removeValue(forKey: indexPathOfHWCell!)
        
        //If the task is no longer extended.
        if (self.task.dateOfExtension != nil && self.datePickerView.date.overScopeThreshold(task: self.task) == false) {
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dateOfExtension = nil
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
        }
        
        //Remove Extended Section if needed.
        self.homeVC?.tableView.beginUpdates()
        if (self.homeVC?.extendedTasks.count == 0) {
            if let extendedTasksSection = self.homeVC!.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.homeVC!.sections.index(of: extendedTasksSection)!
                self.homeVC!.sections.removeObject(object: extendedTasksSection)
                self.homeVC!.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.homeVC?.tableView.endUpdates()
        //
    }
    
    func datePickerValueChanged_Using_SchedulesHelper() {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        let dateString = formatter.string(from: self.datePickerView.date)
        self.title = dateString
        let oldDate = self.task.dueDate
        
        if (self.datePickerView.date.overScopeThreshold(task: self.task)) {
            self.updateInformationalLabelText()
            self.informationalLabel.isHidden = false
            self.informationalButton.isHidden = false
            //(self.cellEditingVC?.homeVC != nil)'s purpose is to check if the Agenda (Home) is where cellEditingVC came from. If SchedulesViewController is where cellEditingVC came from, then DO NOT execute what is in this if statement.
            if (self.cellEditingVC?.helperObject.taskManagerVC == nil) { print("ERROR IN datePickerValueChanged(..) & noDueDateButtonTouchUp of DueDateVC") }
        } else {
            self.informationalLabel.isHidden = true
            self.informationalButton.isHidden = true
        }
        let scheduleEditorVC = self.taskManager as! ScheduleEditorViewController
        if (scheduleEditorVC.indexOfTask(task: task) != nil) {
            let hwCellInScheduleEditor = scheduleEditorVC.tableView.cellForRow(at: scheduleEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
            scheduleEditorVC.tableView.beginUpdates()
            CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: task, cell: hwCellInScheduleEditor, taskManager: self.taskManager)
            scheduleEditorVC.tableView.endUpdates()
        }
        
        //update dueDateCell in CellEditingVC
        let dueDateCell = cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DueDateTableViewCell
        dueDateCell?.dueDateLabel.text = (self.datePickerView.date as NSDate).toReadableString()
        dueDateCell?.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        dueDateCell?.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
        if (self.cellEditingVC?.helperObject.dictionary[0]?.count == 2) {
            //Insert StartTime Cell.
            self.cellEditingVC?.helperObject.dictionary[0]?.insert(ScheduleRowContent(identifier: "StartTimeCell"), at: 2)
            self.cellEditingVC?.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .none)
            //Insert Repeats Cell.
            self.insertRepeatsCell()
        }
        
        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.dueDate = self.datePickerView.date as NSDate
            if (self.task.timeSet == false) {
                self.task.dueDate = self.datePickerView.date.convertToLatestPossibleTimeOfDay() as NSDate
            }
            if (self.task.endDateAndTime != nil) {
                self.task.endDateAndTime = (self.task.endDateAndTime! as Date).useSameDayAs(correctDate: self.datePickerView.date as Date) as NSDate
            }
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }
        
        let origIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell == nil) { //Task didn't exist HomeVC tableView..
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dueDate = self.datePickerView.date as NSDate?
            if (self.task.timeSet == false) {
                self.task.dueDate = self.datePickerView.date.convertToLatestPossibleTimeOfDay() as NSDate
            }
            if (self.task.endDateAndTime != nil) {
                self.task.endDateAndTime = (self.task.endDateAndTime! as Date).useSameDayAs(correctDate: self.datePickerView.date as Date) as NSDate
            }
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            let newIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
            if (newIndexPathOfHWCell == nil) { return } //..and it still doesn't.
            self.homeVC?.tableView.beginUpdates()
            self.homeVC?.tableView.insertRows(at: [newIndexPathOfHWCell!], with: .fade)
            self.homeVC?.tableView.endUpdates()
            return
        }
        
        let cell = self.homeVC?.tableView.cellForRow(at: origIndexPathOfHWCell!) as? HomeworkTableViewCell
        
        //move and reload rows at the same time not possible, so I manually edited the cell http://stackoverflow.com/a/9642438/6051635
        //this behaviour also occurs in the method below.
        
        //if cell is nil, we could reload it here since cell? would be nil. But I don't think it is needed, since the cell would be selected. (thus stored in memory of UITableView possibly)
        
        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()
        
        let realm = try! Realm()
        realm.beginWrite()
        self.task.dueDate = self.datePickerView.date as NSDate?
        if (self.task.timeSet == false) {
            self.task.dueDate = self.datePickerView.date.convertToLatestPossibleTimeOfDay() as NSDate
        }
        if (self.task.endDateAndTime != nil) {
            self.task.endDateAndTime = (self.task.endDateAndTime! as Date).useSameDayAs(correctDate: self.datePickerView.date as Date) as NSDate
        }
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        
        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell != nil && indexPathOfHWCell != nil) {
            self.homeVC?.tableView.moveRow(at: origIndexPathOfHWCell!, to: indexPathOfHWCell!)
        }
        
        //Delete the task from HomeVC if it is due over two weeks away and not completed.
        if (self.task.completed == false) {
        self.homeVC?.tableView.beginUpdates()
        if (self.datePickerView.date.overScopeThreshold(task: self.task) == true) {
            if (self.task.dateOfExtension == nil) { //(consider) if the dateOfExtension was modified within the last 10 min, don't delete row below.
                self.homeVC?.tableView.deleteRows(at: [origIndexPathOfHWCell!], with: .fade) //use origIndexPath since the task is gone from HomeVC data model.
            }
        }
        self.homeVC?.tableView.endUpdates()
        }
        //
        
        //If the task is no longer extended.
        if (self.task.dateOfExtension != nil && self.datePickerView.date.overScopeThreshold(task: self.task) == false) {
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dateOfExtension = nil
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
        }
        
        //Remove Extended Section if needed.
        self.homeVC?.tableView.beginUpdates()
        if (self.homeVC?.extendedTasks.count == 0) {
            if let extendedTasksSection = self.homeVC!.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.homeVC!.sections.index(of: extendedTasksSection)!
                self.homeVC!.sections.removeObject(object: extendedTasksSection)
                self.homeVC!.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.homeVC?.tableView.endUpdates()
        //
        
    }
    
    func datePickerValueChanged_Using_WeeklyHelper() {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        let dateString = formatter.string(from: self.datePickerView.date)
        self.title = dateString
        let oldDate = self.task.dueDate
        
        if (self.datePickerView.date.overScopeThreshold(task: self.task)) {
            self.updateInformationalLabelText()
            self.informationalLabel.isHidden = false
            self.informationalButton.isHidden = false
            //(self.cellEditingVC?.homeVC != nil)'s purpose is to check if the Agenda (Home) is where cellEditingVC came from. If SchedulesViewController is where cellEditingVC came from, then DO NOT execute what is in this if statement.
            if (self.cellEditingVC?.helperObject.taskManagerVC == nil) { print("ERROR IN datePickerValueChanged(..) & noDueDateButtonTouchUp of DueDateVC") }
        } else {
            self.informationalLabel.isHidden = true
            self.informationalButton.isHidden = true
        }
        let weeklyEditorVC = self.taskManager as! WeeklyEditingTableViewController
        if (weeklyEditorVC.indexOfTask(task: task) != nil) {
            let hwCellInWeeklyEditor = weeklyEditorVC.tableView.cellForRow(at: weeklyEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
            weeklyEditorVC.tableView.beginUpdates()
            CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: task, cell: hwCellInWeeklyEditor, taskManager: self.taskManager)
            weeklyEditorVC.tableView.endUpdates()
        }
        
        //update dueDateCell in CellEditingVC
        let dueDateCell = cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DueDateTableViewCell
        dueDateCell?.dueDateLabel.text = (self.datePickerView.date as NSDate).toReadableString()
        dueDateCell?.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        dueDateCell?.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
        if (self.cellEditingVC?.helperObject.dictionary[0]?.count == 2) {
            //Insert StartTime Cell.
            self.cellEditingVC?.helperObject.dictionary[0]?.insert(ScheduleRowContent(identifier: "StartTimeCell"), at: 2)
            self.cellEditingVC?.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .none)
            //Insert Repeats Cell.
            self.insertRepeatsCell()
        }
        
        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.dueDate = self.datePickerView.date as NSDate
            if (self.task.timeSet == false) {
                self.task.dueDate = self.datePickerView.date.convertToLatestPossibleTimeOfDay() as NSDate
            }
            if (self.task.endDateAndTime != nil) {
                self.task.endDateAndTime = (self.task.endDateAndTime! as Date).useSameDayAs(correctDate: self.datePickerView.date as Date) as NSDate
            }
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }
        
        let origIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell == nil) { //Task didn't exist HomeVC tableView..
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dueDate = self.datePickerView.date as NSDate?
            if (self.task.timeSet == false) {
                self.task.dueDate = self.datePickerView.date.convertToLatestPossibleTimeOfDay() as NSDate
            }
            if (self.task.endDateAndTime != nil) {
                self.task.endDateAndTime = (self.task.endDateAndTime! as Date).useSameDayAs(correctDate: self.datePickerView.date as Date) as NSDate
            }
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            let newIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
            if (newIndexPathOfHWCell == nil) { return } //..and it still doesn't.
            self.homeVC?.tableView.beginUpdates()
            self.homeVC?.tableView.insertRows(at: [newIndexPathOfHWCell!], with: .fade)
            self.homeVC?.tableView.endUpdates()
            return
        }
        
        let cell = self.homeVC?.tableView.cellForRow(at: origIndexPathOfHWCell!) as? HomeworkTableViewCell
        
        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()
        
        let realm = try! Realm()
        realm.beginWrite()
        self.task.dueDate = self.datePickerView.date as NSDate?
        if (self.task.timeSet == false) {
            self.task.dueDate = self.datePickerView.date.convertToLatestPossibleTimeOfDay() as NSDate
        }
        if (self.task.endDateAndTime != nil) {
            self.task.endDateAndTime = (self.task.endDateAndTime! as Date).useSameDayAs(correctDate: self.datePickerView.date as Date) as NSDate
        }
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        
        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell != nil && indexPathOfHWCell != nil) {
            self.homeVC?.tableView.moveRow(at: origIndexPathOfHWCell!, to: indexPathOfHWCell!)
        }
        
        //Delete the task from HomeVC if it is due over two weeks away and not completed.
        if (self.task.completed == false) {
            self.homeVC?.tableView.beginUpdates()
            if (self.datePickerView.date.overScopeThreshold(task: self.task) == true) {
                if (self.task.dateOfExtension == nil) { //(consider) if the dateOfExtension was modified within the last 10 min, don't delete row below.
                    self.homeVC?.tableView.deleteRows(at: [origIndexPathOfHWCell!], with: .fade) //use origIndexPath since the task is gone from HomeVC data model.
                }
            }
            self.homeVC?.tableView.endUpdates()
        }
        //
        
        //If the task is no longer extended.
        if (self.task.dateOfExtension != nil && self.datePickerView.date.overScopeThreshold(task: self.task) == false) {
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dateOfExtension = nil
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
        }
        
        //Remove Extended Section if needed.
        self.homeVC?.tableView.beginUpdates()
        if (self.homeVC?.extendedTasks.count == 0) {
            if let extendedTasksSection = self.homeVC!.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.homeVC!.sections.index(of: extendedTasksSection)!
                self.homeVC!.sections.removeObject(object: extendedTasksSection)
                self.homeVC!.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.homeVC?.tableView.endUpdates()
        //
        
    }
    
    func noDueDateButtonTouchUp_Using_HomeworkHelper() {
        self.title = "No Due Date"
        self.informationalLabel.isHidden = true
        self.informationalButton.isHidden = true
        let oldDate = self.task.dueDate
        //update dueDateCell in CellEditingVC
        let dueDateCell = cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DueDateTableViewCell
        if (self.task.type == "Assignment") {
            dueDateCell?.dueDateLabel.text = "Due Date"
        } else {
            dueDateCell?.dueDateLabel.text = "Date"
        }
        dueDateCell?.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
        dueDateCell?.iconImageView.image = #imageLiteral(resourceName: "CalendarBW")
        if (self.cellEditingVC?.helperObject.dictionary[0]?.count == 3) {
            self.cellEditingVC?.helperObject.dictionary[0]?.remove(at: 2)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        } else if (self.cellEditingVC?.helperObject.dictionary[0]?.count == 4) {
            self.cellEditingVC?.helperObject.dictionary[0]?.remove(at: 3)
            self.cellEditingVC?.helperObject.dictionary[0]?.remove(at: 2)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 3, section: 0), IndexPath(row: 2, section: 0)], with: .none)
        }
        self.removeRepeatsCell()
        
        
        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.dueDate = nil
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }
        
        let origIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        let cell = self.homeVC?.tableView.cellForRow(at: origIndexPathOfHWCell!) as? HomeworkTableViewCell
        
        //Add Extended Section if needed.
        self.homeVC?.tableView.beginUpdates()
        if (self.datePickerView.date.overScopeThreshold(task: self.task) == true && self.homeVC?.extendedTasks.count == 0) { //&& self.homeVC?.extendedTasks.count == 0
            if self.homeVC?.sections.first(where: { $0 == "Extended" }) == nil && self.homeVC?.sections.first(where: { $0 == "Completed Today" }) == nil {
                self.homeVC?.sections.insert("Extended", at: 1)
                self.homeVC?.tableView.insertSections([1], with: .automatic)
            } else if self.homeVC?.sections.first(where: { $0 == "Extended" }) == nil && self.homeVC?.sections.first(where: { $0 == "Completed Today" }) != nil {
                self.homeVC?.sections.insert("Extended", at: 2)
                self.homeVC?.tableView.insertSections([2], with: .automatic)
            }
        }
        self.homeVC?.tableView.endUpdates()
        //
        //if cell is nil, we could reload it here since cell? would be nil. But I don't think it is needed, since the cell would be selected. (thus stored in memory of UITableView possibly)
        cell?.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: nil, task: task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()
        
        let realm = try! Realm()
        realm.beginWrite()
        self.task.dueDate = nil
        self.task.timeSet = false
        self.task.endDateAndTime = nil
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        
        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        self.homeVC?.tableView.moveRow(at: origIndexPathOfHWCell!, to: indexPathOfHWCell!)
        self.homeVC?.heightAtIndexPath.removeValue(forKey: indexPathOfHWCell!)
        
        //If the task is no longer extended.
        if (self.task.dateOfExtension != nil && self.datePickerView.date.overScopeThreshold(task: self.task) == false) {
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dateOfExtension = nil
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
        }
        
        //Remove Extended Section if needed.
        self.homeVC?.tableView.beginUpdates()
        if (self.homeVC?.extendedTasks.count == 0) {
            if let extendedTasksSection = self.homeVC!.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.homeVC!.sections.index(of: extendedTasksSection)!
                self.homeVC!.sections.removeObject(object: extendedTasksSection)
                self.homeVC!.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.homeVC?.tableView.endUpdates()
        //
    }
    
    func noDueDateButtonTouchUp_Using_SchedulesHelper() {
        self.title = "No Due Date"
        self.informationalLabel.isHidden = true
        self.informationalButton.isHidden = true
        let oldDate = self.task.dueDate
        
        let scheduleEditorVC = self.taskManager as! ScheduleEditorViewController
        if (scheduleEditorVC.indexOfTask(task: task) != nil) {
            let hwCellInScheduleEditor = scheduleEditorVC.tableView.cellForRow(at: scheduleEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
            scheduleEditorVC.tableView.beginUpdates()
            CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: nil, task: task, cell: hwCellInScheduleEditor, taskManager: self.taskManager)
            scheduleEditorVC.tableView.endUpdates()
        }
        
        //update dueDateCell in CellEditingVC
        let dueDateCell = cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DueDateTableViewCell
        dueDateCell?.dueDateLabel.text = (self.datePickerView.date as NSDate).toReadableString()
        dueDateCell?.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        dueDateCell?.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
        if (self.cellEditingVC?.helperObject.dictionary[0]?.count == 3) { //Has only StartTimeCell
            self.cellEditingVC?.helperObject.dictionary[0]?.remove(at: 2)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        } else if (self.cellEditingVC?.helperObject.dictionary[0]?.count == 4) { //Has both (Start/End)TimeCells
            self.cellEditingVC?.helperObject.dictionary[0]?.remove(at: 3)
            self.cellEditingVC?.helperObject.dictionary[0]?.remove(at: 2)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 3, section: 0), IndexPath(row: 2, section: 0)], with: .none)
        }
        self.removeRepeatsCell()
        
        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.dueDate = nil
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }
        
        let origIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell == nil) { //Task didn't exist HomeVC tableView..
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dueDate = nil
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            ///self.homeVC?.tableView.reloadData()
            let newIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
            if (newIndexPathOfHWCell == nil) { return } //..and it still doesn't.
            self.homeVC?.tableView.beginUpdates()
            self.homeVC?.tableView.insertRows(at: [newIndexPathOfHWCell!], with: .fade)
            //self.homeVC?.tableView.reloadSections([newIndexPathOfHWCell!.section], with: .fade)
            self.homeVC?.tableView.endUpdates()
            return
        }
        
        let cell = self.homeVC?.tableView.cellForRow(at: origIndexPathOfHWCell!) as? HomeworkTableViewCell
        
        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: nil, task: task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()
        
        let realm = try! Realm()
        realm.beginWrite()
        self.task.dueDate = nil
        self.task.timeSet = false
        self.task.endDateAndTime = nil
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        
        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell != nil && indexPathOfHWCell != nil) {
            self.homeVC?.tableView.moveRow(at: origIndexPathOfHWCell!, to: indexPathOfHWCell!)
        }
        
        //Delete the task from HomeVC if it is due over two weeks away and not completed.
        if (self.task.completed == false) {
            self.homeVC?.tableView.beginUpdates()
            if (self.datePickerView.date.overScopeThreshold(task: self.task) == true) {
                if (self.task.dateOfExtension == nil) { //(consider) if the dateOfExtension was modified within the last 10 min, don't delete row below.
                    self.homeVC?.tableView.deleteRows(at: [origIndexPathOfHWCell!], with: .fade) //use origIndexPath since the task is gone from HomeVC data model.
                }
            }
            self.homeVC?.tableView.endUpdates()
        }
        //
        
        //If the task is no longer extended.
        if (self.task.dateOfExtension != nil && self.datePickerView.date.overScopeThreshold(task: self.task) == false) {
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dateOfExtension = nil
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
        }
        
        //Remove Extended Section if needed.
        self.homeVC?.tableView.beginUpdates()
        if (self.homeVC?.extendedTasks.count == 0) {
            if let extendedTasksSection = self.homeVC!.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.homeVC!.sections.index(of: extendedTasksSection)!
                self.homeVC!.sections.removeObject(object: extendedTasksSection)
                self.homeVC!.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.homeVC?.tableView.endUpdates()
    }
    
    func noDueDateButtonTouchUp_Using_WeeklyHelper() {
        self.title = "No Due Date"
        self.informationalLabel.isHidden = true
        self.informationalButton.isHidden = true
        let oldDate = self.task.dueDate
        
        let weeklyEditorVC = self.taskManager as! WeeklyEditingTableViewController
        if (weeklyEditorVC.indexOfTask(task: task) != nil) {
            let hwCellInWeeklyEditor = weeklyEditorVC.tableView.cellForRow(at: weeklyEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
            weeklyEditorVC.tableView.beginUpdates()
            CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: nil, task: task, cell: hwCellInWeeklyEditor, taskManager: self.taskManager)
            weeklyEditorVC.tableView.endUpdates()
        }
        
        //update dueDateCell in CellEditingVC
        let dueDateCell = cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? DueDateTableViewCell
        dueDateCell?.dueDateLabel.text = (self.datePickerView.date as NSDate).toReadableString()
        dueDateCell?.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        dueDateCell?.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
        if (self.cellEditingVC?.helperObject.dictionary[0]?.count == 3) { //Has only StartTimeCell
            self.cellEditingVC?.helperObject.dictionary[0]?.remove(at: 2)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        } else if (self.cellEditingVC?.helperObject.dictionary[0]?.count == 4) { //Has both (Start/End)TimeCells
            self.cellEditingVC?.helperObject.dictionary[0]?.remove(at: 3)
            self.cellEditingVC?.helperObject.dictionary[0]?.remove(at: 2)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 3, section: 0), IndexPath(row: 2, section: 0)], with: .none)
        }
        self.removeRepeatsCell()
        
        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.dueDate = nil
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }
        
        let origIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell == nil) { //Task didn't exist HomeVC tableView..
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dueDate = nil
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            let newIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
            if (newIndexPathOfHWCell == nil) { return } //..and it still doesn't.
            self.homeVC?.tableView.beginUpdates()
            self.homeVC?.tableView.insertRows(at: [newIndexPathOfHWCell!], with: .fade)
            self.homeVC?.tableView.endUpdates()
            return
        }
        
        let cell = self.homeVC?.tableView.cellForRow(at: origIndexPathOfHWCell!) as? HomeworkTableViewCell
        
        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: nil, task: task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()
        
        let realm = try! Realm()
        realm.beginWrite()
        self.task.dueDate = nil
        self.task.timeSet = false
        self.task.endDateAndTime = nil
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        
        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell != nil && indexPathOfHWCell != nil) {
            self.homeVC?.tableView.moveRow(at: origIndexPathOfHWCell!, to: indexPathOfHWCell!)
        }
        
        //Delete the task from HomeVC if it is due over two weeks away and not completed.
        if (self.task.completed == false) {
            self.homeVC?.tableView.beginUpdates()
            if (self.datePickerView.date.overScopeThreshold(task: self.task) == true) {
                if (self.task.dateOfExtension == nil) { //(consider) if the dateOfExtension was modified within the last 10 min, don't delete row below.
                    self.homeVC?.tableView.deleteRows(at: [origIndexPathOfHWCell!], with: .fade) //use origIndexPath since the task is gone from HomeVC data model.
                }
            }
            self.homeVC?.tableView.endUpdates()
        }
        //
        
        //If the task is no longer extended.
        if (self.task.dateOfExtension != nil && self.datePickerView.date.overScopeThreshold(task: self.task) == false) {
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dateOfExtension = nil
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
        }
        
        //Remove Extended Section if needed.
        self.homeVC?.tableView.beginUpdates()
        if (self.homeVC?.extendedTasks.count == 0) {
            if let extendedTasksSection = self.homeVC!.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.homeVC!.sections.index(of: extendedTasksSection)!
                self.homeVC!.sections.removeObject(object: extendedTasksSection)
                self.homeVC!.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.homeVC?.tableView.endUpdates()
    }
    
    @IBAction func doneEditingButtonTouchUp(_ sender: Any) {
        let senderButton = sender as? UIButton
        senderButton?.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .normal)
        self.navigationController?.popViewController(animated: true)
    }
    
    func createDateFromComponents(_ month: Int, day: Int, year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 0
        dateComponents.minute = 0
        return Calendar.current.date(from: dateComponents)!
    }
    
    func determineMinAndMaxDatesForSemester() {
        var minDate = createDateFromComponents(9, day: 8, year: 2016)
        var maxDate = createDateFromComponents(12, day: 23, year: 2016)
        
        self.semesterDates["Fall"] = [minDate, maxDate]
        
        minDate = createDateFromComponents(1, day: 4, year: 2017)
        maxDate = createDateFromComponents(4, day: 30, year: 2017)
        
        self.semesterDates["Spring"] = [minDate, maxDate]
        
        minDate = createDateFromComponents(5, day: 9, year: 2017)
        maxDate = createDateFromComponents(8, day: 20, year: 2017)
        
        self.semesterDates["Summer"] = [minDate, maxDate]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if (UIScreen.main.bounds.size.height == 320) { //fix iPhone 4S layout bug.
            self.noDueDateButton.isHidden = true
        } else if (UIScreen.main.bounds.size.height == 480) {
            self.noDueDateButton.isHidden = false
        }
    }
    
    func iPhone4SLandscapeHandler() {
        if (UIScreen.main.bounds.size.height == 320) { //fix iPhone 4S layout bug.
            self.noDueDateButton.isHidden = true
        }
    }
    
    func updateInformationalLabelText() {
        if (self.task.scope == "Regular") {
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.long
            let twoWeeksBeforeChosenDate = Calendar.current.date(byAdding: .day, value: -14, to: self.datePickerView.date)!
            //datePicker's date - 14 days. Also be sure to change in noDueDateButtonTouchUp if modified.
            self.informationalLabel.text = "This " + self.task.type + " will be hidden from your Agenda until " + formatter.string(from: twoWeeksBeforeChosenDate) + "."
        }
        if (self.task.scope == "Event") {
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.long
            //Also be sure to change in noDueDateButtonTouchUp if modified.
            self.informationalLabel.text = "This " + self.task.type + " will be hidden from your Agenda until " + formatter.string(from: self.datePickerView.date) + "."
        }
    }
    
    @IBAction func informationButtonTouchUpInside(_ sender: Any) {
        var message = String()
        if (self.task.scope == "Regular") {
            if (self.task.type == "Assignment") {
                message = "\nYour Agenda only displays " + self.task.type + "s due within two weeks.\n\n View other " + self.task.type + "s in your Course Schedule."
            }
            if (self.task.type == "Midterm" || self.task.type == "Final" || self.task.type == "Quiz") {
                var plural = self.task.type + "s"
                if (self.task.type == "Quiz") {
                    plural.remove(at: plural.index(plural.startIndex, offsetBy: 4)) //String.Index(4)
                    plural += "zes"
                }
                message = "\nYour Agenda only displays " + plural + " happening within two weeks.\n\n View other " + plural + " in your Course Schedule."
            }
        }
        if (self.task.scope == "Event") {
            message = "\nYour Agenda only displays " + "classe" + "s happening today.\n\n View other " + self.task.type + "s in your Course Schedule."
        }
        let alertViewController = UIAlertController(title: "Did you know?",
                                                    message: message,
                                                    preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alertViewController.dismiss(animated: true, completion: nil)
        })
        alertViewController.addAction(okButton)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func insertRepeatsCell() { //CAN BE MODIFIED TO ALSO INSERT REMINDERS CELL, ETC.
        guard let editingVC = self.cellEditingVC else { return }
        if (editingVC.helperObject.mode == .Create) {
            editingVC.helperObject.dictionary[5] = []
            editingVC.tableView.insertSections([5], with: .none)
            
            editingVC.helperObject.dictionary[4]?.remove(at: 0)
            editingVC.helperObject.dictionary[5]?.insert(ScheduleRowContent(identifier: "CreateCell"), at: 0)
            editingVC.tableView.moveRow(at: IndexPath(row: 0, section: 4), to: IndexPath(row: 0, section: 5))
            editingVC.helperObject.dictionary[4]?.insert(ScheduleRowContent(identifier: "NoteCell"), at: 0)
             editingVC.helperObject.dictionary[3]?.remove(at: 0)
            
            let subtaskCells = editingVC.helperObject.dictionary[2] as! [ScheduleRowContent]
            editingVC.helperObject.dictionary[3]?.append(contentsOf: subtaskCells)
            editingVC.helperObject.dictionary[2]?.removeAll()
            editingVC.tableView.reloadSections([2, 3, 4], with: .none)
            
            editingVC.helperObject.dictionary[2]?.insert(ScheduleRowContent(identifier: "RepeatsCell"), at: 0)
            editingVC.tableView.insertRows(at: [IndexPath(row: 0, section: 2)], with: .none)
        }
        if (editingVC.helperObject.mode == .Edit) {
            editingVC.helperObject.dictionary[4] = []
            editingVC.tableView.insertSections([4], with: .none)
            editingVC.helperObject.dictionary[4]?.insert(ScheduleRowContent(identifier: "NoteCell"), at: 0)
            editingVC.helperObject.dictionary[3]?.remove(at: 0)
            let subtaskCells = editingVC.helperObject.dictionary[2] as! [ScheduleRowContent]
            editingVC.helperObject.dictionary[3]?.append(contentsOf: subtaskCells)
            editingVC.helperObject.dictionary[2]?.removeAll()
            editingVC.tableView.reloadSections([2, 3, 4], with: .none)
            
            editingVC.helperObject.dictionary[2]?.insert(ScheduleRowContent(identifier: "RepeatsCell"), at: 0)
            editingVC.tableView.insertRows(at: [IndexPath(row: 0, section: 2)], with: .none)
        }
    }
    
    func removeRepeatsCell() {
        guard let editingVC = self.cellEditingVC else { return }
        if (editingVC.helperObject.mode == .Create) {
            guard editingVC.helperObject.dictionary.count > 5 else { return }
            let subtaskCells = editingVC.helperObject.dictionary[3] as! [ScheduleRowContent]
            editingVC.helperObject.dictionary[3]?.remove(at: 0)
            editingVC.helperObject.dictionary[3]?.insert(ScheduleRowContent(identifier: "NoteCell"), at: 0)
            editingVC.helperObject.dictionary[4]?.insert(ScheduleRowContent(identifier: "CreateCell"), at: 0)
            editingVC.helperObject.dictionary[5]?.remove(at: 0)
            editingVC.tableView.moveRow(at: IndexPath(row: 0, section: 5), to: IndexPath(row: 0, section: 4))
            editingVC.helperObject.dictionary.removeValue(forKey: 5)
            editingVC.tableView.deleteSections([5], with: .none)
            editingVC.helperObject.dictionary[4]?.remove(at: 1)
            editingVC.tableView.deleteRows(at: [IndexPath(row: 1, section: 4)], with: .none)
            
            editingVC.helperObject.dictionary[2]?.removeAll()
            editingVC.helperObject.dictionary[2]?.append(contentsOf: subtaskCells)
            editingVC.tableView.reloadSections([2,3], with: .none)
        }
        if (editingVC.helperObject.mode == .Edit) {
            if let subtaskCells = editingVC.helperObject.dictionary[3] as? [ScheduleRowContent] {
                editingVC.helperObject.dictionary[4]?.removeAll()
                editingVC.helperObject.dictionary.removeValue(forKey: 4)
                editingVC.tableView.deleteSections([4], with: .none)
                editingVC.helperObject.dictionary[3]?.remove(at: 0)
                editingVC.helperObject.dictionary[3]?.insert(ScheduleRowContent(identifier: "NoteCell"), at: 0)
                editingVC.helperObject.dictionary[2]?.removeAll()
                editingVC.helperObject.dictionary[2]?.append(contentsOf: subtaskCells)
                editingVC.tableView.reloadSections([2,3], with: .none)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //BELOW METHOD MOVED TO CELLEDITING VC.
    //This method ensures that if this task is the master task for a repeatingSchedule, the corresponding dateTokens are also updated.
    //Variable 'newDate' should be the newly selected date from interface.
    /*func updateDateTokenIfTaskRepeats(oldDate: NSDate?) {
        let newDate = self.task.dueDate
        if (self.task.repeatingSchedule != nil) {
            let realm = try! Realm()
            let repeatingSchedulesUsingThisTaskAsMasterTask = realm.objects(RLMRepeatingSchedule.self).filter("masterTask = %@", self.task)
            let currentTaskRepeatingSchedule = self.task.repeatingSchedule //In create mode, task is always rs's master.
            if (repeatingSchedulesUsingThisTaskAsMasterTask.first != nil || currentTaskRepeatingSchedule != nil) {
                var repeatingSchedule = repeatingSchedulesUsingThisTaskAsMasterTask.first
                if (repeatingSchedule == nil) { repeatingSchedule = currentTaskRepeatingSchedule }
                let dateTokens = repeatingSchedule!.tokens
                for (index, dateToken) in dateTokens.enumerated() {
                    //print(dateToken.startTime.description + " ~ " + oldDate!.description)
                    if (dateToken.startTime.timeIntervalSinceReferenceDate == oldDate?.timeIntervalSinceReferenceDate) { //change this line based on what VC this is.
                        if (newDate == nil) { //if user removes dueDate, then the correct token should be removed.
                            self.task.repeatingSchedule?.tokens.remove(at: index)
                            if (self.cellEditingVC?.helperObject.mode == .Edit) { realm.delete(dateToken) }
                            return
                        }
                        //update this dateToken.
                        dateToken.startTime = newDate as! NSDate
                        dateToken.startDayOfWeek = DayOfWeek(id: self.task.dueDate!.dayNumberOfWeek()!)!.rawValue
                        dateToken.lastTaskCreatedDueDate = newDate as! NSDate
                        return
                    }
                }
                //if user had made the dueDate nil before therefore deleting the only matching dateToken, then simply recreate it.
                if (newDate != nil) {
                    let dateToken = RLMDateToken(startTime: newDate as! NSDate, startDayOfWeek: DayOfWeek(id: newDate!.dayNumberOfWeek()!)!.rawValue, endTime: nil)
                    dateToken.lastTaskCreatedDueDate = newDate as! NSDate
                    repeatingSchedule!.tokens.append(dateToken)
                    if (self.cellEditingVC?.helperObject.mode == .Edit) { realm.add(dateToken) }
                }
            }
        }
    }*/
    

}
