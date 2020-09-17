//
//  CourseSelectionTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-04-16.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class CourseSelectionTableViewController: UITableViewController {

    var task: RLMTask!
    var homeVC: HomeworkViewController?
    var cellEditingVC: CellEditingTableViewController?
    var taskManager: UIViewController? //if relevant
    var courses: [RLMCourse]! //use this for adding the None selection.
    
    var coursesQuery: Results<RLMCourse> {
        let realm = try! Realm()
        return realm.objects(RLMCourse.self).sorted(byKeyPath: "createdDate", ascending: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.task.course?.courseCode != nil) {
            self.title = self.task.course?.courseCode
        } else {
            self.title = self.task.course?.courseName
            if (self.title == nil || self.title == "") {
                self.title = "Course"
            }
        }
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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 0
        } else {
            return self.coursesQuery.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let course = self.coursesQuery[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseSelectionCell", for: indexPath) as! CourseSelectionTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.courseTitleLabel.text = course.courseTitle()
        cell.circleView.color = course.color?.getUIColorObject()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /*
         if (section == 0) {
         let headerView = SectionHeaderView.construct("Assignment 1", owner: tableView)
         return headerView
         }
         */
        
        let invisView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        invisView.contentView.backgroundColor = UIColor.clear
        return invisView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return CGFloat.leastNormalMagnitude
        }
        return 21.0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
        if (cell.contentView.backgroundColor != UIColor.clear) {
            cell.backgroundColor = cell.contentView.backgroundColor
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let courseSelectionCell = cell as? CourseSelectionTableViewCell {
            courseSelectionCell.courseTitleLabel.textColor = UIColor.white
            //courseSelectionCell.circleView.color
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
        if (self.coursesQuery[indexPath.row].courseCode != nil) {
            self.title = self.coursesQuery[indexPath.row].courseCode
        } else {
            self.title = self.coursesQuery[indexPath.row].courseName
        }

        //Modify CellEditingVC
        let indexPathInCellEditingVC = self.cellEditingVC?.helperObject.getIndexWithCellIdentifier(identifier: "CourseCell")
        if (indexPathInCellEditingVC != nil) {
            let cellEditingCell = self.cellEditingVC?.tableView.cellForRow(at: indexPathInCellEditingVC!) as? CourseTableViewCell
            cellEditingCell?.courseTitleLabel.text = self.coursesQuery[indexPath.row].courseTitle()
            cellEditingCell?.courseTitleLabel.textColor = UIColor.white
            cellEditingCell?.circleView.color = self.coursesQuery[indexPath.row].color?.getUIColorObject()
            
        }
        if (self.cellEditingVC?.helperObject.mode == .Create) { //if this is a new task and doesn't have a cell
            //then modify the task and return.
            self.task.course = self.coursesQuery[indexPath.row]
            
            //Handle placeholder, which also occurs again deeper into this method for existing tasks.
            let regexPattern = "((Assignment)|(Quiz)|(Midterm)|(Final)|(Lecture)|(Lab)|(Tutorial))"
            let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
            let matches = regex.matches(in: self.task.name, options: [], range: NSRange(location: 0, length: self.task.name.characters.count))
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
            
            self.navigationController!.popViewController(animated: true)
            return
        }
        let cell = tableView.cellForRow(at: indexPath)
        if let courseSelectionCell = cell as? CourseTableViewCell {
            courseSelectionCell.courseTitleLabel.textColor = UIColor.white
            courseSelectionCell.circleView.color = self.coursesQuery[indexPath.row].color?.getUIColorObject()
        }
        let realm = try! Realm()
        realm.beginWrite()
        self.task.course = self.coursesQuery[indexPath.row]
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        
        let indexPathOfHWCell = self.homeVC?.indexOfTask(task: self.task)
        let hwCell = self.homeVC?.tableView.cellForRow(at: indexPathOfHWCell!) as? HomeworkTableViewCell
        
        //CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: self.task.dueDate as! Date, task: self.task, cell: hwCell, taskManager: self.taskManager) //Should be modified to fit this use case.
        if (self.task.course?.facultyName != nil) {
            hwCell?.facultyImageView.image = UIImage(named: self.task.course!.facultyName!)
        } else {
            hwCell?.facultyImageView.image = UIImage(named: "DefaultFaculty")
        }
        hwCell?.homeworkImageView.image = UIImage(named: self.task.type + String(self.coursesQuery[indexPath.row].colorStaticValue))
        hwCell?.colorView.color = self.coursesQuery[indexPath.row].color?.getUIColorObject()
        if (self.coursesQuery[indexPath.row].courseCode != nil) {
            hwCell?.courseLabel.attributedText = NSAttributedString(string: self.coursesQuery[indexPath.row].courseCode!, attributes: hwCell?.courseLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
        } else {
            hwCell?.courseLabel.attributedText = NSAttributedString(string: self.coursesQuery[indexPath.row].courseName, attributes: hwCell?.courseLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
        }
        
        ////  Handle placeholder naming below.  ////
        
        //Adjust task name in realm if it is a default title for a different task type.
        let regexPattern = "((Assignment)|(Quiz)|(Midterm)|(Final)|(Lecture)|(Lab)|(Tutorial)) [0123456789]+"
        let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
        let matches = regex.matches(in: self.task.name, options: [], range: NSRange(location: 0, length: self.task.name.characters.count))
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
            let matches = regex.matches(in: self.task.name, options: [], range: NSRange(location: 0, length: self.task.name.characters.count))
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
//        self.cellEditingVC?.tableView.reloadRows(at: rowsToReload, with: .none)
        self.cellEditingVC?.tableView.reloadData()

    }
    
    func didSelectRowAt_Using_SchedulesHelper(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Not needed for now.
    }
    
    func didSelectRowAt_Using_WeeklyHelper(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Not needed for now.
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

}
