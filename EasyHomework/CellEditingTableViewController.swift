//
//  CellEditingTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-22.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

enum TaskEditingMode: String {
    case Edit = "Edit", Create = "Create"
    //Edit - for editing an already created task.
    //Create - for creating a new task.
}

//This represents the VC shown after tapping on a task cell like those on the homescreen.
class CellEditingTableViewController: UITableViewController,noteEditorDelegate
    
{
    
    var helperObject: CellEditingProtocol!
    
    //[Section : Rows]
    //var dictionary :[Int:Array<ScheduleRowContent>] = [0 : [ScheduleRowContent(identifier: "TitleCell"), ScheduleRowContent(identifier: "DueDateCell")], 1 : [ScheduleRowContent(identifier: "TypeCell"), ScheduleRowContent(identifier: "CourseCell")] ] //2 : [ScheduleRowContent(identifier: "WriteReviewCell")
    //var task: RLMTask!
    //var homeVC: HomeworkViewController?
    //var placeholderTitleText: String!
    //var mode: TaskEditingMode = TaskEditingMode.Edit //Edit is default mode.
    var customInputButton: ChangeMasterTaskButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.helperObject.mode == .Edit) {
            if (self.helperObject.task.name == self.helperObject.generatePlaceholderTitle(isNewCourse: false)) {
                self.title = self.helperObject.placeholderTitleText
            } else {
                self.title = self.helperObject.task.name
            }
        } else {
            self.title = self.helperObject.placeholderTitleText
        }
        
        self.tableView.estimatedRowHeight = 44
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = helperObject
        self.tableView.delegate = helperObject
        self.tableView.keyboardDismissMode = .onDrag
        //self.tableView.contentInset.top += 17
        self.tableView.separatorColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1.0)
        if (self.helperObject.mode == TaskEditingMode.Create) {
            self.setupForCreateMode()
        }
        
        customInputButton = ChangeMasterTaskButton.construct(self) as ChangeMasterTaskButton
        customInputButton.frame.size = CGSize(width: self.view.bounds.width, height: 44)
        //customInputButton.frame.origin = CGPoint(x: self.tableView.frame.origin.x, y: self.view.frame.height)
        self.view.addSubview(customInputButton)
    }
    
    func setupForCreateMode() {
        //Add 'Cancel' in the top left of the navBar.
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(sender:)))
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = cancelButton
        //Add new 'Create' cell.
        self.helperObject.dictionary[4] = [ScheduleRowContent(identifier: "CreateCell")]
        self.helperObject.dictionary[2] = [ScheduleRowContent(identifier: "SubTaskCell")]
    }
    
    var firstAppearance = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.helperObject.mode == TaskEditingMode.Create && firstAppearance == true && self.tableView != nil) {
            //let titleCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TitleTableViewCell
            if self.tableView.visibleCells.count > 0    //added by @solysky20200920
            {
                let titleCell = self.tableView.visibleCells[0] as! TitleTableViewCell
                titleCell.titleTextView.becomeFirstResponder()
                firstAppearance = false
            }
            
        }
    }
    
    @objc func cancel(sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let selectedRowIndexPath = self.tableView.indexPathForSelectedRow
        if ((selectedRowIndexPath) != nil) {
            self.tableView.deselectRow(at: selectedRowIndexPath!, animated: true)
            self.transitionCoordinator?.notifyWhenInteractionEnds({ context in
                if (context.isCancelled) {
                    self.tableView.selectRow(at: selectedRowIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                }
            })
        }
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let selectedRowIndexPath = self.tableView.indexPathForSelectedRow
        if ((selectedRowIndexPath) != nil) {
            
            if let coordinator = transitionCoordinator {
                let animationBlock: (UIViewControllerTransitionCoordinatorContext?) -> () = { [weak self] _ in
                    self!.tableView.deselectRow(at: selectedRowIndexPath!, animated: true)
                }
                let completionBlock: (UIViewControllerTransitionCoordinatorContext?) -> () = { [weak self] context in
                    if context!.isCancelled {
                        self!.tableView.selectRow(at: selectedRowIndexPath!, animated: true, scrollPosition: .none)
                    }
                }
                coordinator.animate(alongsideTransition: animationBlock, completion: completionBlock)
            }
            else {
                self.tableView.deselectRow(at: selectedRowIndexPath!, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tableView.endEditing(true) //incase titleCell is first responder while other aspects of the task are about to be modified.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*override var canBecomeFirstResponder: Bool {
        return true
    }
 
    //var sendButton: UIButton!
    
    override var inputAccessoryView: UIView? {
        if (customInputButton == nil) {
            customInputButton = ChangeMasterTaskButton.construct(self) as ChangeMasterTaskButton
            customInputButton.frame.size = CGSize(width: self.view.bounds.width, height: 44)
            ///customInputButton.frame.origin = CGPoint(x: self.view.frame.origin.x, y: 0)
            //customInputButton.backgroundColor = UIColor.green
            //customInputButton.titleLabel?.font =
        }
        return customInputButton
    }*/

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        return dictionary.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionary[section]!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContent = dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row] as ScheduleRowContent
        let cell = tableView.dequeueReusableCell(withIdentifier: cellContent.identifier, for: indexPath)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

        if (cell is TitleTableViewCell) {
            let titleCell = cell as! TitleTableViewCell
            titleCell.titleTextField.delegate = self
            titleCell.titleTextField.attributedPlaceholder = NSAttributedString(string: self.placeholderTitleText, attributes: [ NSForegroundColorAttributeName : UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.2) ])
            if (self.placeholderTitleText != cellContent.name) {
                titleCell.titleTextField.text = cellContent.name
            } else {
                titleCell.titleTextField.text = ""
            }
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
        
        if (cell is TypeTableViewCell) {
            let taskCell = cell as! TypeTableViewCell
            taskCell.taskLabel.text = self.task.type
            taskCell.taskImageView.image = UIImage(named: "Default" + self.task.type)
        }
        
        if (cell is CourseTableViewCell) {
            let courseCell = cell as! CourseTableViewCell
            if (self.task.course != nil) {
                courseCell.courseTitleLabel.text = self.task.course?.courseName
                courseCell.courseTitleLabel.textColor = UIColor.white
                courseCell.circleView.color = self.task.course?.color?.getUIColorObject()
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellContent = dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row] as ScheduleRowContent
        /*if (cellContent.identifier == "TitleCell") {
            return 44
        }*/
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return CGFloat.leastNormalMagnitude
        }
        return 21.0
        //return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(colorLiteralRed: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
        if (cell.contentView.backgroundColor != UIColor.clear) {
            cell.backgroundColor = cell.contentView.backgroundColor
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let dueDateCell = cell as? DueDateTableViewCell {
            dueDateCell.dueDateLabel.textColor = UIColor.white
            dueDateCell.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
        }
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let dueDateCell = cell as? DueDateTableViewCell {
            if (self.task.dueDate == nil) {
                dueDateCell.dueDateLabel.text = "Due Date"
                dueDateCell.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
                dueDateCell.iconImageView.image = #imageLiteral(resourceName: "CalendarBW")
            } else {
                dueDateCell.dueDateLabel.text = self.task.dueDate?.toReadableString()
                dueDateCell.dueDateLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                dueDateCell.iconImageView.image = #imageLiteral(resourceName: "DefaultCalendar")
            }
        }
    }*/
    
    /*var selectedCell: UITableViewCell!
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            self.performSegue(withIdentifier: segueIdentifier, sender: cell)
        }
        if let typeCell = cell as? TypeTableViewCell {
            var segueIdentifier = "showTaskType"
            if (self.mode == TaskEditingMode.Edit) {
                segueIdentifier += "Detail"
            }
            self.performSegue(withIdentifier: segueIdentifier, sender: cell)
        }
        if let courseCell = cell as? CourseTableViewCell {
            var segueIdentifier = "showCourseSelection"
            if (self.mode == TaskEditingMode.Edit) {
                segueIdentifier += "Detail"
            }
            self.performSegue(withIdentifier: segueIdentifier, sender: cell)
        }
        /* */
        
        if (cell?.reuseIdentifier == "CreateCell") {
            //save task
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(self.task)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            //Set any necessary notifications for HomeVC.
            if (self.mode == .Create && self.task.dueDate != nil && self.task.dueDate!.overScopeThreshold(task: task)) {
                self.homeVC?.setNotification(notificationType: "DueDateFarAway", task: self.task)
            }
            //dismiss VC and insert task into homeVC's tableView
            let indexPathOfTask = self.homeVC?.indexOfTask(task: self.task)
            if (indexPathOfTask != nil) {
                //UIView.animate(withDuration: 1.0, animations: { self.homeVC?.emptyHomescreenView.alpha = 0 })
                self.dismiss(animated: true, completion: {
                    UIView.animate(withDuration: 0.1, animations: { self.homeVC?.emptyHomescreenView.alpha = 0 })
                    self.homeVC?.tableView.insertRows(at: [indexPathOfTask!], with: .fade)
                })
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.selectedCell = cell
    }*/
    
    /*func generatePlaceholderTitle() -> String {
        if (self.task.course != nil) {
            let realm = try! Realm()
            let tasksOfSameTypeAndSameCourseRemovedOrNot = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@", self.task.type, self.task.course!, self.task.createdDate).sorted(byKeyPath: "createdDate", ascending: false)
            return self.task.type + " " + String(tasksOfSameTypeAndSameCourseRemovedOrNot.count)
        }
        return self.task.type
    }*/
    
    @IBAction func textFieldEdited(_ sender: Any) {
        self.helperObject.textFieldEdited(sender: sender as! UITextView)
    }
    
    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tableView.endEditing(false)
        return true
    }*/
    
    // Method for ViewControllers interacting with this one.
    
    /*func getIndexWithCellIdentifier(identifier: String) -> IndexPath? {
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
    }*/
    
    //These methods run when a master task has its date information modified.
    //This method ensures that if this task is the master task for a repeatingSchedule, the corresponding dateTokens are also updated.
    //Note: There are two versions: First is for dueDate/startTime, the second is for endDateAndTime.
    func updateDateTokenIfTaskRepeats(task: RLMTask, oldDate: NSDate?) { //task represents self.task
        let newDate = task.dueDate
        if (task.repeatingSchedule != nil) {
            let realm = try! Realm()
            let repeatingSchedulesUsingThisTaskAsMasterTask = realm.objects(RLMRepeatingSchedule.self).filter("masterTask = %@", task)
            let currentTaskRepeatingSchedule = task.repeatingSchedule //In create mode, task is always rs's master.
            if (repeatingSchedulesUsingThisTaskAsMasterTask.first != nil) { // || currentTaskRepeatingSchedule != nil
                let repeatingSchedule = repeatingSchedulesUsingThisTaskAsMasterTask.first
                //if (repeatingSchedule == nil) { repeatingSchedule = currentTaskRepeatingSchedule }
                let dateTokens = repeatingSchedule!.tokens
                for (index, dateToken) in dateTokens.enumerated() {
                    //print(dateToken.startTime.description + " ~ " + oldDate!.description)
                    if (dateToken.startTime.timeIntervalSinceReferenceDate == oldDate?.timeIntervalSinceReferenceDate) { //change this line based on what VC this is.
                        if (newDate == nil) { //if user removes dueDate, then the correct token should be removed.
                            task.repeatingSchedule?.tokens.remove(at: index)
                            if (self.helperObject.mode == .Edit) { realm.delete(dateToken) }
                            return
                        }
                        //update this dateToken.
                        dateToken.startTime = newDate as! NSDate
                        dateToken.startDayOfWeek = DayOfWeek(id: task.dueDate!.dayNumberOfWeek()!)!.rawValue
                        dateToken.lastTaskCreatedDueDate = newDate as! NSDate
                        if (task.timeSet == false) { dateToken.endTime = nil }
                        return
                    }
                }
                //if user had made the dueDate nil before therefore deleting the only matching dateToken, then simply recreate it.
                if (newDate != nil) {
                    let dateToken = RLMDateToken(startTime: newDate as! NSDate, startDayOfWeek: DayOfWeek(id: newDate!.dayNumberOfWeek()!)!.rawValue, endTime: nil)
                    dateToken.lastTaskCreatedDueDate = newDate as! NSDate
                    repeatingSchedule!.tokens.append(dateToken)
                    if (self.helperObject.mode == .Edit) { realm.add(dateToken) }
                }
            }
        }
    }
    
    //Second version for endDateAndTime. (Used in EndTimeViewController)
    //Variable 'oldDate' in this case is endDateAndTime.
    func updateDateTokenEndTimeIfTaskRepeats(task: RLMTask, oldEndDate: NSDate?) { //task represents self.task
        let newEndDate = task.endDateAndTime
        if (task.repeatingSchedule != nil) {
            let realm = try! Realm()
            let repeatingSchedulesUsingThisTaskAsMasterTask = realm.objects(RLMRepeatingSchedule.self).filter("masterTask = %@", task)
            let currentTaskRepeatingSchedule = task.repeatingSchedule //In create mode, task is always rs's master.
            if (repeatingSchedulesUsingThisTaskAsMasterTask.first != nil) { // || currentTaskRepeatingSchedule != nil
                var repeatingSchedule = repeatingSchedulesUsingThisTaskAsMasterTask.first
                //if (repeatingSchedule == nil) { repeatingSchedule = currentTaskRepeatingSchedule }
                let dateTokens = repeatingSchedule!.tokens
                for (index, dateToken) in dateTokens.enumerated() {
                    if (dateToken.endTime?.timeIntervalSinceReferenceDate == oldEndDate?.timeIntervalSinceReferenceDate) { //change this line based on what VC this is.
                        //update this dateToken.
                        dateToken.endTime = newEndDate
                        return
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is DueDateViewController) {
            let dueDateVC = segue.destination as! DueDateViewController
            dueDateVC.task = self.helperObject.task
            dueDateVC.homeVC = self.helperObject.homeVC
            dueDateVC.taskManager = self.helperObject.taskManagerVC
            dueDateVC.cellEditingVC = self
        }
        if (segue.destination is StartTimeViewController) {
            let startTimeVC = segue.destination as! StartTimeViewController
            startTimeVC.task = self.helperObject.task
            startTimeVC.homeVC = self.helperObject.homeVC
            startTimeVC.taskManager = self.helperObject.taskManagerVC
            startTimeVC.cellEditingVC = self
        }
        if (segue.destination is EndTimeViewController) {
            let endTimeVC = segue.destination as! EndTimeViewController
            endTimeVC.task = self.helperObject.task
            endTimeVC.homeVC = self.helperObject.homeVC
            endTimeVC.taskManager = self.helperObject.taskManagerVC
            endTimeVC.cellEditingVC = self
        }
        if (segue.destination is TaskTypeTableViewController) {
            let taskVC = segue.destination as! TaskTypeTableViewController
            taskVC.task = self.helperObject.task
            taskVC.homeVC = self.helperObject.homeVC
            taskVC.taskManager = self.helperObject.taskManagerVC
            taskVC.cellEditingVC = self
        }
        if (segue.destination is CourseSelectionTableViewController) {
            let courseSelectionVC = segue.destination as! CourseSelectionTableViewController
            courseSelectionVC.task = self.helperObject.task
            courseSelectionVC.homeVC = self.helperObject.homeVC
            courseSelectionVC.taskManager = self.helperObject.taskManagerVC
            courseSelectionVC.cellEditingVC = self
        }
        if (segue.destination is RepeatsTypeTableViewController) {
            let courseSelectionVC = segue.destination as! RepeatsTypeTableViewController
            courseSelectionVC.task = self.helperObject.task
            courseSelectionVC.homeVC = self.helperObject.homeVC
            courseSelectionVC.taskManager = self.helperObject.taskManagerVC
            courseSelectionVC.cellEditingVC = self
        }
        if (segue.destination is BasicNoteViewController) {
            let basicNoteVC = segue.destination as! BasicNoteViewController
            let realm = try! Realm()
            realm.beginWrite()
            basicNoteVC.task = self.helperObject.task
            basicNoteVC.homeVC = self.helperObject.homeVC
            basicNoteVC.taskManager = self.helperObject.taskManagerVC
            basicNoteVC.cellEditingVC = self
            basicNoteVC.delegate = self
            
            if let cell = sender as? NoteTableViewCell{
                basicNoteVC.cell = cell
                if let index = self.tableView.indexPath(for: cell){
                    if index.row < self.helperObject.task.note2.count{
                        basicNoteVC.selectedNote = self.helperObject.task.note2[index.row]
                        basicNoteVC.task.note = self.helperObject.task.note2[index.row]
                    }else{
                        basicNoteVC.task.note = nil
                    }
                }
            }
            
            do {
                    try realm.commitWrite()
            } catch {
                // error while saving notes
            }
        }
    }
    

}

extension CellEditingTableViewController {

    func didChange(_ height: CGFloat, cell: TitleTableViewCell) {

        if cell.titleTextView.text != "" {
            cell.clearButton.isHidden = false
        } else {
            cell.clearButton.isHidden = true
        }

        // Disabling animations gives us our desired behaviour
        UIView.setAnimationsEnabled(false)
        /* These will causes table cell heights to be recaluclated,
         without reloading the entire cell */
        tableView.beginUpdates()
        tableView.endUpdates()
        // Re-enable animations
        UIView.setAnimationsEnabled(true)

        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.tableView.scrollRectToVisible(cell.frame, animated: true)
        }
    }
}

extension CellEditingTableViewController: SubTaskCellDelegate {

    func didTapSubscribeButton() {
        let alert = UIAlertController(title: nil, message: "Subscribe to unlock subtasks!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in

        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    func deleteSubTask(indexPath: IndexPath) {

        if indexPath.row != helperObject.task.subTasks.count {
            let subTask = helperObject.task.subTasks[indexPath.row]

            RLMTask.deleteSubTask(task: helperObject.task, subTask: subTask, completion: { (success) in
                print("Deleted")
                self.helperObject.dictionary[indexPath.section]?.remove(at: indexPath.row)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            })
        }

    }

    func deleteNote(indexPath: IndexPath) {
        
        if indexPath.row != helperObject.task.note2.count {
            let note = helperObject.task.note2[indexPath.row]
            
            RLMTask.deleteNote(task: helperObject.task, note: note, completion: { (success) in
                print("Deleted")
                self.helperObject.dictionary[indexPath.section]?.remove(at: indexPath.row)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            })
        }
        
    }
    
    func deleteEmptySubTask(cell: SubTaskTableViewCell) {
        let point = self.tableView.convert(CGPoint.zero, from: cell.checkMarkButton)
        if let indexPath = self.tableView.indexPathForRow(at: point) {
            deleteSubTask(indexPath: indexPath)
        }
    }
    
    func deleteNoteCell(cell: NoteTableViewCell) {
        if let indexpath = self.tableView.indexPath(for: cell){
            deleteNote(indexPath: indexpath)
        }
    }
    

    func didTapCompleteSubTask(sender: UIButton, cell: SubTaskTableViewCell) {
        let point = self.tableView.convert(CGPoint.zero, from: sender)
        if let indexPath = self.tableView.indexPathForRow(at: point) {
            let subCount = helperObject.task.subTasks
            if subCount.count > 0{
                
                let subTask = helperObject.task.subTasks[indexPath.row]
                
                if subTask.completed == true {
                    RLMSubTask.markCompleted(subTask: subTask, completed: false) { (success) in
                        sender.setImage(#imageLiteral(resourceName: "white circle"), for: .normal)
                        cell.subTaskTextView.textColor = UIColor.white
                        cell.checkMarkButton.tintColor = UIColor(hex: "FFFFFF").withAlphaComponent(0.4)
                    }
                } else {
                    RLMSubTask.markCompleted(subTask: subTask, completed: true) { (success) in
                        
                        if let color = self.helperObject.task.course?.color?.getUIColorObject() {
                            cell.checkMarkButton.tintColor = color
                        }
                        
                        sender.setImage(#imageLiteral(resourceName: "selected_icon"), for: .normal)
                        cell.subTaskTextView.textColor = UIColor(hex: "FFFFFF").withAlphaComponent(0.4)
                    }
                }
            }
        }
    }

    func didChangeHeight(_ height: CGFloat, cell: SubTaskTableViewCell) {

        // Disabling animations gives us our desired behaviour
        UIView.setAnimationsEnabled(false)
        /* These will causes table cell heights to be recaluclated,
         without reloading the entire cell */
        tableView.beginUpdates()
        tableView.endUpdates()
        // Re-enable animations
        UIView.setAnimationsEnabled(true)

        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.tableView.scrollRectToVisible(cell.frame, animated: true)
        }

    }
    
    func didTapNoteEditor(taskTitle: String,id: String,contentSet:String, cell: NoteTableViewCell) {

        if let indexPath = self.tableView.indexPath(for: cell){
            let realm = try! Realm()
            realm.beginWrite()
            
            let task: RLMNote?
            var newTask = false
            
            if indexPath.row != helperObject.task.note2.count {
                task = helperObject.task.note2[indexPath.row]
                
                if let index = helperObject.task.note2.index(of: task!) {
                    helperObject.task.note2[index].title = taskTitle
                    helperObject.task.note2[index].contentSet = contentSet
                }
            } else {
                newTask = true
                task = RLMNote(name: taskTitle, id: id, contentSet: contentSet)
                helperObject.task.note2.append(task!)
            }
            
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            
            if newTask {
            self.helperObject.dictionary[indexPath.section]?.insert(ScheduleRowContent(identifier: "NoteCell"), at: indexPath.row)
                
              //  tableView.deselectRow(at: indexPath, animated: true)
               
                UIView.setAnimationsEnabled(false)
                tableView.beginUpdates()

                self.tableView.insertRows(at: [indexPath], with: .automatic)

                tableView.endUpdates()
                // Re-enable animations
                UIView.setAnimationsEnabled(true)

                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.tableView.scrollRectToVisible(cell.frame, animated: true)
                }

            }
            self.perform(#selector(reloadTable), with: nil, afterDelay: 0.6)
        }
        
    }
    
    @objc func reloadTable() {
        self.tableView.reloadData()
    }

    func didTapDone(subTask: String, cell: SubTaskTableViewCell) {
        
        let point = self.tableView.convert(CGPoint.zero, from: cell.checkMarkButton)
        if let indexPath = self.tableView.indexPathForRow(at: point) {
            let realm = try! Realm()
            realm.beginWrite()
            
            let task: RLMSubTask?
            var newTask = false
            
            if indexPath.row != helperObject.task.subTasks.count {
                task = helperObject.task.subTasks[indexPath.row]
                cell.subTaskTextView.resignFirstResponder()
                if let index = helperObject.task.subTasks.index(of: task!) {
                    helperObject.task.subTasks[index].name = subTask
                }
            } else {
                newTask = true
                cell.subTaskTextView.text = ""
                task = RLMSubTask(name: subTask, task: helperObject.task, completed: false)
                //                    task = RLMSubTask(name: subTask, task: helperObject.task.id, completed: false)
                helperObject.task.subTasks.append(task!)
            }
            
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            
            if newTask {
                self.helperObject.dictionary[indexPath.section]?.insert(ScheduleRowContent(identifier: "SubTaskCell"), at: indexPath.row)
                
                UIView.setAnimationsEnabled(false)
                tableView.beginUpdates()
                
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                
                tableView.endUpdates()
                // Re-enable animations
                UIView.setAnimationsEnabled(true)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.tableView.scrollRectToVisible(cell.frame, animated: true)
                }
                
            }
            
        }
        //        }
        
        
        
        //        guard let indexPath = cell.indexPath else {return}
        
        
    }
}
