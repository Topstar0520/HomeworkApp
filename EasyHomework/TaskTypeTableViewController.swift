//
//  TaskTypeTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-04-15.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class TaskTypeTableViewController: UITableViewController {
    
    //[Rows]
    //var taskTypes : [String] = ["Assignment", "Quiz", "Midterm", "Final", "Lecture", "Lab", "Tutorial"] //, "Lab", "Tutorial"
    
    var taskTypes : [Int : Array<String>] = [0 : [], 1 : ["Assignment", "Quiz", "Midterm", "Final"], 2: ["Lecture", "Lab", "Tutorial"]]
    var task: RLMTask!
    var homeVC: HomeworkViewController?
    var taskManager: UIViewController? //if relevant
    var cellEditingVC: CellEditingTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.cellEditingVC?.helperObject.mode == .Edit) {
            if (self.task.scope == "Regular") {
                self.taskTypes = [0 : [], 1 : ["Assignment", "Quiz", "Midterm", "Final"]]
            } else if (self.task.scope == "Event") {
                self.taskTypes = [0 : [], 1: ["Lecture", "Lab", "Tutorial"]]
            }
        }

        self.title = self.task.type
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.separatorColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1.0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.taskTypes.count //for 1st section which is actually just empty space.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskTypes[section]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let taskType = self.taskTypes[indexPath.section]![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeTableViewCell", for: indexPath) as! TaskTypeTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.taskLabel.text = taskType
        cell.taskImageView.image = UIImage(named: "Default" + taskType)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (self.cellEditingVC?.helperObject.mode == .Create) {
            if (section == 1) {
                let headerView = SectionHeaderView.construct("Tasks", owner: tableView)
                headerView.contentView.backgroundColor = UIColor.clear
                return headerView
            }
            if (section == 2) {
                let headerView = SectionHeaderView.construct("Events", owner: tableView)
                headerView.contentView.backgroundColor = UIColor.clear
                return headerView
            }
        }
        
        if (self.cellEditingVC?.helperObject.mode == .Edit) {
            if (section == 1) {
                if (self.task.scope == "Regular") {
                    let headerView = SectionHeaderView.construct("Tasks", owner: tableView)
                    headerView.contentView.backgroundColor = UIColor.clear
                    return headerView
                }
                if (self.task.scope == "Events") {
                    let headerView = SectionHeaderView.construct("Events", owner: tableView)
                    headerView.contentView.backgroundColor = UIColor.clear
                    return headerView
                }
            }
        }
        
        let invisView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        invisView.contentView.backgroundColor = UIColor.clear
        return invisView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 26
            //if (self.cellEditingVC?.helperObject.mode == .Create) { return 26 }
            //return CGFloat.leastNormalMagnitude
        }
        return 21
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
        if (cell.contentView.backgroundColor != UIColor.clear) {
            cell.backgroundColor = cell.contentView.backgroundColor
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let taskTypeCell = cell as? TaskTypeTableViewCell {
            taskTypeCell.taskLabel.textColor = UIColor.white
            taskTypeCell.taskImageView.image = UIImage(named: "Default" + self.taskTypes[indexPath.section]![indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        /*if let dueDateCell = cell as? DueDateTableViewCell {
            if (self.task.dueDate == nil) {
                dueDateCell.dueDateLabel.text = "Due Date"
                dueDateCell.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
                dueDateCell.iconImageView.image = #imageLiteral(resourceName: "CalendarBW")
            } else {
                dueDateCell.dueDateLabel.text = self.task.dueDate?.toReadableString()
                dueDateCell.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
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
        
        self.navigationController!.popViewController(animated: true)
    }
    
    func didSelectRowAt_Using_HomeworkHelper(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.title = self.taskTypes[indexPath.section]![indexPath.row]
        //Modify CellEditingVC
        let indexPathInCellEditingVC = self.cellEditingVC?.helperObject.getIndexWithCellIdentifier(identifier: "TypeCell")
        if (indexPathInCellEditingVC != nil) {
            let cellEditingCell = self.cellEditingVC?.tableView.cellForRow(at: indexPathInCellEditingVC!) as? TypeTableViewCell
            cellEditingCell?.taskLabel.text = self.taskTypes[indexPath.section]![indexPath.row]
            cellEditingCell?.taskImageView.image = UIImage(named: "Default" + self.taskTypes[indexPath.section]![indexPath.row])
        }
        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task (& placeholder) and return.
            self.task.type = self.taskTypes[indexPath.section]![indexPath.row]
            self.task.updateScope()
            //
            let regexPattern = "((Assignment)|(Quiz)|(Midterm)|(Final)|(Lecture)|(Lab)|(Tutorial))"
            let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
            let matches = regex.matches(in: self.task.name, options: [], range: NSRange(location: 0, length: self.task.name.count))
            let newPlaceholderTitle = self.cellEditingVC!.helperObject.generatePlaceholderTitle(isNewCourse: true)
            if (matches.count == 1) {
                //Modify underlying data model of CellEditingVC (since it is a dynamic UITableView)
                let cellContent = self.cellEditingVC!.helperObject.dictionary[0]![0] as ScheduleRowContent
                if (cellContent.identifier != "TitleCell") {
                    print("This is not the correct cell having it's cellContent.name updated. Check TaskTypeTableViewController to fix this.")
                }
                cellContent.name = newPlaceholderTitle
                self.task.name = newPlaceholderTitle
                self.cellEditingVC?.title = newPlaceholderTitle
            }
            //and now also adjust the placeholder title itself, which must always occur.
            self.cellEditingVC?.helperObject.placeholderTitleText = newPlaceholderTitle
            //And finally reload rows (also happens outside .Create at the bottom of this method)
            var rowsToReload = [self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "TitleCell")!, self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "DueDateCell")!]
            if let startTimeCellIndexPath = self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "StartTimeCell") {
                rowsToReload.append(startTimeCellIndexPath)
            }
            if let createCellIndexPath = self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "CreateCell") {
                rowsToReload.append(createCellIndexPath)
            }
            self.cellEditingVC?.tableView.reloadRows(at: rowsToReload, with: .none)
            if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") == nil && self.task.timeSet == true && self.task.type != "Assignment") {
                self.cellEditingVC!.helperObject.dictionary[0]?.insert(ScheduleRowContent(identifier: "EndTimeCell"), at: 3)
                self.cellEditingVC?.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .none)
            }
            if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") != nil && (self.task.timeSet == false || self.task.type == "Assignment")) {
                self.cellEditingVC!.helperObject.dictionary[0]?.remove(at: 3)
                self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: .none)
            }
            
            //
            /*let newPlaceholderTitle = self.cellEditingVC?.helperObject.generatePlaceholderTitle(isNewCourse: false)
            self.cellEditingVC?.helperObject.placeholderTitleText = newPlaceholderTitle
           // self.cellEditingVC?.title = newPlaceholderTitle
            self.cellEditingVC?.tableView.reloadRows(at: [self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "TitleCell")!], with: .none)*/
            self.navigationController!.popViewController(animated: true)
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        if let taskTypeCell = cell as? TaskTypeTableViewCell {
            taskTypeCell.taskLabel.textColor = UIColor.white
            taskTypeCell.taskImageView.image = UIImage(named: "Default" + self.taskTypes[indexPath.section]![indexPath.row])
        }
        let realm = try! Realm()
        realm.beginWrite()
        self.task.type = self.taskTypes[indexPath.section]![indexPath.row]
        self.task.updateScope()
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        
        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        let hwCell = self.homeVC?.tableView.cellForRow(at: indexPathOfHWCell!) as? HomeworkTableViewCell
        var staticColorValue = 0
        if (self.task.course != nil) {
            staticColorValue = self.task.course!.colorStaticValue
        }
        self.homeVC?.tableView.beginUpdates()
        CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as? Date, task: self.task, cell: hwCell, taskManager: self.taskManager)
        hwCell?.homeworkImageView.image = UIImage(named: self.task.type + String(staticColorValue))
        /*if (self.task.dueDate != nil) {
            if (task.type == "Assignment") {
                hwCell?.dueDateLabel.attributedText = NSAttributedString(string: (task.dueDate! as NSDate).toRemainingDaysString(), attributes: hwCell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
            } else {
                var remainingDaysString = (task.dueDate! as NSDate).toRemainingDaysString()
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                hwCell?.dueDateLabel.attributedText = NSAttributedString(string: "Scheduled" + remainingDaysString, attributes: hwCell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                if (task.timeSet == true && task.dueDate != nil) {
                    let timeString = DateFormatter.localizedString(from: task.dueDate! as Date, dateStyle: .none, timeStyle: .short)
                    remainingDaysString = remainingDaysString.substring(to: remainingDaysString.index(before: remainingDaysString.endIndex))
                    remainingDaysString += (" at " + timeString + ".")
                    if (task.dueDate!.numberOfDaysUntilDate() == 0 || task.dueDate!.numberOfDaysUntilDate() == 1 || task.dueDate!.numberOfDaysUntilDate() == -1) {
                        remainingDaysString.remove(at: remainingDaysString.startIndex)
                        hwCell?.dueDateLabel.attributedText = NSAttributedString(string: remainingDaysString, attributes: hwCell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                        //cell.dueDateLabel.text = remainingDaysString
                    } else {
                        hwCell?.dueDateLabel.attributedText = NSAttributedString(string: "Scheduled" + remainingDaysString, attributes: hwCell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
                        //cell.dueDateLabel.text = "Scheduled" + remainingDaysString
                    }
                }
            }
        } else {
            if (self.task.type == "Assignment") {
                hwCell?.dueDateLabel.attributedText = NSAttributedString(string: "No due date.", attributes: hwCell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
            } else {
                hwCell?.dueDateLabel.attributedText = NSAttributedString(string: "No date.", attributes: hwCell?.dueDateLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
            }
        }*/
        self.homeVC?.tableView.endUpdates()
        
        //Update default task name if task type was modified to a different type.
        let titleTextFieldCell = self.cellEditingVC!.tableView.cellForRow(at: self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "TitleCell")!) as! TitleTableViewCell
        //Adjust task name in realm if it is a default title for a different task type.
        let regexPattern = "((Assignment)|(Quiz)|(Midterm)|(Final)|(Lecture)|(Lab)|(Tutorial)) [0123456789]+"
        let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
        let matches = regex.matches(in: self.task.name, options: [], range: NSRange(location: 0, length: self.task.name.count))
        let newPlaceholderTitle = self.cellEditingVC!.helperObject.generatePlaceholderTitle(isNewCourse: false)
        if (matches.count >= 1 && matches[0].range.contains(0)) {
            //Modify underlying data model of CellEditingVC (since it is a dynamic UITableView)
            let cellContent = self.cellEditingVC!.helperObject.dictionary[0]![0] as ScheduleRowContent
            if (cellContent.identifier != "TitleCell") {
                print("This is not the correct cell having it's cellContent.name updated. Check TaskTypeTableViewController to fix this.")
            }
            cellContent.name = newPlaceholderTitle
            self.cellEditingVC?.title = newPlaceholderTitle
            let realm = try! Realm()
            realm.beginWrite()
            self.task.name = newPlaceholderTitle
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            hwCell?.titleLabel.attributedText = NSAttributedString(string: self.task.name, attributes: hwCell?.titleLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
        } else if (matches.count == 0) { //Now check for another potential placeholder title, such as "Quiz" instead of "Quiz 1".
            let regexPattern = "((Assignment)|(Quiz)|(Midterm)|(Final)|(Lecture)|(Lab)|(Tutorial))"
            let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
            let matches = regex.matches(in: self.task.name, options: [], range: NSRange(location: 0, length: self.task.name.count))
            let newPlaceholderTitle = self.cellEditingVC!.helperObject.generatePlaceholderTitle(isNewCourse: false)
            if (matches.count >= 1 && matches[0].range.contains(0)) {
                //Modify underlying data model of CellEditingVC (since it is a dynamic UITableView)
                let cellContent = self.cellEditingVC!.helperObject.dictionary[0]![0] as ScheduleRowContent
                if (cellContent.identifier != "TitleCell") {
                    print("This is not the correct cell having it's cellContent.name updated. Check TaskTypeTableViewController to fix this.")
                }
                cellContent.name = newPlaceholderTitle
                self.cellEditingVC?.title = newPlaceholderTitle
                let realm = try! Realm()
                realm.beginWrite()
                self.task.name = newPlaceholderTitle
                do {
                    try realm.commitWrite()
                } catch let error {
                    let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                    errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                    self.present(errorVC, animated: true, completion: nil)
                }
                hwCell?.titleLabel.attributedText = NSAttributedString(string: self.task.name, attributes: hwCell?.titleLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
            }
        }
        //and now also adjust the placeholder title itself, which must always occur.
        self.cellEditingVC?.helperObject.placeholderTitleText = newPlaceholderTitle
        //And finally reload the row for the TitleCell (& other cells that may need updating).
        var rowsToReload = [self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "TitleCell")!, self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "DueDateCell")!]
        if let startTimeCellIndexPath = self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "StartTimeCell") {
            rowsToReload.append(startTimeCellIndexPath)
        }
        self.cellEditingVC?.tableView.reloadRows(at: rowsToReload, with: .none)
        if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") == nil && self.task.timeSet == true && self.task.type != "Assignment") {
            self.cellEditingVC!.helperObject.dictionary[0]?.insert(ScheduleRowContent(identifier: "EndTimeCell"), at: 3)
            self.cellEditingVC?.tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }
        if (self.cellEditingVC!.helperObject.getIndexWithCellIdentifier(identifier: "EndTimeCell") != nil && (self.task.timeSet == false || self.task.type == "Assignment")) {
            self.cellEditingVC!.helperObject.dictionary[0]?.remove(at: 3)
            self.cellEditingVC?.tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: .none)
        }
        
    }
    
    func didSelectRowAt_Using_SchedulesHelper(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Not needed
    }
    
    func didSelectRowAt_Using_WeeklyHelper(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Not needed
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

}
