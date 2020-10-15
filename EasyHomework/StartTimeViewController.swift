//
//  StartTimeViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2018-01-25.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class StartTimeViewController: UIViewController {

    @IBOutlet var noStartTimeButton: UIButton!
    @IBOutlet var datePickerView: CustomDatePickerView!
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

        let gregorian = Calendar(identifier: .gregorian)
        let date = self.task.dueDate!
        //let now = Date()
        //var nowComponents = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date as Date)
        components.hour = 9
        components.minute = 0
        components.second = 0
        let sameDateAsTaskAndBeginningOfCurrentHour = gregorian.date(from: components)!

        if (self.task.timeSet == false) {
            self.datePickerView.setDate(sameDateAsTaskAndBeginningOfCurrentHour, animated: false)
            if (self.task.type == "Assignment") {
                self.title = "Due " + (self.datePickerView.date as NSDate).toReadableTimeString()
            } else {
                self.title = "Starts " + (self.datePickerView.date as NSDate).toReadableTimeString()
            }
        } else {
            self.datePickerView.setDate(self.task.dueDate! as Date, animated: false)
            if (self.task.type == "Assignment") {
                self.title = "Due " + self.task.dueDate!.toReadableTimeString()
            } else {
                self.title = "Starts " + self.task.dueDate!.toReadableTimeString()
            }
        }

        if (self.task.type == "Assignment") {
            self.noStartTimeButton.setTitle("This " + self.task.type + " has no due time?", for: UIControlState.normal)
        } else {
            self.noStartTimeButton.setTitle("This " + self.task.type + " has no start time?", for: UIControlState.normal)
        }
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
        //
        if (self.task.timeSet == false) {
            if (self.task.type == "Assignment") {
                timeCell?.startTimeLabel.text = "Time Due"
            } else {
                timeCell?.startTimeLabel.text = "Start Time"
            }
            timeCell?.startTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
            timeCell?.iconImageView.image = #imageLiteral(resourceName: "StartClockBW")
        } else {
            if (self.task.type == "Assignment") {
                timeCell?.startTimeLabel.text = "Due " + self.task.dueDate!.toReadableTimeString()
            } else {
                timeCell?.startTimeLabel.text = "Starts " + self.task.dueDate!.toReadableTimeString()
            }
            timeCell?.startTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            timeCell?.iconImageView.image = #imageLiteral(resourceName: "DefaultStartClock")
        }
    }

    //The methods used in the below IBActions are essentially C&P'd from DueDateVC with minor modifications.
    @IBAction func StartTimePickerValueChanged(_ sender: Any) {
        if (self.cellEditingVC?.helperObject is HomeworkCellEditingHelperObject) {
            self.timePickerValueChanged_Using_HomeworkHelper()
        }
        if (self.cellEditingVC?.helperObject is SchedulesCellEditingHelperObject) {
            self.timePickerValueChanged_Using_SchedulesHelper()
        }
        if (self.cellEditingVC?.helperObject is WeeklyCellEditingHelperObject) {
            self.timePickerValueChanged_Using_WeeklyHelper()
        }
        if (self.cellEditingVC?.helperObject is CalendarCellEditingHelperObject) {
            self.timePickerValueChanged_Using_CalendarHelper()
        }

        self.upDateNotifications() //For Reminders Functionality.
    }

    @IBAction func noStartTimeButtonTouchUpInside(_ sender: Any) {
        if (self.cellEditingVC?.helperObject is HomeworkCellEditingHelperObject) {
            self.noTimeButtonTouchUp_Using_HomeworkHelper()
        }
        if (self.cellEditingVC?.helperObject is SchedulesCellEditingHelperObject) {
            self.noTimeButtonTouchUp_Using_SchedulesHelper()
        }
        if (self.cellEditingVC?.helperObject is WeeklyCellEditingHelperObject) {
            self.noTimeButtonTouchUp_Using_WeeklyHelper()
        }
        if (self.cellEditingVC?.helperObject is CalendarCellEditingHelperObject) {
            self.noTimeButtonTouchUp_Using_CalendarHelper()
        }

        self.upDateNotifications() //For Reminders Functionality.
    }

    func timePickerValueChanged_Using_HomeworkHelper() {
        let oldDate = self.task.dueDate
        if (self.task.type == "Assignment") {
            self.title = "Due " + (self.datePickerView.date as NSDate).toReadableTimeString()
        } else {
            self.title = "Starts " + (self.datePickerView.date as NSDate).toReadableTimeString()
        }
        if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") == nil && self.task.type != "Assignment") {
            self.cellEditingVC!.helperObject.dictionary[0]?.insert(ScheduleRowContent(identifier: "EndTimeCell"), at: 3)
            self.cellEditingVC?.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }

        if (self.datePickerView.date.overScopeThreshold(task: self.task)) {
            //self.updateInformationalLabelText()
            //self.informationalLabel.isHidden = false
            //self.informationalButton.isHidden = false
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
                //self.upDateNotifications()
            }
        } else {
            //self.informationalLabel.isHidden = true
            //self.informationalButton.isHidden = true
        }

        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.dueDate = (self.datePickerView.date).withoutExtraneousSeconds() as NSDate
            self.task.timeSet = true
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

        let realm = try! Realm()
        realm.beginWrite()
        self.task.timeSet = true
        self.task.dueDate = (self.datePickerView.date).withoutExtraneousSeconds() as NSDate?
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        //self.upDateNotifications()

        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()

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
            //self.upDateNotifications()
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

    func timePickerValueChanged_Using_SchedulesHelper() {
        let oldDate = self.task.dueDate
        if (self.task.type == "Assignment") {
            self.title = "Due " + (self.datePickerView.date as NSDate).toReadableTimeString()
        } else {
            self.title = "Starts " + (self.datePickerView.date as NSDate).toReadableTimeString()
        }
        if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") == nil && self.task.type != "Assignment") {
            self.cellEditingVC!.helperObject.dictionary[0]?.insert(ScheduleRowContent(identifier: "EndTimeCell"), at: 3)
            self.cellEditingVC?.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }

        if (self.datePickerView.date.overScopeThreshold(task: self.task)) {
            //self.updateInformationalLabelText()
            //self.informationalLabel.isHidden = false
            //self.informationalButton.isHidden = false
            //(self.cellEditingVC?.homeVC != nil)'s purpose is to check if the Agenda (Home) is where cellEditingVC came from. If SchedulesViewController is where cellEditingVC came from, then DO NOT execute what is in this if statement.
            if (self.cellEditingVC?.helperObject.taskManagerVC == nil) { print("ERROR IN datePickerValueChanged(..) & noDueDateButtonTouchUp of DueDateVC") }
        } else {
            //self.informationalLabel.isHidden = true
            //self.informationalButton.isHidden = true
        }
        let scheduleEditorVC = self.taskManager as! ScheduleEditorViewController

        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.dueDate = (self.datePickerView.date).withoutExtraneousSeconds() as NSDate
            self.task.timeSet = true
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }

        let origIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell == nil) { //Task didn't exist HomeVC tableView..
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dueDate = (self.datePickerView.date).withoutExtraneousSeconds() as NSDate?
            self.task.timeSet = true
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            //self.upDateNotifications()
            if (scheduleEditorVC.indexOfTask(task: task) != nil) {
                let hwCellInScheduleEditor = scheduleEditorVC.tableView.cellForRow(at: scheduleEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
                scheduleEditorVC.tableView.beginUpdates()
                CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: hwCellInScheduleEditor, taskManager: self.taskManager)
                scheduleEditorVC.tableView.endUpdates()
            }
            let newIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
            if (newIndexPathOfHWCell == nil) { return } //..and it still doesn't.
            self.homeVC?.tableView.beginUpdates()
            self.homeVC?.tableView.insertRows(at: [newIndexPathOfHWCell!], with: .fade)
            self.homeVC?.tableView.endUpdates()
            return
        }

        let cell = self.homeVC?.tableView.cellForRow(at: origIndexPathOfHWCell!) as? HomeworkTableViewCell

        let realm = try! Realm()
        realm.beginWrite()
        self.task.dueDate = (self.datePickerView.date).withoutExtraneousSeconds() as NSDate?
        self.task.timeSet = true
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        //self.upDateNotifications()
        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()

        let hwCellInScheduleEditor = scheduleEditorVC.tableView.cellForRow(at: scheduleEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
        scheduleEditorVC.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: hwCellInScheduleEditor, taskManager: self.taskManager)
        scheduleEditorVC.tableView.endUpdates()

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
            //self.upDateNotifications()
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

        for tableView in TaskManagerTracker.taskManagers() { //Handle any other existing TaskManagers.
            if !(tableView?.parentViewController == self.homeVC || tableView?.parentViewController == self.taskManager) {
                tableView?.reloadData()
            }
        }
    }

    func timePickerValueChanged_Using_WeeklyHelper() {
        let oldDate = self.task.dueDate
        if (self.task.type == "Assignment") {
            self.title = "Due " + (self.datePickerView.date as NSDate).toReadableTimeString()
        } else {
            self.title = "Starts " + (self.datePickerView.date as NSDate).toReadableTimeString()
        }
        if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") == nil && self.task.type != "Assignment") {
            self.cellEditingVC!.helperObject.dictionary[0]?.insert(ScheduleRowContent(identifier: "EndTimeCell"), at: 3)
            self.cellEditingVC?.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }

        if (self.datePickerView.date.overScopeThreshold(task: self.task)) {
            //self.updateInformationalLabelText()
            //self.informationalLabel.isHidden = false
            //self.informationalButton.isHidden = false
            //(self.cellEditingVC?.homeVC != nil)'s purpose is to check if the Agenda (Home) is where cellEditingVC came from. If SchedulesViewController is where cellEditingVC came from, then DO NOT execute what is in this if statement.
            if (self.cellEditingVC?.helperObject.taskManagerVC == nil) { print("ERROR IN datePickerValueChanged(..) & noDueDateButtonTouchUp of DueDateVC") }
        } else {
            //self.informationalLabel.isHidden = true
            //self.informationalButton.isHidden = true
        }
        let weeklyEditorVC = self.taskManager as! WeeklyEditingTableViewController

        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.dueDate = (self.datePickerView.date).withoutExtraneousSeconds() as NSDate
            self.task.timeSet = true
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }

        let origIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell == nil) { //Task didn't exist HomeVC tableView..
            let realm = try! Realm()
            realm.beginWrite()
            self.task.dueDate = (self.datePickerView.date).withoutExtraneousSeconds() as NSDate?
            self.task.timeSet = true
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            //self.upDateNotifications()
            if (weeklyEditorVC.indexOfTask(task: task) != nil) {
                let hwCellInWeeklyEditor = weeklyEditorVC.tableView.cellForRow(at: weeklyEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
                weeklyEditorVC.tableView.beginUpdates()
                CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: hwCellInWeeklyEditor, taskManager: self.taskManager)
                weeklyEditorVC.tableView.endUpdates()
            }
            let newIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
            if (newIndexPathOfHWCell == nil) { return } //..and it still doesn't.
            self.homeVC?.tableView.beginUpdates()
            self.homeVC?.tableView.insertRows(at: [newIndexPathOfHWCell!], with: .fade)
            self.homeVC?.tableView.endUpdates()
            return
        }

        let cell = self.homeVC?.tableView.cellForRow(at: origIndexPathOfHWCell!) as? HomeworkTableViewCell

        let realm = try! Realm()
        realm.beginWrite()
        self.task.dueDate = (self.datePickerView.date).withoutExtraneousSeconds() as NSDate?
        self.task.timeSet = true
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        //self.upDateNotifications()
        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()

        let hwCellInWeeklyEditor = weeklyEditorVC.tableView.cellForRow(at: weeklyEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
        weeklyEditorVC.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: hwCellInWeeklyEditor, taskManager: self.taskManager)
        weeklyEditorVC.tableView.endUpdates()

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
            //self.upDateNotifications()
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

        for tableView in TaskManagerTracker.taskManagers() { //Handle any other existing TaskManagers.
            if !(tableView?.parentViewController == self.homeVC || tableView?.parentViewController == self.taskManager) {
                tableView?.reloadData()
            }
        }
    }

    func timePickerValueChanged_Using_CalendarHelper() {
        let oldDate = self.task.dueDate
        if (self.task.type == "Assignment") {
            self.title = "Due " + (self.datePickerView.date as NSDate).toReadableTimeString()
        } else {
            self.title = "Starts " + (self.datePickerView.date as NSDate).toReadableTimeString()
        }
        if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") == nil && self.task.type != "Assignment") {
            self.cellEditingVC!.helperObject.dictionary[0]?.insert(ScheduleRowContent(identifier: "EndTimeCell"), at: 3)
            self.cellEditingVC?.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }

        if (self.datePickerView.date.overScopeThreshold(task: self.task)) {
            //self.updateInformationalLabelText()
            //self.informationalLabel.isHidden = false
            //self.informationalButton.isHidden = false
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
            //self.informationalLabel.isHidden = true
            //self.informationalButton.isHidden = true
        }

        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.dueDate = (self.datePickerView.date).withoutExtraneousSeconds() as NSDate
            self.task.timeSet = true
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }

        let calendarTaskManager = self.taskManager as! CalendarTaskManagerViewController
        let origIndexPathOfHWCell = calendarTaskManager.indexOfTask(task: self.task)
        let cell = calendarTaskManager.tableView.cellForRow(at: origIndexPathOfHWCell!) as? HomeworkTableViewCell

        //Add Extended Section if needed.
        calendarTaskManager.tableView.beginUpdates()
        if (self.datePickerView.date.overScopeThreshold(task: self.task) == true && calendarTaskManager.extendedTasks.count == 0) { //&& calendarTaskManager.extendedTasks.count == 0
            if calendarTaskManager.sections.first(where: { $0 == "Extended" }) == nil && calendarTaskManager.sections.first(where: { $0 == "Completed Today" }) == nil {
                calendarTaskManager.sections.insert("Extended", at: 1)
                calendarTaskManager.tableView.insertSections([1], with: .automatic)
            } else if calendarTaskManager.sections.first(where: { $0 == "Extended" }) == nil && calendarTaskManager.sections.first(where: { $0 == "Completed Today" }) != nil {
                calendarTaskManager.sections.insert("Extended", at: 2)
                calendarTaskManager.tableView.insertSections([2], with: .automatic)
            }
        }
        calendarTaskManager.tableView.endUpdates()
        //

        let realm = try! Realm()
        realm.beginWrite()
        self.task.timeSet = true
        self.task.dueDate = (self.datePickerView.date).withoutExtraneousSeconds() as NSDate?
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }

        calendarTaskManager.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: cell, taskManager: self.taskManager)
        calendarTaskManager.tableView.endUpdates()

        let indexPathOfHWCell = calendarTaskManager.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell != nil && indexPathOfHWCell != nil) {
            calendarTaskManager.tableView.moveRow(at: origIndexPathOfHWCell!, to: indexPathOfHWCell!)
        }
        calendarTaskManager.heightAtIndexPath.removeValue(forKey: indexPathOfHWCell!)

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
        calendarTaskManager.tableView.beginUpdates()
        if (calendarTaskManager.extendedTasks.count == 0) {
            if let extendedTasksSection = calendarTaskManager.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = calendarTaskManager.sections.index(of: extendedTasksSection)!
                calendarTaskManager.sections.removeObject(object: extendedTasksSection)
                calendarTaskManager.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        calendarTaskManager.tableView.endUpdates()
        //

        self.homeVC!.tableView.reloadData()
    }

    func noTimeButtonTouchUp_Using_HomeworkHelper() {
        let oldDate = self.task.dueDate
        if (self.task.type == "Assignment") {
            self.title = "Due Anytime"
        } else {
            self.title = "No Start Time"
        }
        if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") != nil) {
            self.cellEditingVC!.helperObject.dictionary[0]?.remove(at: 3)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }
        //self.informationalLabel.isHidden = true
        //self.informationalButton.isHidden = true
        //update dueDateCell in CellEditingVC

        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.task.dueDate = (self.task.dueDate! as Date).convertToLatestPossibleTimeOfDay() as NSDate
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

        let realm = try! Realm()
        realm.beginWrite()
        self.task.timeSet = false
        self.task.endDateAndTime = nil
        self.task.dueDate = (self.task.dueDate! as Date).convertToLatestPossibleTimeOfDay() as NSDate
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        //self.upDateNotifications()

        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as! Date, task: self.task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()

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
            //self.upDateNotifications()
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

    func noTimeButtonTouchUp_Using_SchedulesHelper() {
        let oldDate = self.task.dueDate
        if (self.task.type == "Assignment") {
            self.title = "Due Anytime"
        } else {
            self.title = "No Start Time"
        }
        if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") != nil) {
            self.cellEditingVC!.helperObject.dictionary[0]?.remove(at: 3)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }
        //self.informationalLabel.isHidden = true
        //self.informationalButton.isHidden = true

        let scheduleEditorVC = self.taskManager as! ScheduleEditorViewController

        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.task.dueDate = (self.task.dueDate! as Date).convertToLatestPossibleTimeOfDay() as NSDate
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }

        let origIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell == nil) { //Task didn't exist HomeVC tableView..
            let realm = try! Realm()
            realm.beginWrite()
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.task.dueDate = (self.task.dueDate! as Date).convertToLatestPossibleTimeOfDay() as NSDate
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            //self.upDateNotifications()
            if (scheduleEditorVC.indexOfTask(task: task) != nil) {
                let hwCellInScheduleEditor = scheduleEditorVC.tableView.cellForRow(at: scheduleEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
                scheduleEditorVC.tableView.beginUpdates()
                CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as! Date, task: self.task, cell: hwCellInScheduleEditor, taskManager: self.taskManager)
                scheduleEditorVC.tableView.endUpdates()
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

        let realm = try! Realm()
        realm.beginWrite()
        self.task.timeSet = false
        self.task.endDateAndTime = nil
        self.task.dueDate = (self.task.dueDate! as Date).convertToLatestPossibleTimeOfDay() as NSDate
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        //self.upDateNotifications()

        let hwCellInScheduleEditor = scheduleEditorVC.tableView.cellForRow(at: scheduleEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
        scheduleEditorVC.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: hwCellInScheduleEditor, taskManager: self.taskManager)
        scheduleEditorVC.tableView.endUpdates()

        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate! as Date, task: self.task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()

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
            //self.upDateNotifications()
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

    func noTimeButtonTouchUp_Using_WeeklyHelper() {
        let oldDate = self.task.dueDate
        if (self.task.type == "Assignment") {
            self.title = "Due Anytime"
        } else {
            self.title = "No Start Time"
        }
        if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") != nil) {
            self.cellEditingVC!.helperObject.dictionary[0]?.remove(at: 3)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }
        //self.informationalLabel.isHidden = true
        //self.informationalButton.isHidden = true

        let weeklyEditorVC = self.taskManager as! WeeklyEditingTableViewController

        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.task.dueDate = (self.task.dueDate! as Date).convertToLatestPossibleTimeOfDay() as NSDate
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }

        let origIndexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        if (origIndexPathOfHWCell == nil) { //Task didn't exist HomeVC tableView..
            let realm = try! Realm()
            realm.beginWrite()
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.task.dueDate = (self.task.dueDate! as Date).convertToLatestPossibleTimeOfDay() as NSDate
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            //self.upDateNotifications()
            if (weeklyEditorVC.indexOfTask(task: task) != nil) {
                let hwCellInWeeklyEditor = weeklyEditorVC.tableView.cellForRow(at: weeklyEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
                weeklyEditorVC.tableView.beginUpdates()
                CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as! Date, task: self.task, cell: hwCellInWeeklyEditor, taskManager: self.taskManager)
                weeklyEditorVC.tableView.endUpdates()
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

        let realm = try! Realm()
        realm.beginWrite()
        self.task.timeSet = false
        self.task.endDateAndTime = nil
        self.task.dueDate = (self.task.dueDate! as Date).convertToLatestPossibleTimeOfDay() as NSDate
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        //self.upDateNotifications()

        let hwCellInWeeklyEditor = weeklyEditorVC.tableView.cellForRow(at: weeklyEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
        weeklyEditorVC.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.datePickerView.date, task: self.task, cell: hwCellInWeeklyEditor, taskManager: self.taskManager)
        weeklyEditorVC.tableView.endUpdates()

        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate! as Date, task: self.task, cell: cell, taskManager: self.taskManager)
        self.homeVC?.tableView.endUpdates()

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
            //self.upDateNotifications()
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

    func noTimeButtonTouchUp_Using_CalendarHelper() {
        let oldDate = self.task.dueDate
        if (self.task.type == "Assignment") {
            self.title = "Due Anytime"
        } else {
            self.title = "No Start Time"
        }
        if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") != nil) {
            self.cellEditingVC!.helperObject.dictionary[0]?.remove(at: 3)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }
        //self.informationalLabel.isHidden = true
        //self.informationalButton.isHidden = true

        //update dueDateCell in CellEditingVC

        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.timeSet = false
            self.task.endDateAndTime = nil
            self.task.dueDate = (self.task.dueDate! as Date).convertToLatestPossibleTimeOfDay() as NSDate
            self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
            return
        }

        let calendarTaskManagerVC = self.taskManager as! CalendarTaskManagerViewController
        let origIndexPathOfHWCell = calendarTaskManagerVC.indexOfTask(task: self.task)
        let cell = calendarTaskManagerVC.tableView.cellForRow(at: origIndexPathOfHWCell!) as? HomeworkTableViewCell

        //Add Extended Section if needed.
        calendarTaskManagerVC.tableView.beginUpdates()
        if (self.datePickerView.date.overScopeThreshold(task: self.task) == true && calendarTaskManagerVC.extendedTasks.count == 0) { //&& calendarTaskManagerVC.extendedTasks.count == 0
            if calendarTaskManagerVC.sections.first(where: { $0 == "Extended" }) == nil && calendarTaskManagerVC.sections.first(where: { $0 == "Completed Today" }) == nil {
                calendarTaskManagerVC.sections.insert("Extended", at: 1)
                calendarTaskManagerVC.tableView.insertSections([1], with: .automatic)
            } else if calendarTaskManagerVC.sections.first(where: { $0 == "Extended" }) == nil && calendarTaskManagerVC.sections.first(where: { $0 == "Completed Today" }) != nil {
                calendarTaskManagerVC.sections.insert("Extended", at: 2)
                calendarTaskManagerVC.tableView.insertSections([2], with: .automatic)
            }
        }
        calendarTaskManagerVC.tableView.endUpdates()
        //

        let realm = try! Realm()
        realm.beginWrite()
        self.task.timeSet = false
        self.task.endDateAndTime = nil
        self.task.dueDate = (self.task.dueDate! as Date).convertToLatestPossibleTimeOfDay() as NSDate
        self.cellEditingVC?.updateDateTokenIfTaskRepeats(task: self.task, oldDate: oldDate)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }

        calendarTaskManagerVC.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as! Date, task: self.task, cell: cell, taskManager: self.taskManager)
        calendarTaskManagerVC.tableView.endUpdates()

        let indexPathOfHWCell = calendarTaskManagerVC.indexOfTask(task: self.task)
        calendarTaskManagerVC.tableView.moveRow(at: origIndexPathOfHWCell!, to: indexPathOfHWCell!)
        calendarTaskManagerVC.heightAtIndexPath.removeValue(forKey: indexPathOfHWCell!)

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
        calendarTaskManagerVC.tableView.beginUpdates()
        if (calendarTaskManagerVC.extendedTasks.count == 0) {
            if let extendedTasksSection = calendarTaskManagerVC.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = calendarTaskManagerVC.sections.index(of: extendedTasksSection)!
                calendarTaskManagerVC.sections.removeObject(object: extendedTasksSection)
                calendarTaskManagerVC.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        calendarTaskManagerVC.tableView.endUpdates()
        //

        self.homeVC!.tableView.reloadData()
    }

    @IBAction func doneBtnTouchUpInside(_ sender: Any) {
        let senderButton = sender as? UIButton
        senderButton?.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .normal)
        self.navigationController?.popViewController(animated: true)
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

    func upDateNotifications(){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.setRemindersNotifications()
    }

    func updateInformationalLabelText() {
        /*if (self.task.scope == "Regular") {
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
        }*/
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
