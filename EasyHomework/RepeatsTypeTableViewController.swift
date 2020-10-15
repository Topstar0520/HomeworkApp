//
//  RepeatsTypeTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2018-08-07.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class RepeatsTypeTableViewController: UITableViewController {

    var repeatsTypes : [Int : Array<String>] = [0 : [], 1 : ["None", "Daily", "Weekly", "Bi-Weekly", "Monthly"]]
    var task: RLMTask!
    var homeVC: HomeworkViewController?
    var taskManager: UIViewController? //if relevant
    var cellEditingVC: CellEditingTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        if (self.cellEditingVC?.helperObject.mode == .Edit) {

        }

        if (self.task.repeatingSchedule != nil) {
            self.title = self.task.repeatingSchedule!.type
        } else {
            self.title = "Repeats"
        }
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.separatorColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1.0)

    }

    override func viewDidAppear(_ animated: Bool) {
        if (self.task.repeatingSchedule == nil) {
            let repeatsCell = self.cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? RepeatsTableViewCell
            repeatsCell?.repeatsLabel.text = "Repeats"
            repeatsCell?.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
            repeatsCell?.iconImageView.image = #imageLiteral(resourceName: "RepeatsBW")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.repeatsTypes.count //for 1st section which is actually just empty space.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repeatsTypes[section]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repeatsType = self.repeatsTypes[indexPath.section]![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatsTypeTableViewCell", for: indexPath) as! RepeatsTypeTableViewCell

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

        cell.repeatsLabel.text = repeatsType
        cell.repeatsImageView.image = UIImage(named: "Default" + repeatsType)

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let invisView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        invisView.contentView.backgroundColor = UIColor.clear
        return invisView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            //return 26
            //if (self.cellEditingVC?.helperObject.mode == .Create) { return 26 }
            //return CGFloat.leastNormalMagnitude
        }
        return 21
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*cell.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
        if (cell.contentView.backgroundColor != UIColor.clear) {
            cell.backgroundColor = cell.contentView.backgroundColor
        }*/
        cell.contentView.backgroundColor = UIColor.clear //since iOS13
    }

    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let repeatsTypeCell = cell as? RepeatsTypeTableViewCell {
            repeatsTypeCell.repeatsLabel.textColor = UIColor.white
            repeatsTypeCell.repeatsImageView.image = UIImage(named: "Default" + self.repeatsTypes[indexPath.section]![indexPath.row])
        }
    }

    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        /*if let dueDateCell = cell as? DueDateTableViewCell {
         if (self.task.dueDate == nil) {
         dueDateCell.dueDateLabel.text = "Due Date"
         dueDateCell.dueDateLabel.textColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.4)
         dueDateCell.iconImageView.image = #imageLiteral(resourceName: "CalendarBW")
         } else {
         dueDateCell.dueDateLabel.text = self.task.dueDate?.toReadableString()
         dueDateCell.dueDateLabel.textColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 1.0)
         dueDateCell.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
         }
         }*/
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.cellEditingVC?.helperObject is HomeworkCellEditingHelperObject) {
            self.didSelectRowAt_Using_HomeworkHelper(tableView, didSelectRowAt: indexPath)
        }

        if (self.cellEditingVC?.helperObject is SchedulesCellEditingHelperObject) {
            self.didSelectRowAt_Using_SchedulesHelper(tableView, didSelectRowAt: indexPath)
        }

        if (self.cellEditingVC?.helperObject is WeeklyCellEditingHelperObject) {
            self.didSelectRowAt_Using_WeeklyHelper(tableView, didSelectRowAt: indexPath)
        }

        if (self.cellEditingVC?.helperObject is CalendarCellEditingHelperObject) {
            self.didSelectRowAt_Using_CalendarHelper(tableView, didSelectRowAt: indexPath)
        }

        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.setRemindersNotifications()

        self.navigationController!.popViewController(animated: true)
    }

    //1)Make datetokens have their startDayOfWeek, startTime, endTime when master task has those properties modified. Make sure the correct dateToken is chosen. DUEDATEVC (Done), StartTimeVC (Done), EndTimeVC (Done).
    //^^ Attach Task to schedule known as 'Master Task'. New Property called 'masterTask'.
    //2)Copy implementation (& modify as needed) to other helpers. (Done)
    func didSelectRowAt_Using_HomeworkHelper(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.title = self.repeatsTypes[indexPath.section]![indexPath.row]

        //If 'None' was tapped..apply changes then return.
        if (self.getIndexWithCellIdentifier(identifier: "None") == indexPath) {
            let repeatsCell = self.cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? RepeatsTableViewCell
            repeatsCell?.repeatsLabel.text = "Repeats"
            repeatsCell?.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
            repeatsCell?.iconImageView.image = #imageLiteral(resourceName: "RepeatsBW")
            if (self.cellEditingVC?.helperObject.mode == .Create) {
                self.task.originalDueDate = nil
                return
            }
            //self.cellEditingVC?.customInputView.isHidden = true

            //If there was a repeating schedule attached to this task before 'None' was tapped, remove it.
            if (self.task.repeatingSchedule != nil && self.cellEditingVC?.helperObject.mode == .Edit) {
                let realm = try! Realm()
                realm.beginWrite()
                self.task.originalDueDate = nil
                //Delete RLMRepeatingSchedule + Tokens
                realm.delete(self.task.repeatingSchedule!.tokens)
                realm.delete(self.task.repeatingSchedule!)
                do {
                    try realm.commitWrite()
                } catch let error {
                    let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                    errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                    self.present(errorVC, animated: true, completion: nil)
                }
            }

            //Reload cells in HWVC (or whichever relevant VCs) to ensure the repeats icon appears/disappears for tasks with same RLMRepeatingSchedule.
            self.updateAllVisibleCellsInHomeworkVC()
            let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
            let hwCell = self.homeVC?.tableView.cellForRow(at: indexPathOfHWCell!) as? HomeworkTableViewCell
            self.homeVC?.tableView.beginUpdates()
            CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCell, taskManager: self.taskManager)
            if (task.repeatingSchedule != nil) {
                hwCell?.repeatsImageView.isHidden = false
            } else {
                hwCell?.repeatsImageView.isHidden = true
            }
            //For other implementations, be sure to ALSO have repeatsImageView.isHidden modified for all relevant VCs.
            self.homeVC?.tableView.endUpdates()
            return
        }

        //We can now assume 'None' was NOT selected for the remainder of this function.

        //Modify CellEditingVC since a repeating schedule has been selected.
        let indexPathInCellEditingVC = self.cellEditingVC?.helperObject.getIndexWithCellIdentifier(identifier: "RepeatsCell")
        if (indexPathInCellEditingVC != nil) {
            let cellEditingCell = self.cellEditingVC?.tableView.cellForRow(at: indexPathInCellEditingVC!) as? RepeatsTableViewCell
            cellEditingCell?.repeatsLabel.text = self.repeatsTypes[indexPath.section]![indexPath.row]
            cellEditingCell?.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            cellEditingCell?.iconImageView.image = UIImage(named: "Default" + self.repeatsTypes[indexPath.section]![indexPath.row])
        }

        var repeatsType = self.repeatsTypes[indexPath.section]![indexPath.row]
        //if the user made no change to existing schedule, just return.
        if (self.task.repeatingSchedule?.schedule == repeatsType) {
            return
        }
        //Currently not possible to have more than one date token for a repeatingSchedule created in this VC. Below two variables purely exist for future extensibility.
        //var tasksToSave = [self.task]
        //var dateTokensToSave = [RLMDateToken]()

        //Create an RLMRepeatingSchedule based on the interval. (daily, weekly, bi-weekly, etc.)
        let repeatingSchedule = RLMRepeatingSchedule(schedule: repeatsType, type: self.task.type, course: self.task.course, location: nil)
        //Create DateToken(s).
        let dayOfWeek = DayOfWeek(id: self.task.dueDate!.dayNumberOfWeek()!)!.rawValue
        let dateToken = RLMDateToken(startTime: self.task.dueDate!, startDayOfWeek: dayOfWeek, endTime: self.task.endDateAndTime)

        if (self.cellEditingVC?.helperObject.mode == .Create) {
            dateToken.lastTaskCreatedDueDate = self.task.dueDate
            repeatingSchedule.tokens.append(dateToken)
            repeatingSchedule.masterTask = self.task
            self.task.repeatingSchedule = repeatingSchedule
            self.task.originalDueDate = self.task.dueDate

            self.navigationController!.popViewController(animated: true)
            return
        }

        //Other wise it's Edit mode so we save the repeating schedule.
        let cell = self.cellEditingVC?.tableView.cellForRow(at: indexPath)
        if let repeatsTypeCell = cell as? RepeatsTypeTableViewCell {
            repeatsTypeCell.repeatsLabel.textColor = UIColor.white
            repeatsTypeCell.repeatsImageView.image = UIImage(named: "Default" + self.repeatsTypes[indexPath.section]![indexPath.row])
        }
        let realm = try! Realm()
        realm.beginWrite()
        //Delete any existing RLMRepeatingSchedule + Tokens
        if (self.task.repeatingSchedule != nil) {
            realm.delete(self.task.repeatingSchedule!.tokens)
            realm.delete(self.task.repeatingSchedule!)
        }
        //Save DateTokens HERE.
        dateToken.lastTaskCreatedDueDate = self.task.dueDate
        repeatingSchedule.tokens.append(dateToken)
        repeatingSchedule.masterTask = self.task
        realm.add(repeatingSchedule)
        self.task.repeatingSchedule = repeatingSchedule
        self.task.originalDueDate = self.task.dueDate
        //Save Repeating Schedule since it was updated.
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }



        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        let hwCell = self.homeVC?.tableView.cellForRow(at: indexPathOfHWCell!) as? HomeworkTableViewCell

        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCell, taskManager: self.taskManager)
        if (task.repeatingSchedule != nil) {
            hwCell?.repeatsImageView.isHidden = false
        } else {
            hwCell?.repeatsImageView.isHidden = true
        }
        //For other implementations, be sure to ALSO have repeatsImageView.isHidden modified for all relevant VCs.
        self.homeVC?.tableView.endUpdates()

        //Reload cells in HWVC (or whichever relevant VCs) to ensure the repeats icon appears/disappears for tasks with same RLMRepeatingSchedule.
        self.updateAllVisibleCellsInHomeworkVC()

        //reload calendar
        self.homeVC?.calendarViewController.fetchTasks()
    }

    func didSelectRowAt_Using_SchedulesHelper(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.title = self.repeatsTypes[indexPath.section]![indexPath.row]

        //If 'None' was tapped..apply changes then return.
        if (self.getIndexWithCellIdentifier(identifier: "None") == indexPath) {
            let repeatsCell = self.cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? RepeatsTableViewCell
            repeatsCell?.repeatsLabel.text = "Repeats"
            repeatsCell?.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
            repeatsCell?.iconImageView.image = #imageLiteral(resourceName: "RepeatsBW")
            if (self.cellEditingVC?.helperObject.mode == .Create) {
                self.task.originalDueDate = nil
                return
            }
            //self.cellEditingVC?.customInputView.isHidden = true

            //If there was a repeating schedule attached to this task before 'None' was tapped, remove it.
            if (self.task.repeatingSchedule != nil && self.cellEditingVC?.helperObject.mode == .Edit) {
                let realm = try! Realm()
                realm.beginWrite()
                self.task.originalDueDate = nil
                //Delete RLMRepeatingSchedule + Tokens
                realm.delete(self.task.repeatingSchedule!.tokens)
                realm.delete(self.task.repeatingSchedule!)
                do {
                    try realm.commitWrite()
                } catch let error {
                    let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                    errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                    self.present(errorVC, animated: true, completion: nil)
                }
            }

            //Reload cells in HWVC (or whichever relevant VCs) to ensure the repeats icon appears/disappears for tasks with same RLMRepeatingSchedule.
            self.updateAllVisibleCellsInHomeworkVC()
            let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
            var hwCell: HomeworkTableViewCell?
            if (indexPathOfHWCell != nil) {
                hwCell = self.homeVC?.tableView.cellForRow(at: indexPathOfHWCell!) as? HomeworkTableViewCell
                self.homeVC?.tableView.beginUpdates()
                CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCell, taskManager: self.taskManager)
            }
            if (task.repeatingSchedule != nil) {
                hwCell?.repeatsImageView.isHidden = false
            } else {
                hwCell?.repeatsImageView.isHidden = true
            }
            let scheduleEditorVC = self.taskManager as! ScheduleEditorViewController
            if (scheduleEditorVC.indexOfTask(task: task) != nil) {
                let hwCellInScheduleEditor = scheduleEditorVC.tableView.cellForRow(at: scheduleEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
                scheduleEditorVC.tableView.beginUpdates()
                CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCellInScheduleEditor, taskManager: self.taskManager)
                if (task.repeatingSchedule != nil) {
                    hwCellInScheduleEditor?.repeatsImageView.isHidden = false
                } else {
                    hwCellInScheduleEditor?.repeatsImageView.isHidden = true
                }
                scheduleEditorVC.tableView.endUpdates()
            }
            //For other implementations, be sure to ALSO have repeatsImageView.isHidden modified for all relevant VCs.
            self.homeVC?.tableView.endUpdates()
            return
        }

        //We can now assume 'None' was NOT selected for the remainder of this function.

        //Modify CellEditingVC since a repeating schedule has been selected.
        let indexPathInCellEditingVC = self.cellEditingVC?.helperObject.getIndexWithCellIdentifier(identifier: "RepeatsCell")
        if (indexPathInCellEditingVC != nil) {
            let cellEditingCell = self.cellEditingVC?.tableView.cellForRow(at: indexPathInCellEditingVC!) as? RepeatsTableViewCell
            cellEditingCell?.repeatsLabel.text = self.repeatsTypes[indexPath.section]![indexPath.row]
            cellEditingCell?.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            cellEditingCell?.iconImageView.image = UIImage(named: "Default" + self.repeatsTypes[indexPath.section]![indexPath.row])
        }

        var repeatsType = self.repeatsTypes[indexPath.section]![indexPath.row]
        //if the user made no change to existing schedule, just return.
        if (self.task.repeatingSchedule?.schedule == repeatsType) {
            return
        }
        //Currently not possible to have more than one date token for a repeatingSchedule created in this VC. Below two variables purely exist for future extensibility.
        //var tasksToSave = [self.task]
        //var dateTokensToSave = [RLMDateToken]()

        //Create an RLMRepeatingSchedule based on the interval. (daily, weekly, bi-weekly, etc.)
        let repeatingSchedule = RLMRepeatingSchedule(schedule: repeatsType, type: self.task.type, course: self.task.course, location: nil)
        //Create DateToken(s).
        let dayOfWeek = DayOfWeek(id: self.task.dueDate!.dayNumberOfWeek()!)!.rawValue
        let dateToken = RLMDateToken(startTime: self.task.dueDate!, startDayOfWeek: dayOfWeek, endTime: self.task.endDateAndTime)

        if (self.cellEditingVC?.helperObject.mode == .Create) {
            dateToken.lastTaskCreatedDueDate = self.task.dueDate
            repeatingSchedule.tokens.append(dateToken)
            repeatingSchedule.masterTask = self.task
            self.task.repeatingSchedule = repeatingSchedule
            self.task.originalDueDate = self.task.dueDate

            self.navigationController!.popViewController(animated: true)
            return
        }

        //Other wise it's Edit mode so we save the repeating schedule.
        let cell = self.cellEditingVC?.tableView.cellForRow(at: indexPath)
        if let repeatsTypeCell = cell as? RepeatsTypeTableViewCell {
            repeatsTypeCell.repeatsLabel.textColor = UIColor.white
            repeatsTypeCell.repeatsImageView.image = UIImage(named: "Default" + self.repeatsTypes[indexPath.section]![indexPath.row])
        }
        let realm = try! Realm()
        realm.beginWrite()
        //Delete any existing RLMRepeatingSchedule + Tokens
        if (self.task.repeatingSchedule != nil) {
            realm.delete(self.task.repeatingSchedule!.tokens)
            realm.delete(self.task.repeatingSchedule!)
        }
        //Save DateTokens HERE.
        dateToken.lastTaskCreatedDueDate = self.task.dueDate
        repeatingSchedule.tokens.append(dateToken)
        repeatingSchedule.masterTask = self.task
        realm.add(repeatingSchedule)
        self.task.repeatingSchedule = repeatingSchedule
        self.task.originalDueDate = self.task.dueDate
        //Save Repeating Schedule since it was updated.
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }



        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        let hwCell = self.homeVC?.tableView.cellForRow(at: indexPathOfHWCell!) as? HomeworkTableViewCell

        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCell, taskManager: self.taskManager)
        if (task.repeatingSchedule != nil) {
            hwCell?.repeatsImageView.isHidden = false
        } else {
            hwCell?.repeatsImageView.isHidden = true
        }
        self.homeVC?.tableView.endUpdates()

        let scheduleEditorVC = self.taskManager as! ScheduleEditorViewController
        if (scheduleEditorVC.indexOfTask(task: task) != nil) {
            let hwCellInScheduleEditor = scheduleEditorVC.tableView.cellForRow(at: scheduleEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
            scheduleEditorVC.tableView.beginUpdates()
            CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCellInScheduleEditor, taskManager: self.taskManager)
            if (task.repeatingSchedule != nil) {
                hwCellInScheduleEditor?.repeatsImageView.isHidden = false
            } else {
                hwCellInScheduleEditor?.repeatsImageView.isHidden = true
            }
            scheduleEditorVC.tableView.endUpdates()
        }

        //Reload cells in HWVC (or whichever relevant VCs) to ensure the repeats icon appears/disappears for tasks with same RLMRepeatingSchedule.
        self.updateAllVisibleCellsInHomeworkVC()

        for tableView in TaskManagerTracker.taskManagers() { //Handle any other existing TaskManagers.
            if !(tableView?.parentViewController == self.homeVC || tableView?.parentViewController == self.taskManager) {
                tableView?.reloadData()
            }
        }
    }

    func didSelectRowAt_Using_WeeklyHelper(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.title = self.repeatsTypes[indexPath.section]![indexPath.row]

        //If 'None' was tapped..apply changes then return.
        if (self.getIndexWithCellIdentifier(identifier: "None") == indexPath) {
            let repeatsCell = self.cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? RepeatsTableViewCell
            repeatsCell?.repeatsLabel.text = "Repeats"
            repeatsCell?.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
            repeatsCell?.iconImageView.image = #imageLiteral(resourceName: "RepeatsBW")
            if (self.cellEditingVC?.helperObject.mode == .Create) {
                self.task.originalDueDate = nil
                return
            }
            //self.cellEditingVC?.customInputView.isHidden = true

            //If there was a repeating schedule attached to this task before 'None' was tapped, remove it.
            if (self.task.repeatingSchedule != nil && self.cellEditingVC?.helperObject.mode == .Edit) {
                let realm = try! Realm()
                realm.beginWrite()
                self.task.originalDueDate = nil
                //Delete RLMRepeatingSchedule + Tokens
                realm.delete(self.task.repeatingSchedule!.tokens)
                realm.delete(self.task.repeatingSchedule!)
                do {
                    try realm.commitWrite()
                } catch let error {
                    let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                    errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                    self.present(errorVC, animated: true, completion: nil)
                }
            }

            //Reload cells in HWVC (or whichever relevant VCs) to ensure the repeats icon appears/disappears for tasks with same RLMRepeatingSchedule.
            self.updateAllVisibleCellsInHomeworkVC()
            let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
            let hwCell = self.homeVC?.tableView.cellForRow(at: indexPathOfHWCell!) as? HomeworkTableViewCell
            self.homeVC?.tableView.beginUpdates()
            CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCell, taskManager: self.taskManager)
            if (task.repeatingSchedule != nil) {
                hwCell?.repeatsImageView.isHidden = false
            } else {
                hwCell?.repeatsImageView.isHidden = true
            }
            //For other implementations, be sure to ALSO have repeatsImageView.isHidden modified for all relevant VCs.
            self.homeVC?.tableView.endUpdates()

            let weeklyEditorVC = self.taskManager as! WeeklyEditingTableViewController
            if (weeklyEditorVC.indexOfTask(task: task) != nil) {
                let hwCellInWeeklyEditor = weeklyEditorVC.tableView.cellForRow(at: weeklyEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
                weeklyEditorVC.tableView.beginUpdates()
                CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCellInWeeklyEditor, taskManager: self.taskManager)
                if (task.repeatingSchedule != nil) {
                    hwCellInWeeklyEditor?.repeatsImageView.isHidden = false
                } else {
                    hwCellInWeeklyEditor?.repeatsImageView.isHidden = true
                }
                weeklyEditorVC.tableView.endUpdates()
            }
            return
        }

        //We can now assume 'None' was NOT selected for the remainder of this function.

        //Modify CellEditingVC since a repeating schedule has been selected.
        let indexPathInCellEditingVC = self.cellEditingVC?.helperObject.getIndexWithCellIdentifier(identifier: "RepeatsCell")
        if (indexPathInCellEditingVC != nil) {
            let cellEditingCell = self.cellEditingVC?.tableView.cellForRow(at: indexPathInCellEditingVC!) as? RepeatsTableViewCell
            cellEditingCell?.repeatsLabel.text = self.repeatsTypes[indexPath.section]![indexPath.row]
            cellEditingCell?.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            cellEditingCell?.iconImageView.image = UIImage(named: "Default" + self.repeatsTypes[indexPath.section]![indexPath.row])
        }

        var repeatsType = self.repeatsTypes[indexPath.section]![indexPath.row]
        //if the user made no change to existing schedule, just return.
        if (self.task.repeatingSchedule?.schedule == repeatsType) {
            return
        }
        //Currently not possible to have more than one date token for a repeatingSchedule created in this VC. Below two variables purely exist for future extensibility.
        //var tasksToSave = [self.task]
        //var dateTokensToSave = [RLMDateToken]()

        //Create an RLMRepeatingSchedule based on the interval. (daily, weekly, bi-weekly, etc.)
        let repeatingSchedule = RLMRepeatingSchedule(schedule: repeatsType, type: self.task.type, course: self.task.course, location: nil)
        //Create DateToken(s).
        let dayOfWeek = DayOfWeek(id: self.task.dueDate!.dayNumberOfWeek()!)!.rawValue
        let dateToken = RLMDateToken(startTime: self.task.dueDate!, startDayOfWeek: dayOfWeek, endTime: self.task.endDateAndTime)

        if (self.cellEditingVC?.helperObject.mode == .Create) {
            dateToken.lastTaskCreatedDueDate = self.task.dueDate
            repeatingSchedule.tokens.append(dateToken)
            repeatingSchedule.masterTask = self.task
            self.task.repeatingSchedule = repeatingSchedule
            self.task.originalDueDate = self.task.dueDate

            self.navigationController!.popViewController(animated: true)
            return
        }

        //Other wise it's Edit mode so we save the repeating schedule.
        let cell = self.cellEditingVC?.tableView.cellForRow(at: indexPath)
        if let repeatsTypeCell = cell as? RepeatsTypeTableViewCell {
            repeatsTypeCell.repeatsLabel.textColor = UIColor.white
            repeatsTypeCell.repeatsImageView.image = UIImage(named: "Default" + self.repeatsTypes[indexPath.section]![indexPath.row])
        }
        let realm = try! Realm()
        realm.beginWrite()
        //Delete any existing RLMRepeatingSchedule + Tokens
        if (self.task.repeatingSchedule != nil) {
            realm.delete(self.task.repeatingSchedule!.tokens)
            realm.delete(self.task.repeatingSchedule!)
        }
        //Save DateTokens HERE.
        dateToken.lastTaskCreatedDueDate = self.task.dueDate
        repeatingSchedule.tokens.append(dateToken)
        repeatingSchedule.masterTask = self.task
        realm.add(repeatingSchedule)
        self.task.repeatingSchedule = repeatingSchedule
        self.task.originalDueDate = self.task.dueDate
        //Save Repeating Schedule since it was updated.
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }



        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        let hwCell = self.homeVC?.tableView.cellForRow(at: indexPathOfHWCell!) as? HomeworkTableViewCell

        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCell, taskManager: self.taskManager)
        if (task.repeatingSchedule != nil) {
            hwCell?.repeatsImageView.isHidden = false
        } else {
            hwCell?.repeatsImageView.isHidden = true
        }
        self.homeVC?.tableView.endUpdates()

        let weeklyEditorVC = self.taskManager as! WeeklyEditingTableViewController
        if (weeklyEditorVC.indexOfTask(task: task) != nil) {
            let hwCellInWeeklyEditor = weeklyEditorVC.tableView.cellForRow(at: weeklyEditorVC.indexOfTask(task: task)!) as? HomeworkTableViewCell
            weeklyEditorVC.tableView.beginUpdates()
            CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCellInWeeklyEditor, taskManager: self.taskManager)
            if (task.repeatingSchedule != nil) {
                hwCellInWeeklyEditor?.repeatsImageView.isHidden = false
            } else {
                hwCellInWeeklyEditor?.repeatsImageView.isHidden = true
            }
            weeklyEditorVC.tableView.endUpdates()
        }

        //Reload cells in HWVC (or whichever relevant VCs) to ensure the repeats icon appears/disappears for tasks with same RLMRepeatingSchedule.
        self.updateAllVisibleCellsInHomeworkVC()

        for tableView in TaskManagerTracker.taskManagers() { //Handle any other existing TaskManagers.
            if !(tableView?.parentViewController == self.homeVC || tableView?.parentViewController == self.taskManager) {
                tableView?.reloadData()
            }
        }
    }

    func didSelectRowAt_Using_CalendarHelper(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.title = self.repeatsTypes[indexPath.section]![indexPath.row]

        //If 'None' was tapped..apply changes then return.
        if (self.getIndexWithCellIdentifier(identifier: "None") == indexPath) {
            let repeatsCell = self.cellEditingVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? RepeatsTableViewCell
            repeatsCell?.repeatsLabel.text = "Repeats"
            repeatsCell?.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
            repeatsCell?.iconImageView.image = #imageLiteral(resourceName: "RepeatsBW")
            if (self.cellEditingVC?.helperObject.mode == .Create) {
                self.task.originalDueDate = nil
                return
            }
            //self.cellEditingVC?.customInputView.isHidden = true

            //If there was a repeating schedule attached to this task before 'None' was tapped, remove it.
            if (self.task.repeatingSchedule != nil && self.cellEditingVC?.helperObject.mode == .Edit) {
                let realm = try! Realm()
                realm.beginWrite()
                self.task.originalDueDate = nil
                //Delete RLMRepeatingSchedule + Tokens
                realm.delete(self.task.repeatingSchedule!.tokens)
                realm.delete(self.task.repeatingSchedule!)
                do {
                    try realm.commitWrite()
                } catch let error {
                    let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                    errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                    self.present(errorVC, animated: true, completion: nil)
                }
            }

            //Reload cells in HWVC (or whichever relevant VCs) to ensure the repeats icon appears/disappears for tasks with same RLMRepeatingSchedule.
            self.updateAllVisibleCellsInCalendarVC()
            let calendarTaskManagerVC = self.taskManager as! CalendarTaskManagerViewController
            let indexPathOfHWCell = calendarTaskManagerVC.indexOfTask(task: self.task)
            let hwCell = calendarTaskManagerVC.tableView.cellForRow(at: indexPathOfHWCell!) as? HomeworkTableViewCell
            calendarTaskManagerVC.tableView.beginUpdates()
            CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCell, taskManager: self.taskManager)
            if (task.repeatingSchedule != nil) {
                hwCell?.repeatsImageView.isHidden = false
            } else {
                hwCell?.repeatsImageView.isHidden = true
            }
            //For other implementations, be sure to ALSO have repeatsImageView.isHidden modified for all relevant VCs.
            calendarTaskManagerVC.tableView.endUpdates()
            return
        }

        //We can now assume 'None' was NOT selected for the remainder of this function.

        //Modify CellEditingVC since a repeating schedule has been selected.
        let indexPathInCellEditingVC = self.cellEditingVC?.helperObject.getIndexWithCellIdentifier(identifier: "RepeatsCell")
        if (indexPathInCellEditingVC != nil) {
            let cellEditingCell = self.cellEditingVC?.tableView.cellForRow(at: indexPathInCellEditingVC!) as? RepeatsTableViewCell
            cellEditingCell?.repeatsLabel.text = self.repeatsTypes[indexPath.section]![indexPath.row]
            cellEditingCell?.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            cellEditingCell?.iconImageView.image = UIImage(named: "Default" + self.repeatsTypes[indexPath.section]![indexPath.row])
        }

        var repeatsType = self.repeatsTypes[indexPath.section]![indexPath.row]
        //if the user made no change to existing schedule, just return.
        if (self.task.repeatingSchedule?.schedule == repeatsType) {
            return
        }
        //Currently not possible to have more than one date token for a repeatingSchedule created in this VC. Below two variables purely exist for future extensibility.
        //var tasksToSave = [self.task]
        //var dateTokensToSave = [RLMDateToken]()

        //Create an RLMRepeatingSchedule based on the interval. (daily, weekly, bi-weekly, etc.)
        let repeatingSchedule = RLMRepeatingSchedule(schedule: repeatsType, type: self.task.type, course: self.task.course, location: nil)
        //Create DateToken(s).
        let dayOfWeek = DayOfWeek(id: self.task.dueDate!.dayNumberOfWeek()!)!.rawValue
        let dateToken = RLMDateToken(startTime: self.task.dueDate!, startDayOfWeek: dayOfWeek, endTime: self.task.endDateAndTime)

        if (self.cellEditingVC?.helperObject.mode == .Create) {
            dateToken.lastTaskCreatedDueDate = self.task.dueDate
            repeatingSchedule.tokens.append(dateToken)
            repeatingSchedule.masterTask = self.task
            self.task.repeatingSchedule = repeatingSchedule
            self.task.originalDueDate = self.task.dueDate

            self.navigationController!.popViewController(animated: true)
            return
        }

        //Other wise it's Edit mode so we save the repeating schedule.
        let cell = self.cellEditingVC?.tableView.cellForRow(at: indexPath)
        if let repeatsTypeCell = cell as? RepeatsTypeTableViewCell {
            repeatsTypeCell.repeatsLabel.textColor = UIColor.white
            repeatsTypeCell.repeatsImageView.image = UIImage(named: "Default" + self.repeatsTypes[indexPath.section]![indexPath.row])
        }
        let realm = try! Realm()
        realm.beginWrite()
        //Delete any existing RLMRepeatingSchedule + Tokens
        if (self.task.repeatingSchedule != nil) {
            realm.delete(self.task.repeatingSchedule!.tokens)
            realm.delete(self.task.repeatingSchedule!)
        }
        //Save DateTokens HERE.
        dateToken.lastTaskCreatedDueDate = self.task.dueDate
        repeatingSchedule.tokens.append(dateToken)
        repeatingSchedule.masterTask = self.task
        realm.add(repeatingSchedule)
        self.task.repeatingSchedule = repeatingSchedule
        self.task.originalDueDate = self.task.dueDate
        //Save Repeating Schedule since it was updated.
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }


        let calendarTaskManagerVC = self.taskManager as! CalendarTaskManagerViewController
        let indexPathOfHWCell = calendarTaskManagerVC.indexOfTask(task: self.task)
        let hwCell = calendarTaskManagerVC.tableView.cellForRow(at: indexPathOfHWCell!) as? HomeworkTableViewCell

        calendarTaskManagerVC.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCell, taskManager: self.taskManager)
        if (task.repeatingSchedule != nil) {
            hwCell?.repeatsImageView.isHidden = false
        } else {
            hwCell?.repeatsImageView.isHidden = true
        }
        //For other implementations, be sure to ALSO have repeatsImageView.isHidden modified for all relevant VCs.
        calendarTaskManagerVC.tableView.endUpdates()

        //Reload cells in HWVC (or whichever relevant VCs) to ensure the repeats icon appears/disappears for tasks with same RLMRepeatingSchedule.
        self.updateAllVisibleCellsInHomeworkVC()

        self.homeVC!.tableView.reloadData()
    }

    func updateAllVisibleCellsInHomeworkVC() {
        let visibleIndexPaths = self.homeVC!.tableView.indexPathsForVisibleRows
        if (visibleIndexPaths != nil) {
            for indexPath in visibleIndexPaths! {
                let task = self.homeVC!.tasks(inSection: indexPath.section)[indexPath.row]
                let hwCell = self.homeVC!.tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
                self.homeVC!.tableView.beginUpdates()
                CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: task.dueDate as? Date, task: task, cell: hwCell, taskManager: self.taskManager)
                if (task.repeatingSchedule != nil) {
                    hwCell?.repeatsImageView.isHidden = false
                } else {
                    hwCell?.repeatsImageView.isHidden = true
                }
                self.homeVC!.tableView.endUpdates()
            }
        }
    }

    func updateAllVisibleCellsInCalendarVC() {
        let calendarTaskManagerVC = self.taskManager as! CalendarTaskManagerViewController
        let visibleIndexPaths = calendarTaskManagerVC.tableView.indexPathsForVisibleRows
        if (visibleIndexPaths != nil) {
            for indexPath in visibleIndexPaths! {
                let task = calendarTaskManagerVC.tasks(inSection: indexPath.section)[indexPath.row]
                let hwCell = calendarTaskManagerVC.tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
                calendarTaskManagerVC.tableView.beginUpdates()
                CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: task.dueDate as? Date, task: task, cell: hwCell, taskManager: self.taskManager)
                if (task.repeatingSchedule != nil) {
                    hwCell?.repeatsImageView.isHidden = false
                } else {
                    hwCell?.repeatsImageView.isHidden = true
                }
                calendarTaskManagerVC.tableView.endUpdates()
            }
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func getIndexWithCellIdentifier(identifier: String) -> IndexPath? {
        for (key, contentArray) in self.repeatsTypes {
            var index = 0
            for content in contentArray {
                if (content == identifier) {
                    return IndexPath(row: index, section: key)
                }
                index = index + 1
            }
        }
        print("Could not find the specified cell. Check CellEditingVC for details.")
        return nil
    }

}
