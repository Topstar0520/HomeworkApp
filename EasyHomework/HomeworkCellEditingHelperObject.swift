//
//  HomeworkCellEditingHelperObject.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-06-13.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class HomeworkCellEditingHelperObject: NSObject, CellEditingProtocol {
    
    var cellEditingTVC: CellEditingTableViewController!
    
    var dictionary = [0 : [ScheduleRowContent(identifier: "TitleCell"), ScheduleRowContent(identifier: "DueDateCell")], 1 : [ScheduleRowContent(identifier: "TypeCell"), ScheduleRowContent(identifier: "CourseCell")] ] //2 : [ScheduleRowContent(identifier: "WriteReviewCell") //[Section : Rows]
    var task: RLMTask!
    var taskManagerVC: UIViewController? //i.e. HomeViewController or any other VC that actuallys shows the task that was selected. Cast this property to the expected UIViewController and use it.
    var placeholderTitleText: String!
    var mode: TaskEditingMode = TaskEditingMode.Edit //Edit is default mode.
    var homeVC: HomeworkViewController?
    var subTaskSectionIndex: Int?
    
    init(cellEditingTVC: CellEditingTableViewController, task: RLMTask, taskManagerVC: UIViewController?, homeVC: HomeworkViewController?) {
        super.init()

        self.cellEditingTVC = cellEditingTVC
        self.taskManagerVC = taskManagerVC
        self.homeVC = homeVC //taskManagerVC as? HomeworkViewController
        self.task = task
        self.placeholderTitleText = self.generatePlaceholderTitle(isNewCourse: false)
        self.cellEditingTVC.title = self.placeholderTitleText
        if (self.task.dueDate != nil) {
            self.dictionary[0]?.insert(ScheduleRowContent(identifier: "StartTimeCell"), at: 2)
            self.dictionary[2] = [ScheduleRowContent(identifier: "RepeatsCell")]
            self.dictionary[3] = [ScheduleRowContent(identifier: "SubTaskCell")]
            self.dictionary[4] = [ScheduleRowContent(identifier: "NoteCell")]
            self.subTaskSectionIndex = 3
            self.addRowsForSubTasks(index: 3)
            self.addRowsForNote(index: 4)
        } else {
            self.dictionary[2] = [ScheduleRowContent(identifier: "SubTaskCell")]
            self.dictionary[3] = [ScheduleRowContent(identifier: "NoteCell")]
            self.addRowsForSubTasks(index: 2)
            self.addRowsForNote(index: 3)
            self.subTaskSectionIndex = 2
        }
        if (self.task.timeSet == true && self.task.type != "Assignment") {
            self.dictionary[0]?.insert(ScheduleRowContent(identifier: "EndTimeCell"), at: 3)
        }



    }

    func addRowsForSubTasks(index: Int) {
        for _ in task.subTasks {
            self.dictionary[index]?.insert(ScheduleRowContent(identifier: "SubTaskCell"), at: 0)
        }
    }
    
    func addRowsForNote(index: Int) {
        for _ in task.note2 {
            self.dictionary[index]?.insert(ScheduleRowContent(identifier: "NoteCell"), at: 0)
        }
    }
    
    

    func deleteSubTaskAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure, you want to delete?", preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.deleteSubTask(indexPath: indexPath)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        cellEditingTVC.present(alert, animated: true, completion: nil)
    }

    func deleteSubTask(indexPath: IndexPath) {

        let subTask = self.task.subTasks[indexPath.row]

        RLMTask.deleteSubTask(task: self.task, subTask: subTask, completion: { (success) in
            print("Deleted")
            self.dictionary[indexPath.section]?.remove(at: indexPath.row)
            self.cellEditingTVC.tableView.beginUpdates()
            self.cellEditingTVC.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.cellEditingTVC.tableView.endUpdates()
        })
    }

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dictionary.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionary[section]?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContent = dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row] as ScheduleRowContent
        let cell = tableView.dequeueReusableCell(withIdentifier: cellContent.identifier, for: indexPath)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        if (cell is TitleTableViewCell) {
            let titleCell = cell as! TitleTableViewCell
            titleCell.titleTextView.delegate = self
            titleCell.titleTextView.placeholderTextColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.2)
            if (self.placeholderTitleText != cellContent.name) {
                titleCell.titleTextView.text = cellContent.name
            } else {
                titleCell.titleTextView.text = ""
            }

            titleCell.clearButton.addTarget(self, action: #selector(clearCellText), for: .touchUpInside)
        }
        
        if (cell is DueDateTableViewCell) {
            let dueDateCell = cell as! DueDateTableViewCell
            if (self.task.dueDate == nil) {
                if (self.task.type == "Assignment") {
                    dueDateCell.dueDateLabel.text = "Due Date"
                } else {
                    dueDateCell.dueDateLabel.text = "Date"
                }
                dueDateCell.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
                dueDateCell.iconImageView.image = #imageLiteral(resourceName: "CalendarBW")
            } else {
                dueDateCell.dueDateLabel.text = self.task.dueDate?.toReadableString()
                dueDateCell.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                dueDateCell.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
            }
        }
        
        if (cell is StartTimeTableViewCell) {
            let startTimeCell = cell as! StartTimeTableViewCell
            if (self.task.timeSet == false) {
                if (self.task.type == "Assignment") {
                    startTimeCell.startTimeLabel.text = "Time Due"
                } else {
                    startTimeCell.startTimeLabel.text = "Start Time"
                }
                startTimeCell.startTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
                startTimeCell.iconImageView.image = #imageLiteral(resourceName: "StartClockBW")
            } else {
                if (self.task.type == "Assignment") {
                    startTimeCell.startTimeLabel.text = "Due " + self.task.dueDate!.toReadableTimeString()
                } else {
                    startTimeCell.startTimeLabel.text = "Starts " + self.task.dueDate!.toReadableTimeString()
                }
                startTimeCell.startTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                startTimeCell.iconImageView.image = #imageLiteral(resourceName: "DefaultStartClock")
            }
            
        }
        
        if (cell is EndTimeTableViewCell) {
            let endTimeCell = cell as! EndTimeTableViewCell
            if (self.task.endDateAndTime == nil) {
                endTimeCell.endTimeLabel.text = "End Time"
                endTimeCell.endTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
                endTimeCell.iconImageView.image = #imageLiteral(resourceName: "EndTimeBW")
            } else {
                endTimeCell.endTimeLabel.text = "Ends " + self.task.endDateAndTime!.toReadableTimeString()
                endTimeCell.endTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                endTimeCell.iconImageView.image = #imageLiteral(resourceName: "DefaultStopClock")
            }
            
        }
        
        if (cell is TypeTableViewCell) {
            let taskCell = cell as! TypeTableViewCell
            taskCell.taskLabel.text = self.task.type
            taskCell.taskImageView.image = UIImage(named: "Default" + self.task.type)
        }
        
        if (cell is RepeatsTableViewCell) {
            let repeatsCell = cell as! RepeatsTableViewCell
            if (self.task.repeatingSchedule == nil) {
                repeatsCell.repeatsLabel.text = "Repeats"
                repeatsCell.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
                repeatsCell.iconImageView.image = #imageLiteral(resourceName: "RepeatsBW")
            } else {
                repeatsCell.repeatsLabel.text = self.task.repeatingSchedule!.schedule
                repeatsCell.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                repeatsCell.iconImageView.image = UIImage(named: "Default" + self.task.repeatingSchedule!.schedule)
            }
        }
        
        if (cell is CourseTableViewCell) {
            let courseCell = cell as! CourseTableViewCell
            if (self.task.course != nil) {
                if (self.task.course!.courseCode != nil) {
                    courseCell.courseTitleLabel.text = self.task.course!.courseCode! + " - " + self.task.course!.courseName
                } else {
                    courseCell.courseTitleLabel.text = self.task.course!.courseName
                }
                courseCell.courseTitleLabel.textColor = UIColor.white
                courseCell.circleView.color = self.task.course?.color?.getUIColorObject()
            }
        }
        
        if (cell is TitleTableViewCell) {
            let titleCell = cell as! TitleTableViewCell
            titleCell.titleTextView.delegate = self
            titleCell.titleTextView.placeholderTextColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.2) 
            if (self.placeholderTitleText != cellContent.name) {
                titleCell.titleTextView.text = cellContent.name
            } else {
                titleCell.titleTextView.text = ""
            }
        }
        
        
        if (cell is CreateTaskOrEventTableViewCell) {
            let createCell = cell as! CreateTaskOrEventTableViewCell
            if (self.task.scope == "Regular") {
                createCell.createLabel.text = "Create Task"
            } else if (self.task.scope == "Event") {
                createCell.createLabel.text = "Create Event"
            }
        }

        if let cell = cell as? SubTaskTableViewCell {
            cell.delegate = cellEditingTVC
            //            cell.indexPath = indexPath
          
            if UserDefaults.standard.bool(forKey: "isSubscribed") == true {
                cell.subscribeButton.isHidden = true
                cell.subTaskTextView.isEditable = true
            } else {
                cell.subTaskTextView.isEditable = false
                cell.subscribeButton.isHidden = false
            }

            if indexPath.row != task.subTasks.count {
                let subTask = task.subTasks[indexPath.row]
                cell.subTaskTextView.text = subTask.name
//                cell.subTask = subTask

                cell.subTaskTextView.returnKeyType = .done

                if let color = task.course?.color?.getUIColorObject() , subTask.completed == true {
                    cell.checkMarkButton.tintColor = color
                } else {
                    cell.checkMarkButton.tintColor = UIColor(hex: "FFFFFF").withAlphaComponent(0.4)
                }

                if subTask.completed == true {
                    cell.subTaskTextView.textColor = UIColor(hex: "FFFFFF").withAlphaComponent(0.4)
                    cell.checkMarkButton.setImage(#imageLiteral(resourceName: "selected_icon"), for: .normal)
                } else {
                    cell.subTaskTextView.textColor = UIColor.white
                    cell.checkMarkButton.setImage(#imageLiteral(resourceName: "white circle"), for: .normal)
                }

            } else {
//                cell.subTask = nil
                cell.subTaskTextView.returnKeyType = .next
                cell.subTaskTextView.text = ""
                cell.checkMarkButton.setImage(#imageLiteral(resourceName: "plus_light"), for: .normal)
            }

        }
        
        if let noteCell = cell as? NoteTableViewCell {
           
            
            if indexPath.row < self.task.note2.count{
                let noteEditor = self.task.note2[indexPath.row]
                noteCell.noteTitleLabel.text = noteEditor.title == "" ? "Add a Note.." : noteEditor.title
                noteCell.imgVew.image = noteEditor.title == "" ? UIImage(named: "newNote") : UIImage(named: "note")
                noteCell.noteTitleLabel.textColor = UIColor.white
                noteCell.circleView.color = UIColor.white
            }else{
                noteCell.noteTitleLabel.text = "Add a Note.."
                noteCell.imgVew.image = UIImage(named: "newNote")
                noteCell.noteTitleLabel.textColor = UIColor.white.withAlphaComponent(0.40)
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellContent = dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row] as ScheduleRowContent
        /*if (cellContent.identifier == "TitleCell") {
         return 44
         }*/
        return UITableViewAutomaticDimension
    }

    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /* if (section == 0) {
         let headerView = SectionHeaderView.construct("Assignment 1", owner: tableView)
         return headerView
         }
         
         if (section == 1) {
         let headerView = SectionHeaderView.construct("CS2210", owner: tableView)
         return headerView
         }*/
        
        let invisView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        invisView.contentView.backgroundColor = UIColor.clear
        return invisView
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return CGFloat.leastNormalMagnitude
        }
        return 21.0
        //return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
        if (cell.contentView.backgroundColor != UIColor.clear) {
            cell.backgroundColor = cell.contentView.backgroundColor
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let dueDateCell = cell as? DueDateTableViewCell {
            dueDateCell.dueDateLabel.textColor = UIColor.white
            dueDateCell.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
        }
        if let startTimeCell = cell as? StartTimeTableViewCell {
            startTimeCell.startTimeLabel.textColor = UIColor.white
            startTimeCell.iconImageView.image = #imageLiteral(resourceName: "DefaultStartClock")
        }
        if let endTimeCell = cell as? EndTimeTableViewCell {
            endTimeCell.endTimeLabel.textColor = UIColor.white
            endTimeCell.iconImageView.image = #imageLiteral(resourceName: "DefaultStopClock")
        }
        if let repeatsCell = cell as? RepeatsTableViewCell {
            repeatsCell.repeatsLabel.textColor = UIColor.white
            repeatsCell.iconImageView.image = #imageLiteral(resourceName: "DefaultRepeats")
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let dueDateCell = cell as? DueDateTableViewCell {
            if (self.task.dueDate == nil) {
                if (self.task.type == "Assignment") {
                    dueDateCell.dueDateLabel.text = "Due Date"
                } else {
                    dueDateCell.dueDateLabel.text = "Date"
                }
                dueDateCell.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
                dueDateCell.iconImageView.image = #imageLiteral(resourceName: "CalendarBW")
            } else {
                dueDateCell.dueDateLabel.text = self.task.dueDate?.toReadableString()
                dueDateCell.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                dueDateCell.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
            }
        }
        if let startTimeCell = cell as? StartTimeTableViewCell {
            if (self.task.timeSet == false) {
                if (self.task.type == "Assignment") {
                    startTimeCell.startTimeLabel.text = "Time Due"
                } else {
                    startTimeCell.startTimeLabel.text = "Start Time"
                }
                startTimeCell.startTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
                startTimeCell.iconImageView.image = #imageLiteral(resourceName: "StartClockBW")
            } else {
                if (self.task.type == "Assignment") {
                    startTimeCell.startTimeLabel.text = "Due " + self.task.dueDate!.toReadableTimeString()
                } else {
                    startTimeCell.startTimeLabel.text = "Starts " + self.task.dueDate!.toReadableTimeString()
                }
                startTimeCell.startTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                startTimeCell.iconImageView.image = #imageLiteral(resourceName: "DefaultStartClock")
            }
        }
        if let endTimeCell = cell as? EndTimeTableViewCell {
            if (self.task.endDateAndTime == nil) {
                endTimeCell.endTimeLabel.text = "End Time"
                endTimeCell.endTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
                endTimeCell.iconImageView.image = #imageLiteral(resourceName: "EndTimeBW")
            } else {
                endTimeCell.endTimeLabel.text = "Ends " + self.task.endDateAndTime!.toReadableTimeString()
                endTimeCell.endTimeLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                endTimeCell.iconImageView.image = #imageLiteral(resourceName: "DefaultStopClock")
            }
        }
        if let repeatsCell = cell as? RepeatsTableViewCell {
            if (self.task.repeatingSchedule == nil) {
                repeatsCell.repeatsLabel.text = "Repeats"
                repeatsCell.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
                repeatsCell.iconImageView.image = #imageLiteral(resourceName: "RepeatsBW")
            } else {
                repeatsCell.repeatsLabel.text = self.task.repeatingSchedule!.schedule
                repeatsCell.repeatsLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                repeatsCell.iconImageView.image = #imageLiteral(resourceName: "DefaultRepeats")
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == subTaskSectionIndex {
            if indexPath.row != task.subTasks.count {
                return true
            } else {
                return false
            }
        }
        return false
    }

    // For iOS 10.. and below
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            self.deleteSubTask(indexPath: indexPath)
        }

        //        if let cell = tableView.cellForRow(at: indexPath) {
        //            deleteAction.setIcon(iconImage: UIImage(named: "CheckedMarkRead")!, backColor: .blue, cellHeight: cell.bounds.height, iconSizePercentage: 1)
        //        }
        deleteAction.backgroundColor = UIColor.red

        return [deleteAction]
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            self.deleteSubTask(indexPath: indexPath)
            completion(true)
        }

//        deleteAction.image = #imageLiteral(resourceName: "Chat LIst Delete Icon")
        deleteAction.backgroundColor = UIColor.red
        return UISwipeActionsConfiguration(actions: [deleteAction])

    }
    
    var selectedCell: UITableViewCell!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        /* Perform segues and modify appearance for designated cells here. Pass information via the prepareForSegue(..) method below. */
        //Every cell that performs a segue has two segues from the VC to the destinationVC, one of kind show and the other of kind showDetail.
        if let dueDateCell = cell as? DueDateTableViewCell {
            dueDateCell.dueDateLabel.textColor = UIColor.white
            dueDateCell.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
            var segueIdentifier = "showDueDate"
            if (self.mode == TaskEditingMode.Edit) {
                segueIdentifier += "Detail"
            }
            self.cellEditingTVC.performSegue(withIdentifier: segueIdentifier, sender: cell)
        }
        if let startTimeCell = cell as? StartTimeTableViewCell {
            startTimeCell.startTimeLabel.textColor = UIColor.white
            startTimeCell.iconImageView.image = #imageLiteral(resourceName: "DefaultStartClock")
            var segueIdentifier = "showStartTime"
            if (self.mode == TaskEditingMode.Edit) {
                segueIdentifier += "Detail"
            }
            self.cellEditingTVC.performSegue(withIdentifier: segueIdentifier, sender: cell)
        }
        if let endTimeCell = cell as? EndTimeTableViewCell {
            endTimeCell.endTimeLabel.textColor = UIColor.white
            endTimeCell.iconImageView.image = #imageLiteral(resourceName: "DefaultStopClock")
            var segueIdentifier = "showEndTime"
            if (self.mode == TaskEditingMode.Edit) {
             segueIdentifier += "Detail"
            }
            self.cellEditingTVC.performSegue(withIdentifier: segueIdentifier, sender: cell)
        }
        if let typeCell = cell as? TypeTableViewCell {
            var segueIdentifier = "showTaskType"
            if (self.mode == TaskEditingMode.Edit) {
                segueIdentifier += "Detail"
            }
            self.cellEditingTVC.performSegue(withIdentifier: segueIdentifier, sender: cell)
        }
        if let courseCell = cell as? CourseTableViewCell {
            var segueIdentifier = "showCourseSelection"
            if (self.mode == TaskEditingMode.Edit) {
                segueIdentifier += "Detail"
            }
            self.cellEditingTVC.performSegue(withIdentifier: segueIdentifier, sender: cell)
        }
        if let repeatsCell = cell as? RepeatsTableViewCell {
            repeatsCell.repeatsLabel.textColor = UIColor.white
            repeatsCell.iconImageView.image = #imageLiteral(resourceName: "DefaultRepeats")
            var segueIdentifier = "showRepeatsType"
            if (self.mode == TaskEditingMode.Edit) {
                segueIdentifier += "Detail"
            }
            self.cellEditingTVC.performSegue(withIdentifier: segueIdentifier, sender: cell)
        }
        
        if let noteCell = cell as? NoteTableViewCell {
            var segueIdentifier = "showBasicNoteEditor"
            if (self.mode == TaskEditingMode.Edit) {
                segueIdentifier += "Detail"
            }
            self.cellEditingTVC.performSegue(withIdentifier: segueIdentifier, sender: noteCell)
        }
        /* */
        
        if (cell?.reuseIdentifier == "CreateCell") {
            //save task
            let realm = try! Realm()
            realm.beginWrite()
            print(self.task)
            realm.add(self.task)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.cellEditingTVC.present(errorVC, animated: true, completion: nil)
            }
            //Set any necessary notifications for HomeVC.
            if (self.mode == .Create && self.task.dueDate != nil && self.task.dueDate!.overScopeThreshold(task: task)) {
                self.homeVC?.setNotification(notificationType: "DueDateFarAway", task: self.task)
            }
            //dismiss VC and insert task into homeVC's tableView
            let indexPathOfTask = self.homeVC?.indexOfTask(task: self.task)
            if (indexPathOfTask != nil) {
                //UIView.animate(withDuration: 1.0, animations: { self.homeVC?.emptyHomescreenView.alpha = 0 })
                self.cellEditingTVC.dismiss(animated: true, completion: {
                    UIView.animate(withDuration: 0.1, animations: { self.homeVC?.emptyHomescreenView.alpha = 0 })
                    self.homeVC?.tableView.insertRows(at: [indexPathOfTask!], with: .fade)
                })
            } else {
                self.cellEditingTVC.dismiss(animated: true, completion: nil)
            }
        }
        
        //self.selectedCell = cell
    }

    @objc func clearCellText() {
        if let cell = cellEditingTVC.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TitleTableViewCell {
            cell.titleTextView.text = ""
            textViewDidChange(cell.titleTextView)
        }

    }

    func generatePlaceholderTitle(isNewCourse: Bool) -> String {
        if (self.task.course != nil) {
            let realm = try! Realm()
            let tasksOfSameTypeAndSameCourse = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@ AND removed = false", self.task.type, self.task.course!, self.task.createdDate).sorted(byKeyPath: "createdDate", ascending: false)
            if (isNewCourse == true) {
                return self.task.type + " " + String(tasksOfSameTypeAndSameCourse.count + 1)
            } else {
                return self.task.type + " " + String(tasksOfSameTypeAndSameCourse.count)
            }
        }
        return self.task.type
    }

    func textViewDidChange(_ textView: UITextView) {

        guard let point = cellEditingTVC?.tableView.convert(CGPoint.zero, from: textView) else { return }
        if let indexPath = cellEditingTVC?.tableView.indexPathForRow(at: point) {
            if let cell = cellEditingTVC?.tableView.cellForRow(at: indexPath) as? TitleTableViewCell {
                let fixedWidth = textView.frame.size.width

                // Our base height
                let baseHeight: CGFloat = 35

                if textView.text.last == "\n" {
                    textView.text.removeLast()
                    textView.resignFirstResponder()
                }

                if textView.text != "" {
                    let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
                    let height: CGFloat = newSize.height > baseHeight ? newSize.height : baseHeight

                    cellEditingTVC?.didChange(height, cell: cell)
                } else {
                    cellEditingTVC?.didChange(baseHeight, cell: cell)
                }
            }

        }

        textFieldEdited(sender: textView)
    }

    func textFieldEdited(sender: UITextView) {
        let textField = sender
        //print(textField.text)
        var titleString = textField.text!
        if (titleString.characters.count == 0) {
            titleString = self.placeholderTitleText
        }
        self.cellEditingTVC.title = titleString
        
        //update cellContent.name property (Make sure that the cellContent dictionary index here is correct. It should be TitleCell.)
        let cellContent = dictionary[0]![0] as ScheduleRowContent
        if (cellContent.identifier != "TitleCell") {
            print("This is not the correct cell having it's cellContent.name updated. Check CellEditingTableViewController to fix this.")
        }
        cellContent.name = titleString
        
        if (self.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.name = titleString
            return
        }
        
        let realm = try! Realm()
        realm.beginWrite()
        self.task.name = titleString
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.cellEditingTVC.present(errorVC, animated: true, completion: nil)
        }
        
        //update cell in HomeVC
        let selectedIndexPath = self.homeVC?.indexOfTask(task: self.task)
        if (selectedIndexPath == nil) {
            return
        }
        self.homeVC?.useLastSelectedRowIndexPath = true
        let cell = self.homeVC?.tableView.cellForRow(at: selectedIndexPath!) as? HomeworkTableViewCell
        self.homeVC?.tableView.beginUpdates()
        cell?.titleLabel.attributedText = NSAttributedString(string: titleString, attributes: cell?.titleLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
        self.homeVC?.tableView.endUpdates()
        //self.homeVC?.tableView.reloadRows(at: [selectedIndexPath!], with: .none) //original way of reloading cell.
        self.homeVC?.tableView.selectRow(at: selectedIndexPath!, animated: false, scrollPosition: .none)
        self.homeVC?.heightAtIndexPath.removeValue(forKey: selectedIndexPath!) //Since we no longer have correct cached height, we should remove it.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.cellEditingTVC.tableView.endEditing(false)
        return true
    }
    
    func getIndexWithCellIdentifier(identifier: String) -> IndexPath? {
        for (key, scheduleRowContentArray) in self.dictionary {
            var index = 0
            for scheduleRowContent in scheduleRowContentArray {
                if (scheduleRowContent.identifier == identifier) {
                    return IndexPath(row: index, section: key)
                }
                index = index + 1
            }
        }
        print("Could not find the specified cell. Check CellEditingVC for details.")
        return nil
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var frame: CGRect = self.cellEditingTVC.customInputButton.frame
        frame.origin.y = scrollView.contentOffset.y
        self.cellEditingTVC.customInputButton.frame = frame
        
        self.cellEditingTVC.view.bringSubview(toFront: self.cellEditingTVC.customInputButton)
    }
    
}

