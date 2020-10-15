//
//  ScheduleEditorViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-25.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift
import FTPopOverMenu_Swift

class ScheduleEditorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, HomeworkTableViewCellDelegate {

    //ToDo: Eventually bring this over to a UITableViewController so that keyboard behaviour is handled.

    @IBOutlet var tableView: B4GradTableView!
    var course: RLMCourse!
    var coursesVC: CoursesViewController!
    var homeVC: HomeworkViewController!
    //[Section : Rows]
    var dictionary :[Int:Array<ScheduleRowContent>] = [0 : [ScheduleRowContent(identifier: "ConfirmationCell")], 1 : [ScheduleRowContent(identifier: "CourseNameCell"), ScheduleRowContent(identifier: "CourseCodeCell"), ScheduleRowContent(identifier: "LectureCell")], 2 :
        [ScheduleRowContent(identifier: "NewAssignmentCell")], 3 : [ScheduleRowContent(identifier: "NewQuizCell")], 4 : [ScheduleRowContent(identifier: "NewMidtermCell")], 5 : [ScheduleRowContent(identifier: "NewFinalCell")], 6 : [ScheduleRowContent(identifier: "LabCell"), ScheduleRowContent(identifier: "TutorialCell")] ] //5 : [ScheduleRowContent(identifier: "FinalToggleCell", defaultToggle: false)] //7 : [ScheduleRowContent(identifier: "UseScheduleCell")]
    //The following 2 variables exist only to ensure that HWcells look selected after being reloaded (since reloading a tableView cell deselects it).
    var lastSelectedRowIndexPath : IndexPath?
    var useLastSelectedRowIndexPath = false
    //Semester-related variables.
    var semesterNotSelectedYet = true
    var defaultSemester : String!
    var minimumDate : Date!
    var maximumDate : Date!
    var semesterDates = [String:Array<Date>]()
    //PickerView-related & DatePickerView-related variables
    var pickerActivated = false

    override func viewDidLoad() {
        super.viewDidLoad()
        TaskManagerTracker.addTaskManager(tableView: self.tableView)
        //self.title = "Anonymous's Schedule"
        setupUI()

        self.defaultSemester = self.determineDefaultSemester()
        //change this to be modified based on the University's/Course's semester schedule.
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.keyboardDismissMode = .onDrag

        //Keep in mind: Unlike HWViewController, ScheduleEditorVC puts the results from the realm queries and inserts them into a dictionary.

        //Add all tasks to tableView's datasource (self.dictionary):

        //First, Assignments are added for the Assignments section.
        let realm = try! Realm()
        let coursePredicate = NSPredicate(format: "course = %@", self.course as CVarArg)
        let assignmentsWithoutNullDueDates = realm.objects(RLMTask.self).filter("removed = false AND dueDate != null AND type = 'Assignment'").filter(coursePredicate).sorted(byKeyPath: "dueDate", ascending: true)
        let assignmentsWithNullDueDates = realm.objects(RLMTask.self).filter("removed = false AND dueDate = null AND type = 'Assignment'").filter(coursePredicate).sorted(byKeyPath: "dueDate", ascending: true)
        let assignments = assignmentsWithoutNullDueDates.toArray() + assignmentsWithNullDueDates.toArray()
        let assignmentScheduleRowContentArray = self.convertRLMTaskCollectionToScheduleRowContentArray(tasks: assignments)
        self.dictionary[2]?.insert(contentsOf: assignmentScheduleRowContentArray, at: 0)
        //Second, Quizzes are added for the Quizzes section.
        let quizzesWithoutNullDueDates = realm.objects(RLMTask.self).filter("removed = false AND dueDate != null AND type = 'Quiz'").filter(coursePredicate).sorted(byKeyPath: "dueDate", ascending: true)
        let quizzesWithNullDueDates = realm.objects(RLMTask.self).filter("removed = false AND dueDate = null AND type = 'Quiz'").filter(coursePredicate).sorted(byKeyPath: "dueDate", ascending: true)
        let quizzes = quizzesWithoutNullDueDates.toArray() + quizzesWithNullDueDates.toArray()
        let quizScheduleRowContentArray = self.convertRLMTaskCollectionToScheduleRowContentArray(tasks: quizzes)
        self.dictionary[3]?.insert(contentsOf: quizScheduleRowContentArray, at: 0)
        //Third, Midterms are added for the Midterms section.
        let midtermsWithoutNullDueDates = realm.objects(RLMTask.self).filter("removed = false AND dueDate != null AND type = 'Midterm'").filter(coursePredicate).sorted(byKeyPath: "dueDate", ascending: true)
        let midtermsWithNullDueDates = realm.objects(RLMTask.self).filter("removed = false AND dueDate = null AND type = 'Midterm'").filter(coursePredicate).sorted(byKeyPath: "dueDate", ascending: true)
        let midterms = midtermsWithoutNullDueDates.toArray() + midtermsWithNullDueDates.toArray()
        let midtermScheduleRowContentArray = self.convertRLMTaskCollectionToScheduleRowContentArray(tasks: midterms)
        self.dictionary[4]?.insert(contentsOf: midtermScheduleRowContentArray, at: 0)
        let finalsWithoutNullDueDates = realm.objects(RLMTask.self).filter("removed = false AND dueDate != null AND type = 'Final'").filter(coursePredicate).sorted(byKeyPath: "dueDate", ascending: true)
        let finalsWithNullDueDates = realm.objects(RLMTask.self).filter("removed = false AND dueDate = null AND type = 'Final'").filter(coursePredicate).sorted(byKeyPath: "dueDate", ascending: true)
        let finals = finalsWithoutNullDueDates.toArray() + finalsWithNullDueDates.toArray()
        let finalScheduleRowContentArray = self.convertRLMTaskCollectionToScheduleRowContentArray(tasks: finals)
        self.dictionary[5]?.insert(contentsOf: finalScheduleRowContentArray, at: 0)
    }

    func convertRLMTaskCollectionToScheduleRowContentArray(tasks: [RLMTask]) -> [ScheduleRowContent] {
        var scheduleRowContentArray = [ScheduleRowContent]()
        for task in tasks {
            let taskScheduleRowContent = ScheduleRowContent(identifier: "HomeworkTableViewCell", task: task)
            scheduleRowContentArray.append(taskScheduleRowContent)
        }
        return scheduleRowContentArray
    }

    private func setupUI() {
        let moreItem = UIBarButtonItem(image: UIImage(named: "more_horiz"), style: .done, target: self, action: #selector(onMoreItem(sender:event:)))
        self.navigationItem.rightBarButtonItem = moreItem

        let configuration = FTConfiguration.shared
        configuration.backgoundTintColor = UIColor.white
        configuration.cornerRadius = 15.0
        configuration.cellSelectionStyle = .default
    }

    func setTitle() {
        var currentTitle = ""
        if (self.course.courseCode != nil) {
            //self.title = self.course.courseCode! + "'s Schedule"
            currentTitle = self.course.courseCode!
        } else {
            //self.title = self.course.courseName + "'s Schedule"
            currentTitle = self.course.courseName
        }

        let titleView = UIView()
        titleView.backgroundColor = .clear

        let iconImage = UIImageView()
        iconImage.image = UIImage(named: self.course.facultyName!)?.scaleImage(toSize: CGSize(width: 25.0, height: 25.0))
        iconImage.contentMode = .scaleAspectFit
        titleView.addSubview(iconImage)

        let navLabel = UILabel()
        navLabel.textAlignment = .center
        navLabel.font = UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.medium)
        navLabel.textColor = .white
        navLabel.text = currentTitle
        titleView.addSubview(navLabel)

        iconImage.translatesAutoresizingMaskIntoConstraints = false
        navLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImage.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        iconImage.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        iconImage.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 0.0).isActive = true
        iconImage.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 0.0).isActive = true
        iconImage.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 0.0).isActive = true
        iconImage.trailingAnchor.constraint(equalTo: navLabel.leadingAnchor, constant: -5.0).isActive = true
        navLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 0.0).isActive = true
        navLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 0.0).isActive = true
        navLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 0.0).isActive = true

        self.navigationItem.titleView = titleView
    }

    override func viewWillAppear(_ animated: Bool) { //Remember: Set TableView's subclass to B4GradTableView !
        super.viewWillAppear(true)
        self.registerKeyboardNotifications()
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
        self.setTitle()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.unregisterKeyboardNotifications()
    }

    @objc func onMoreItem(sender: UIBarButtonItem, event: UIEvent) {

        let cellConfi = FTCellConfiguration()
        cellConfi.textColor = UIColor.black
        cellConfi.textFont = UIFont.boldSystemFont(ofSize: 16)

        let cellConfis = Array(repeating: cellConfi, count: 2)

        let courseColorImage = self.course.color!.getUIColorObject().image(size: CGSize(width: 40, height: 40))!.maskRoundedImage(radius: 20)

        FTPopOverMenu.showForEvent(event: event, with: ["Color", "Symbol"], menuImageArray: [courseColorImage, self.course.facultyName!], cellConfigurationArray: cellConfis, done: { (selectedIndex) in
            if selectedIndex == 0 {
                //if (UserDefaults.standard.bool(forKey: "isSubscribed") == true) {
                    let nextVc = self.storyboard?.instantiateViewController(withIdentifier: "ColorPickerTableViewController") as! ColorPickerTableViewController
                    nextVc.colorStaticValue = self.course.colorStaticValue
                    nextVc.editScheduleVc = self
                    self.navigationController?.pushViewController(nextVc, animated: true)
                /*} else {
                    let storyboard = UIStoryboard(name: "Subscription", bundle: nil)
                    let subscriptionPlansVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlansViewController")
                    self.present(subscriptionPlansVC, animated: true, completion: nil)
                }*/
            } else if selectedIndex == 1 {
                let nextVc = self.storyboard?.instantiateViewController(withIdentifier: "FacultyCollectionViewController") as! FacultyCollectionViewController
                nextVc.facultyName = self.course.facultyName
                nextVc.editScheduleVc = self
                self.navigationController?.pushViewController(nextVc, animated: true)
            }
        }) {

        }
    }

    //**Solves the odd tableView scrollView offset bug that occurs when tableView.beginUpdates(..) and tableView.endUpdates(..) get called.**
    //http://stackoverflow.com/a/33397350/6051635

    var heightAtIndexPath = NSMutableDictionary()
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.heightAtIndexPath.object(forKey: indexPath)
        if ((height) != nil) {
            return CGFloat((height! as AnyObject).floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = cell.frame.size.height
        self.heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)

        if (UIDevice.current.userInterfaceIdiom == .pad) {
            cell.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
            if (cell.contentView.backgroundColor != UIColor.clear) {
                cell.backgroundColor = cell.contentView.backgroundColor
            }
        }
        cell.contentView.backgroundColor = nil //since iOS13
    }

    //**End of Bug Solution.**

    //TableView Datasource/Delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return dictionary.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionary[section]!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContent = dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row] as ScheduleRowContent
        let cell = tableView.dequeueReusableCell(withIdentifier: cellContent.identifier, for: indexPath)

        if (cellContent.identifier == "CourseNameCell") {
            let nameCell = cell as! CourseNameEditingTableViewCell
            nameCell.textField.text = cellContent.name
            nameCell.textField.delegate = self
            return nameCell
        }

        if (cellContent.identifier == "CourseCodeCell") {
            let codeCell = cell as! CourseCodeEditingTableViewCell
            codeCell.textField.text = cellContent.name

            codeCell.textField.delegate = self
            return codeCell
        }
        if (cellContent.identifier == "SemesterCell") {
            let semesterCell = cell as! SemesterTableViewCell
            if (cellContent.pickerTitleForRow == nil) {
                cellContent.pickerTitleForRow = self.defaultSemester
            }
            semesterCell.rhsLabel.text = cellContent.pickerTitleForRow
            return semesterCell
        }

        if (cellContent.identifier == "SectionCell") {
            let semesterCell = cell as! SectionTableViewCell
            if (cellContent.pickerTitleForRow == nil) {
                cellContent.pickerTitleForRow = PickerDataSource(source: .upTo20Sections).dataArray.first
            }
            semesterCell.rhsLabel.text = cellContent.pickerTitleForRow
            return semesterCell
        }

        if (cellContent.identifier == "ProfessorCell") {
            let profCell = cell as! ProfessorTableViewCell
            profCell.textField.text = cellContent.name
            profCell.textField.delegate = self
            return profCell
        }

        if (cellContent.identifier == "HomeworkTableViewCell") {
            let cell = cell as! HomeworkTableViewCell
            let task = cellContent.task!
            cell.task = task
            cell.delegate = self
            /*for view in self.tableView.subviews {
                if view is UIScrollView {
                    print(view.description)
                }
            }*/

            CellCustomizer.cellForRowCustomization(task: task, cell: cell, taskManager: self)

            if self.tableView.indexPathForSelectedRow != nil {
                if (self.tableView.indexPathForSelectedRow! == indexPath) {
                    cell.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
                } else {
                    cell.cardView.backgroundColor = UIColor.white
                }
            }

            if (self.lastSelectedRowIndexPath != nil && self.useLastSelectedRowIndexPath == true) {
                if (self.lastSelectedRowIndexPath!.row == indexPath.row && ((self.lastSelectedRowIndexPath?.section) != nil)) {
                    cell.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
                    self.useLastSelectedRowIndexPath = false
                }
            }

            return cell
        }

        if (cellContent.identifier == "FinalReminderCell") { //depcrecated
            let finalReminderCell = cell as! FinalReminderTableViewCell
            finalReminderCell.textField.delegate = self
            if (cellContent.date == nil) {
                finalReminderCell.rhsLabel.text = "Set Date"
                return finalReminderCell
            }
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            finalReminderCell.rhsLabel.text = formatter.string(from: cellContent.date! as Date)
            return finalReminderCell
        }

        if (cellContent.identifier == "AssignmentCell") { //depcrecated
            let assignmentCell = cell as! AssignmentTableViewCell
            var counter = 0
            for row in self.dictionary[2]! {
                if (row.identifier == "AssignmentCell") {
                    counter += 1
                    if (row == cellContent) {
                        break
                    }
                }
            }
            assignmentCell.textField.attributedPlaceholder = NSAttributedString(string: "Assignment " + String(counter), attributes: [ NSAttributedStringKey.foregroundColor : UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.3) ])
            assignmentCell.textField.text = cellContent.name
            assignmentCell.textField.delegate = self
            if (cellContent.date == nil) {
                assignmentCell.rhsLabel.text = "Due Date"
                return assignmentCell
            }
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            assignmentCell.rhsLabel.text = formatter.string(from: cellContent.date! as Date)
            return assignmentCell
        }

        if (cellContent.identifier == "QuizCell") {
            let quizCell = cell as! QuizTableViewCell
            var counter = 0
            for row in self.dictionary[3]! {
                if (row.identifier == "QuizCell") {
                    counter += 1
                    if (row == cellContent) {
                        break
                    }
                }
            }
            quizCell.textField.attributedPlaceholder = NSAttributedString(string: "Quiz " + String(counter), attributes: [ NSAttributedStringKey.foregroundColor : UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.3) ])
            quizCell.textField.text = cellContent.name
            quizCell.textField.delegate = self
            if (cellContent.date == nil) {
                quizCell.rhsLabel.text = "Due Date"
                return quizCell
            }
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            quizCell.rhsLabel.text = formatter.string(from: cellContent.date! as Date)
            return quizCell
        }

        if (cellContent.identifier == "MidtermCell") {
            let midtermCell = cell as! MidtermTableViewCell
            var counter = 0
            for row in self.dictionary[4]! {
                if (row.identifier == "MidtermCell") {
                    counter += 1
                    if (row == cellContent) {
                        break
                    }
                }
            }
            midtermCell.textField.attributedPlaceholder = NSAttributedString(string: "Midterm " + String(counter), attributes: [ NSAttributedStringKey.foregroundColor : UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.3) ])
            midtermCell.textField.text = cellContent.name
            midtermCell.textField.delegate = self
            if (cellContent.date == nil) {
                midtermCell.rhsLabel.text = "Due Date"
                return midtermCell
            }
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.medium
            midtermCell.rhsLabel.text = formatter.string(from: cellContent.date! as Date)
            return midtermCell
        }

        if (cellContent.identifier == "FinalToggleCell") {
            let finalToggleCell = cell
            if (cellContent.toggle == true) {
                finalToggleCell.accessoryType = .checkmark
            } else {
                finalToggleCell.accessoryType = .none
            }
            return finalToggleCell
        }

        if (cellContent.identifier == "FinalCell") {
            let finalCell = cell as! FinalTableViewCell
            return finalCell
        }

        if (cellContent.identifier == "PickerTableViewCell") {
            let pickerCell = cell as! PickerTableViewCell
            pickerCell.pickerView.indexPath = indexPath
            pickerCell.pickerView.dataSource = cellContent.pickerDataSource
            pickerCell.pickerView.delegate = self
            //Refactor this code.
            //Select correct default row.
            for (index, element) in (cellContent.pickerDataSource?.dataArray)!.enumerated() {
                if (element == cellContent.pickerTitleForRow) {
                    pickerCell.pickerView.selectRow(index, inComponent: 0, animated: false)
                }
            }
            if (cellContent.pickerTitleForRow == nil) {
                pickerCell.pickerView.selectRow(0, inComponent: 0, animated: false)
            }
            //Ensure semester is correct from the outset.
            if (indexPath == IndexPath(row: 2, section: 1) && self.semesterNotSelectedYet == true) {
                for (index, data) in cellContent.pickerDataSource!.dataArray.enumerated() {
                    if (self.defaultSemester == data) {
                        pickerCell.pickerView.selectRow(index, inComponent: 0, animated: false)
                    }
                }
                self.semesterNotSelectedYet = false
            }
            return pickerCell
        }

        if (cellContent.identifier == "DatePickerTableViewCell") {
            let datePickerCell = cell as! DatePickerTableViewCell
            datePickerCell.datePicker.indexPath = indexPath
            datePickerCell.datePicker.minimumDate = Date.distantPast
            datePickerCell.datePicker.maximumDate = Date.distantFuture
            if (cellContent.date == nil) {
                datePickerCell.datePicker.setDate(Date(), animated: false)
            } else {
                datePickerCell.datePicker.setDate(cellContent.date! as Date, animated: false)
            }
            return datePickerCell
        }

        return cell

    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0) //This color is also set in a method above and in B4GradTableView.
        return true
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor.white
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor.white
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor.white
        return indexPath
    }

    //The sections sometimes visually glitching are because of the 'headers shouldn't be cells' bug. (FIXED!)
    //http://stackoverflow.com/questions/12772197/what-is-the-meaning-of-the-no-index-path-for-table-cell-being-reused-message-i
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        if (cell is HomeworkTableViewCell) {
            let hwCell = cell as! HomeworkTableViewCell
            hwCell.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
            self.lastSelectedRowIndexPath = indexPath
        }

        if (cell?.reuseIdentifier == "HomeworkTableViewCell") {
            let scheduleRowContent = self.dictionary[indexPath.section]![indexPath.row]
            let task = scheduleRowContent.task!

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cellEditingVC = storyboard.instantiateViewController(withIdentifier: "CellEditingVC") as! CellEditingTableViewController
            cellEditingVC.helperObject = SchedulesCellEditingHelperObject(cellEditingTVC: cellEditingVC, task: task, taskManagerVC: self, homeVC: self.homeVC)
            cellEditingVC.helperObject.mode = .Edit
            cellEditingVC.helperObject.dictionary[0]![0].name = task.name
            cellEditingVC.title = task.name
            cellEditingVC.helperObject.task = task
            cellEditingVC.helperObject.taskManagerVC = self
            self.show(cellEditingVC, sender: nil)
            
            if (((UserDefaults.standard.object(forKey: "DateSinceFirstLaunched") as! Date).daysTo(Date())!) >= 3 && UserDefaults.standard.bool(forKey: "isSubscribed") == false) {
                //display subscription screen with no 'X' and state 'free trial is over'.
                let storyboard = UIStoryboard(name: "Subscription", bundle: nil)
                let subscriptionPlansVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlansViewController") as! SubscriptionPlansViewController
                subscriptionPlansVC.customHeadlineText = "Your Free Trial has Expired. Purchase to Continue."
                subscriptionPlansVC.view.viewWithTag(101)?.isHidden = true
                if #available(iOS 13.0, *) {
                    subscriptionPlansVC.isModalInPresentation = true
                }
                self.present(subscriptionPlansVC, animated: true, completion: nil)
            }
            
            return
        }

        if (cell?.reuseIdentifier == "NewAssignmentCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
            let cellEditingVC = storyboard.instantiateViewController(withIdentifier: "CellEditingVC") as! CellEditingTableViewController
            let newTask = RLMTask(name: "", type: "Assignment", dueDate: nil, course: self.course) //create task (but don't save it yet)
            cellEditingVC.helperObject = SchedulesCellEditingHelperObject(cellEditingTVC: cellEditingVC, task: newTask, taskManagerVC: self, homeVC: self.homeVC)
            cellEditingVC.helperObject.mode = TaskEditingMode.Create
            cellEditingVC.helperObject.task = newTask
            navigationController.viewControllers = [cellEditingVC]
            navigationController.modalPresentationStyle = .formSheet
            self.present(navigationController, animated: true, completion: nil)
            return
        }

        if (cell?.reuseIdentifier == "NewQuizCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
            let cellEditingVC = storyboard.instantiateViewController(withIdentifier: "CellEditingVC") as! CellEditingTableViewController
            let newTask = RLMTask(name: "", type: "Quiz", dueDate: nil, course: self.course) //create task (but don't save it yet)
            cellEditingVC.helperObject = SchedulesCellEditingHelperObject(cellEditingTVC: cellEditingVC, task: newTask, taskManagerVC: self, homeVC: self.homeVC)
            cellEditingVC.helperObject.mode = TaskEditingMode.Create
            cellEditingVC.helperObject.task = newTask
            navigationController.viewControllers = [cellEditingVC]
            navigationController.modalPresentationStyle = .formSheet
            self.present(navigationController, animated: true, completion: nil)
            return
        }

        if (cell?.reuseIdentifier == "NewMidtermCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
            let cellEditingVC = storyboard.instantiateViewController(withIdentifier: "CellEditingVC") as! CellEditingTableViewController
            let newTask = RLMTask(name: "", type: "Midterm", dueDate: nil, course: self.course) //create task (but don't save it yet)
            cellEditingVC.helperObject = SchedulesCellEditingHelperObject(cellEditingTVC: cellEditingVC, task: newTask, taskManagerVC: self, homeVC: self.homeVC)
            cellEditingVC.helperObject.mode = TaskEditingMode.Create
            cellEditingVC.helperObject.task = newTask
            navigationController.viewControllers = [cellEditingVC]
            navigationController.modalPresentationStyle = .formSheet
            self.present(navigationController, animated: true, completion: nil)
            return
        }

        if (cell?.reuseIdentifier == "NewFinalCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
            let cellEditingVC = storyboard.instantiateViewController(withIdentifier: "CellEditingVC") as! CellEditingTableViewController
            let newTask = RLMTask(name: "", type: "Final", dueDate: nil, course: self.course) //create task (but don't save it yet)
            cellEditingVC.helperObject = SchedulesCellEditingHelperObject(cellEditingTVC: cellEditingVC, task: newTask, taskManagerVC: self, homeVC: self.homeVC)
            cellEditingVC.helperObject.mode = TaskEditingMode.Create
            cellEditingVC.helperObject.task = newTask
            navigationController.viewControllers = [cellEditingVC]
            navigationController.modalPresentationStyle = .formSheet
            self.present(navigationController, animated: true, completion: nil)
            return
        }

        //--

        if (cell?.reuseIdentifier == "SemesterCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            self.activeField?.resignFirstResponder()
            if (self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row + 1].identifier != "PickerTableViewCell") {
                tableView.beginUpdates()
                //Remove any existing pickerViewCells.
                for (index, rowContent) in (self.dictionary[(indexPath as NSIndexPath).section]?.enumerated())! {
                    if (rowContent.identifier == "PickerTableViewCell" || rowContent.identifier == "DatePickerTableViewCell") {
                        self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: (indexPath as NSIndexPath).section)], with: .top)
                    }
                }
                //Add New pickerViewCell.
                let cellContent = ScheduleRowContent(identifier: "PickerTableViewCell")
                //Determine semester type based on University/Course information.
                cellContent.pickerDataSource = PickerDataSource(source: .standardSemester)
                cellContent.pickerTitleForRow = self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row].pickerTitleForRow
                self.dictionary[(indexPath as NSIndexPath).section]?.insert(cellContent, at: (self.dictionary[(indexPath as NSIndexPath).section]!.count - 1))
                tableView.insertRows(at: [IndexPath(row: 2, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: self.dictionary[(indexPath as NSIndexPath).section]!.count - 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            }
            return
        }

        if (cell?.reuseIdentifier == "SectionCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            self.activeField?.resignFirstResponder()
            if (self.dictionary[(indexPath as NSIndexPath).section]?.last?.identifier != "PickerTableViewCell") {
                tableView.beginUpdates()
                //Remove any existing pickerViewCells.
                for (index, rowContent) in (self.dictionary[(indexPath as NSIndexPath).section]?.enumerated())! {
                    if (rowContent.identifier == "PickerTableViewCell" || rowContent.identifier == "DatePickerTableViewCell") {
                        self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: (indexPath as NSIndexPath).section)], with: .top)
                    }
                }
                //Add New pickerViewCell.
                let cellContent = ScheduleRowContent(identifier: "PickerTableViewCell")
                cellContent.pickerDataSource = PickerDataSource(source: .upTo20Sections)
                cellContent.pickerTitleForRow = self.dictionary[(indexPath as NSIndexPath).section]?[self.dictionary[(indexPath as NSIndexPath).section]!.count - 1].pickerTitleForRow
                self.dictionary[(indexPath as NSIndexPath).section]?.insert(cellContent, at: (self.dictionary[(indexPath as NSIndexPath).section]!.count))
                tableView.insertRows(at: [IndexPath(row: 3, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: self.dictionary[(indexPath as NSIndexPath).section]!.count - 1)
                tableView.deleteRows(at: [IndexPath(row: 3, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            }
            return
        }

        if (cell?.reuseIdentifier == "AssignmentCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            self.activeField?.resignFirstResponder()
            if (self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row + 1].identifier != "DatePickerTableViewCell") {
                tableView.beginUpdates()
                //Remove any existing pickerViewCells or datePickerViewCells.
                var increment = 1
                for (index, rowContent) in (self.dictionary[(indexPath as NSIndexPath).section]?.enumerated())! {
                    if (rowContent.identifier == "PickerTableViewCell" || rowContent.identifier == "DatePickerTableViewCell") {
                        self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: (indexPath as NSIndexPath).section)], with: .top)
                        if (index < (indexPath as NSIndexPath).row) {
                            increment -= 1
                        }
                    }
                }
                //Add New pickerViewCell.
                let cellContent = ScheduleRowContent(identifier: "DatePickerTableViewCell")
                cellContent.date = self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row + (increment - 1)].date
                self.dictionary[(indexPath as NSIndexPath).section]?.insert(cellContent, at: ((indexPath as NSIndexPath).row + increment))
                tableView.insertRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + increment, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: (indexPath as NSIndexPath).row + 1)
                tableView.deleteRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + 1, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            }
            return
        }

        if (cell?.reuseIdentifier == "QuizCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            self.activeField?.resignFirstResponder()
            if (self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row + 1].identifier != "DatePickerTableViewCell") {
                tableView.beginUpdates()
                //Remove any existing pickerViewCells or datePickerViewCells.
                var increment = 1
                for (index, rowContent) in (self.dictionary[(indexPath as NSIndexPath).section]?.enumerated())! {
                    if (rowContent.identifier == "PickerTableViewCell" || rowContent.identifier == "DatePickerTableViewCell") {
                        self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: (indexPath as NSIndexPath).section)], with: .top)
                        if (index < (indexPath as NSIndexPath).row) {
                            increment -= 1
                        }
                    }
                }
                //Add New pickerViewCell.
                let cellContent = ScheduleRowContent(identifier: "DatePickerTableViewCell")
                cellContent.date = self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row + (increment - 1)].date
                self.dictionary[(indexPath as NSIndexPath).section]?.insert(cellContent, at: ((indexPath as NSIndexPath).row + increment))
                tableView.insertRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + increment, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: (indexPath as NSIndexPath).row + 1)
                tableView.deleteRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + 1, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            }
            return
        }

        if (cell?.reuseIdentifier == "MidtermCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            self.activeField?.resignFirstResponder()
            if (self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row + 1].identifier != "DatePickerTableViewCell") {
                tableView.beginUpdates()
                //Remove any existing pickerViewCells or datePickerViewCells.
                var increment = 1
                for (index, rowContent) in (self.dictionary[(indexPath as NSIndexPath).section]?.enumerated())! {
                    if (rowContent.identifier == "PickerTableViewCell" || rowContent.identifier == "DatePickerTableViewCell") {
                        self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: (indexPath as NSIndexPath).section)], with: .top)
                        if (index < (indexPath as NSIndexPath).row) {
                            increment -= 1
                        }
                    }
                }
                //Add New pickerViewCell.
                let cellContent = ScheduleRowContent(identifier: "DatePickerTableViewCell")
                cellContent.date = self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row + (increment - 1)].date
                self.dictionary[(indexPath as NSIndexPath).section]?.insert(cellContent, at: ((indexPath as NSIndexPath).row + increment))
                tableView.insertRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + increment, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: (indexPath as NSIndexPath).row + 1)
                tableView.deleteRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + 1, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            }
            return
        }

        if (cell?.reuseIdentifier == "FinalToggleCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            self.activeField?.resignFirstResponder()
            if (self.dictionary[(indexPath as NSIndexPath).section]?.count == 1) {
                self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row].toggle = true
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                tableView.beginUpdates()
                let cellContent = ScheduleRowContent(identifier: "FinalReminderCell")
                self.dictionary[(indexPath as NSIndexPath).section]?.insert(cellContent, at: ((indexPath as NSIndexPath).row + 1))
                //tableView.insertRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + 1, section: (indexPath as NSIndexPath).section)], with: .top)
                let newFinalCellContent = ScheduleRowContent(identifier: "NewFinalCell")
                self.dictionary[(indexPath as NSIndexPath).section]?.insert(newFinalCellContent, at: ((indexPath as NSIndexPath).row + 2))
                //tableView.insertRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + 1, section: (indexPath as NSIndexPath).section), IndexPath(row: (indexPath as NSIndexPath).row + 2, section: (indexPath as NSIndexPath).section)], with: .automatic)

                let realm = try! Realm()
                let coursePredicate = NSPredicate(format: "course = %@", self.course as CVarArg)
                let finalsWithoutNullDueDates = realm.objects(RLMTask.self).filter("removed = false AND dueDate != null AND type = 'Final'").filter(coursePredicate).sorted(byKeyPath: "dueDate", ascending: true)
                let finalsWithNullDueDates = realm.objects(RLMTask.self).filter("removed = false AND dueDate = null AND type = 'Final'").filter(coursePredicate).sorted(byKeyPath: "dueDate", ascending: true)
                let finals = finalsWithoutNullDueDates.toArray() + finalsWithNullDueDates.toArray()
                let finalScheduleRowContentArray = self.convertRLMTaskCollectionToScheduleRowContentArray(tasks: finals)
                self.dictionary[(indexPath as NSIndexPath).section]?.insert(contentsOf: finalScheduleRowContentArray, at: self.dictionary[(indexPath as NSIndexPath).section]!.count - 1)

                var indexPaths = [IndexPath]()
                for (rowCount, row) in self.dictionary[(indexPath as NSIndexPath).section]!.enumerated() {
                    if (row.identifier != "FinalToggleCell") {
                        indexPaths.append(IndexPath(row: rowCount, section: (indexPath as NSIndexPath).section))
                    }
                }
                tableView.insertRows(at: indexPaths, with: .automatic)

                tableView.endUpdates()
            } else {
                self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row].toggle = false
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                tableView.beginUpdates()
                var indexPaths = [IndexPath]()
                for (rowCount, row) in self.dictionary[(indexPath as NSIndexPath).section]!.enumerated() {
                    if (row.identifier != "FinalToggleCell") {
                        self.dictionary[(indexPath as NSIndexPath).section]?.removeObject(object: row)
                        indexPaths.append(IndexPath(row: rowCount, section: (indexPath as NSIndexPath).section))
                    }
                }
                tableView.deleteRows(at: indexPaths, with: .automatic)
                tableView.endUpdates()
            }
            return
            /*tableView.beginUpdates()
            if (self.hideAllPickerViews((indexPath as NSIndexPath).section) == true) {
                self.dictionary[5]?.insert(ScheduleRowContent(identifier: "FinalReminderCell"), at: (self.dictionary[5]!.count - 1))
                tableView.insertRows(at: [IndexPath(row: self.dictionary[5]!.count - 2, section: (indexPath as NSIndexPath).section)], with: .automatic)
            } else {
                self.dictionary[5]?.insert(ScheduleRowContent(identifier: "FinalReminderCell"), at: (self.dictionary[5]!.count - 1))
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
            tableView.endUpdates()
            return*/
        }

        if (cell?.reuseIdentifier == "FinalReminderCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            self.activeField?.resignFirstResponder()
            if (self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row + 1].identifier != "DatePickerTableViewCell") {
                tableView.beginUpdates()
                //Remove any existing pickerViewCells or datePickerViewCells.
                var increment = 1
                for (index, rowContent) in (self.dictionary[(indexPath as NSIndexPath).section]?.enumerated())! {
                    if (rowContent.identifier == "PickerTableViewCell" || rowContent.identifier == "DatePickerTableViewCell") {
                        self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: (indexPath as NSIndexPath).section)], with: .top)
                        if (index < (indexPath as NSIndexPath).row) {
                            increment -= 1
                        }
                    }
                }
                //Add New pickerViewCell.
                let cellContent = ScheduleRowContent(identifier: "DatePickerTableViewCell")
                cellContent.date = self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row + (increment - 1)].date
                self.dictionary[(indexPath as NSIndexPath).section]?.insert(cellContent, at: ((indexPath as NSIndexPath).row + increment))
                tableView.insertRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + increment, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: (indexPath as NSIndexPath).row + 1)
                tableView.deleteRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + 1, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            }
            return
        }

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = rgbaToUIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1.0)
        if (section == 1) {
            //Way to do it using Cells.
            /*let headerViewCell = tableView.dequeueReusableCellWithIdentifier("GeneralHeaderCell")!
            headerViewCell.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
            headerViewCell.backgroundColor = UIColor.clearColor()
            headerView.frame = headerViewCell.frame
            headerViewCell.autoresizingMask = [.FlexibleHeight,  .FlexibleWidth]
            headerView.addSubview(headerViewCell)
            return headerView*/
            let headerView = SectionHeaderView.construct("General", owner: tableView)
            return headerView
        }

        if (section == 2) {
            let headerView = SectionHeaderView.construct("Assignments", owner: tableView)
            return headerView
        }

        if (section == 3) {
            let headerView = SectionHeaderView.construct("Quizzes", owner: tableView)
            return headerView
        }

        if (section == 4) {
            let headerView = SectionHeaderView.construct("Midterms", owner: tableView)
            return headerView
        }

        if (section == 5) {
            let headerView = SectionHeaderView.construct("Final", owner: tableView)
            return headerView
        }

        if (section == 6) {
            let headerView = SectionHeaderView.construct("Labs/Tutorials", owner: tableView)
            return headerView
        }

        let invisView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        invisView.backgroundColor = UIColor.clear
        return invisView

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 || section == 7 || section == 8) {
            return CGFloat.leastNormalMagnitude
        } else {
            return 21.0
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if (self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row].identifier == "FinalCell") {
            let alertController = UIAlertController(title: "Final Exam", message: "You will be reminded to add a date for this exam when the final exam schedule is released.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if (self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row].identifier == "FinalReminderCell") {
            let alertController = UIAlertController(title: "Final Exam Reminder", message: "If your school has not yet released their final exam schedule, you can set a reminder to add your final exam(s). Or you can choose to add them now by tapping New Final below.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath)
        if (cell?.reuseIdentifier == "FinalReminderCell") {
            return true
        }
        if (cell?.reuseIdentifier == "AssignmentCell" || cell?.reuseIdentifier == "QuizCell" || cell?.reuseIdentifier == "MidtermCell" || cell?.reuseIdentifier == "LLTCell") {
            self.activeField?.resignFirstResponder()
            //Dismiss any pickerView or dateView cells that are below the editing cell.
            if ((self.dictionary[(indexPath as NSIndexPath).section]?.count)! > (indexPath as NSIndexPath).row + 1) {
                if (self.dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row + 1].identifier == "DatePickerTableViewCell" || self.dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row + 1].identifier == "PickerTableViewCell") {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Clear"
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if (editingStyle == UITableViewCellEditingStyle.delete && cell?.reuseIdentifier == "FinalReminderCell") {
            let finalReminderCell = cell as? FinalReminderTableViewCell
            tableView.beginUpdates()
            self.dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row].date = nil
            //finalReminderCell?.rhsLabel.text = "Set Date"
            tableView.reloadRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            return
        }
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            tableView.beginUpdates()
            self.dictionary[(indexPath as NSIndexPath).section]!.remove(at: (indexPath as NSIndexPath).row)
            tableView.reloadSections(IndexSet(integer: (indexPath as NSIndexPath).section), with: .automatic)
            tableView.endUpdates()
            return
        }
    }

    //UITextFieldDelegate

    var activeField : UITextField?

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
        self.hideAllPickerViews()
    }

    //After tapping 'Next' or 'Done', OR scrolling to dismiss keyboard.
    func textFieldDidEndEditing(_ textField: UITextField) {
        let point = self.tableView.convert(CGPoint.zero, from: textField)
        let indexPath = self.tableView.indexPathForRow(at: point)
        self.dictionary[((indexPath! as NSIndexPath).section)]![(indexPath! as NSIndexPath).row].name = textField.text
        self.activeField = nil

        let identifier = self.dictionary[((indexPath! as NSIndexPath).section)]![(indexPath! as NSIndexPath).row].identifier
        if (identifier == "CourseNameCell") {
            textField.resignFirstResponder()
            if (textField.text!.characters.count == 0) {
                let alertController = UIAlertController(title: "Oops..", message: "Course Name should not be empty.", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil)
                alertController.addAction(actionOk)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            let realm = try! Realm()
            realm.beginWrite()
            self.course.courseName = textField.text!
            do {
                try realm.commitWrite()
            } catch let error {

            }
            self.setTitle()
            self.coursesVC.tableView.reloadData()
            self.homeVC.tableView.reloadData()
        }

        if (identifier == "CourseCodeCell") {
            textField.resignFirstResponder()
            if (textField.text!.characters.count == 0) {
                let alertController = UIAlertController(title: "Oops..", message: "Course Code should not be empty.", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil)
                alertController.addAction(actionOk)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            let realm = try! Realm()
            realm.beginWrite()
            self.course.courseCode = textField.text!
            do {
                try realm.commitWrite()
            } catch let error {

            }
            self.setTitle()
            self.coursesVC.tableView.reloadData()
            self.homeVC.tableView.reloadData()
        }

    }

    //After tapping 'Done' or 'Next'
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let point = self.tableView.convert(CGPoint.zero, from: textField)
        let indexPath = self.tableView.indexPathForRow(at: point)
        let identifier = self.dictionary[((indexPath! as NSIndexPath).section)]![(indexPath! as NSIndexPath).row].identifier

        if (identifier == "CourseNameCell") {
            let courseCodeCell = self.tableView.cellForRow(at: IndexPath(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)) as! CourseCodeEditingTableViewCell
            if (self.traitCollection.horizontalSizeClass == .compact && self.traitCollection.verticalSizeClass == .compact) {
                self.tableView.scrollToRow(at: IndexPath(row: ((indexPath as NSIndexPath?)?.row)! + 1, section: 1), at: .top, animated: true)
            }
            courseCodeCell.textField.becomeFirstResponder()
        }

        if (identifier == "CourseCodeCell") {
            textField.resignFirstResponder()
        }

        if (identifier == "ProfessorCell") {
            textField.resignFirstResponder()
            self.tableView.selectRow(at: IndexPath(row: ((indexPath as NSIndexPath?)?.row)! + 1, section: 1), animated: true, scrollPosition: .middle)
            self.tableView(self.tableView, didSelectRowAt: IndexPath(row: ((indexPath as NSIndexPath?)?.row)! + 1, section: 1))
        }

        if (identifier == "AssignmentCell") {
            textField.resignFirstResponder()
            self.tableView.selectRow(at: IndexPath(row: (indexPath! as NSIndexPath).row, section: (indexPath! as NSIndexPath).section), animated: true, scrollPosition: .none)
            self.tableView(self.tableView, didSelectRowAt: IndexPath(row: (indexPath! as NSIndexPath).row, section: (indexPath! as NSIndexPath).section))
        }

        if (identifier == "QuizCell") {
            textField.resignFirstResponder()
            self.tableView.selectRow(at: IndexPath(row: (indexPath! as NSIndexPath).row, section: (indexPath! as NSIndexPath).section), animated: true, scrollPosition: .none)
            //scrollPosition has to be .None for above method because it relies on estimatedHeightForRowAtIndexPath which can be inaccurate.
            self.tableView(self.tableView, didSelectRowAt: IndexPath(row: (indexPath! as NSIndexPath).row, section: (indexPath! as NSIndexPath).section))
            //self.tableView.scrollToNearestSelectedRowAtScrollPosition(.Middle, animated: true) //doesn't work & causes odd behaviour.
            //let datePickerCellIndexPath = NSIndexPath(forRow: indexPath!.row + 1, inSection: indexPath!.section)
            //var scrollToFrame = self.tableView.cellForRowAtIndexPath(datePickerCellIndexPath)!.frame
            //self.tableView.scrollRectToVisible(scrollToFrame, animated: true) //also occasionally causes odd behaviour as-is.
        }

        if (identifier == "MidtermCell") {
            textField.resignFirstResponder()
            self.tableView.selectRow(at: IndexPath(row: (indexPath! as NSIndexPath).row, section: (indexPath! as NSIndexPath).section), animated: true, scrollPosition: .none)
            self.tableView(self.tableView, didSelectRowAt: IndexPath(row: (indexPath! as NSIndexPath).row, section: (indexPath! as NSIndexPath).section))
        }

        return true
     }


    //Keyboard Notifications.

    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleEditorViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @IBOutlet var baseConstraint: NSLayoutConstraint!

    @objc func keyboardWillShow(_ aNotification: Notification)    {
        //Collect information about keyboard using its notification.
        let info = (aNotification as NSNotification).userInfo!
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue) as! Double
        let curve = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSValue) as! UInt
        let kbFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //baseConstraint.constant = kbFrame.size.height
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.init(rawValue: curve), animations: {
            //self.tableView.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
        })
    }

    @objc func keyboardWillBeHidden(_ aNotification: Notification)    {
        let info = (aNotification as NSNotification).userInfo!
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue) as! Double
        let curve = (info[UIKeyboardAnimationCurveUserInfoKey] as! NSValue) as! UInt
        //baseConstraint.constant = 0
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.init(rawValue: curve), animations: {
            //self.tableView.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
        })
    }

    //UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let customPickerView = pickerView as! CustomPickerView
        let cellContent = self.dictionary[customPickerView.indexPath.section]![customPickerView.indexPath.row]
        let titleForRow = cellContent.pickerDataSource?.dataArray[row]
        let attributedTitleForRow = NSAttributedString(string: titleForRow!, attributes: [NSAttributedStringKey.foregroundColor : UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 1.0)])
        return attributedTitleForRow
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Get title from pickerViewer row.
        let customPickerView = pickerView as! CustomPickerView
        let cellContent = self.dictionary[customPickerView.indexPath.section]![customPickerView.indexPath.row]
        let titleForRow = cellContent.pickerDataSource?.dataArray[row]

        //Update information in pickerViewCell.
        let pickerViewCellContent = self.dictionary[customPickerView.indexPath.section]![customPickerView.indexPath.row]
        pickerViewCellContent.pickerTitleForRow = pickerViewCellContent.pickerDataSource?.dataArray[row]

        //Update tableView accordingly.
        self.tableView.beginUpdates()
        let cellContentNeedingModification = self.dictionary[customPickerView.indexPath.section]![customPickerView.indexPath.row - 1]
        cellContentNeedingModification.pickerTitleForRow = titleForRow
        self.tableView.reloadRows(at: [IndexPath(row: customPickerView.indexPath.row - 1, section: customPickerView.indexPath.section)], with: .none)
        self.tableView.endUpdates()

        if (self.dictionary[customPickerView.indexPath.section]![customPickerView.indexPath.row - 1].identifier == "SemesterCell") {
            self.minimumDate = self.semesterDates[self.dictionary[customPickerView.indexPath.section]![customPickerView.indexPath.row - 1].pickerTitleForRow!]![0]
            self.maximumDate = self.semesterDates[self.dictionary[customPickerView.indexPath.section]![customPickerView.indexPath.row - 1].pickerTitleForRow!]![1]
        }
    }

    //UIDatePickerAction (essentially a delegate).

    @IBAction func DatePickerValueChanged(_ sender: AnyObject) {
        //Get date from customDatePickerView.
        let customDatePickerView = sender as! CustomDatePickerView

        //Update information in datePickerViewCell.
        let datePickerViewCellContent = self.dictionary[customDatePickerView.indexPath.section]![customDatePickerView.indexPath.row]
        datePickerViewCellContent.date = customDatePickerView.date

        //Update tableView accordingly.
        self.tableView.beginUpdates()
        let cellContentNeedingModification = self.dictionary[customDatePickerView.indexPath.section]![customDatePickerView.indexPath.row - 1]
        cellContentNeedingModification.date = customDatePickerView.date
        self.tableView.reloadRows(at: [IndexPath(row: customDatePickerView.indexPath.row - 1, section: customDatePickerView.indexPath.section)], with: .none)
        self.tableView.endUpdates()

        /*let scheduledNotifications: [UILocalNotification]? = UIApplication.shared.scheduledLocalNotifications
        if (scheduledNotifications != nil) {
            for notification in scheduledNotifications! { // loop through notifications...
                if (notification.userInfo!["type"] as! String == "Final Reminder" && (notification.userInfo!["date"] as! Date).numberOfDaysUntilDate() == datePickerViewCellContent.date!.numberOfDaysUntilDate()) {
                    UIApplication.shared.cancelLocalNotification(notification)
                    break
                }
            }
        }

       let notification = UILocalNotification()
        notification.alertBody = "It is time to schedule Finals. Go knock 'em out." // text that will be displayed in the notification
        //notification.alertAction = "" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"

        let gregorian = Calendar(identifier: .gregorian)
        let fireDate = datePickerViewCellContent.date
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate!)
        // Change the time to 4:30PM in your locale
        components.hour = 4
        components.minute = 30
        components.second = 0

        let date = gregorian.date(from: components)!
        notification.fireDate = fireDate // todo item due date (when notification will be fired) notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["type" : "Final Reminder", "date" : cellContentNeedingModification.date!] // assign a unique identifier to the notification so that we can retrieve it later

        UIApplication.shared.scheduleLocalNotification(notification)*/

    }


    //Other

    func determineDefaultSemester() -> String {
        self.determineMinAndMaxDatesForSemester()
        let date = Date()
        var era = 0, year = 0, month = 0, day = 0
        (Calendar.current as NSCalendar).getEra(&era, year:&year, month:&month, day:&day, from: date)
        if (month >= 9) { //First Semester.
            self.dictionary[1]![1].pickerTitleForRow = PickerDataSource(source: .standardSemester).dataArray[0]
            self.minimumDate = self.semesterDates["Fall"]![0]
            self.maximumDate = self.semesterDates["Fall"]![1]
            return PickerDataSource(source: .standardSemester).dataArray[0]
        } else if (month <= 3) { //Second Semester.
            self.dictionary[1]![1].pickerTitleForRow = PickerDataSource(source: .standardSemester).dataArray[1]
            self.minimumDate = self.semesterDates["Spring"]![0]
            self.maximumDate = self.semesterDates["Spring"]![1]
            return PickerDataSource(source: .standardSemester).dataArray[1]
        } else { //Summer Semester.
            self.dictionary[1]![1].pickerTitleForRow = PickerDataSource(source: .standardSemester).dataArray[2]
            self.minimumDate = self.semesterDates["Summer"]![0]
            self.maximumDate = self.semesterDates["Summer"]![1]
            return PickerDataSource(source: .standardSemester).dataArray[2]
        }
    }

    func determineMinAndMaxDatesForSemester() {
        //let nowDate = NSDate()

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

    func createDateFromComponents(_ month: Int, day: Int, year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 0
        dateComponents.minute = 0
        return Calendar.current.date(from: dateComponents)!
    }

    func hideAllPickerViews() {
        //This prevents crash.
        var pickerViewsNeedHiding = false
        for cell in self.tableView.visibleCells {
            if (cell.reuseIdentifier == "PickerTableViewCell" || cell.reuseIdentifier == "DatePickerTableViewCell") {
                pickerViewsNeedHiding = true
            }
        }

        if (pickerViewsNeedHiding == false) {
            return
        }

        var sectionCounter = 0
        for _ in self.dictionary {
            for (index, rowContent) in (self.dictionary[sectionCounter]?.enumerated())! {
                if (rowContent.identifier == "PickerTableViewCell" || rowContent.identifier == "DatePickerTableViewCell") {
                    self.dictionary[sectionCounter]?.remove(at: index)
                    tableView.deleteRows(at: [IndexPath(row: index, section: sectionCounter)], with: .top)
                }
            }
            sectionCounter += 1
        }
    }

    func hideAllPickerViews(_ section : Int) -> Bool { //For use when New[Assignment][Quiz][etc..]Cell tapped.
        var sameSection = false
        //This prevents crash.
        var pickerViewsNeedHiding = false
        for cell in self.tableView.visibleCells {
            if (cell.reuseIdentifier == "PickerTableViewCell" || cell.reuseIdentifier == "DatePickerTableViewCell") {
                pickerViewsNeedHiding = true
            }
        }

        if (pickerViewsNeedHiding == false) {
            return false
        }

        var sectionCounter = 0
        for _ in self.dictionary {
            for (index, rowContent) in (self.dictionary[sectionCounter]?.enumerated())! {
                if (rowContent.identifier == "PickerTableViewCell" || rowContent.identifier == "DatePickerTableViewCell") {
                    if (section == sectionCounter) {
                        sameSection = true
                        self.dictionary[sectionCounter]?.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: sectionCounter)], with: .top)
                    } else {
                        self.dictionary[sectionCounter]?.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: sectionCounter)], with: .top)
                    }
                }
            }
            sectionCounter += 1
        }
        return sameSection
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getScheduleRowContentWithIdentifier(identifier: String) -> ScheduleRowContent? {
        for (section, rows) in self.dictionary {
            for row in rows {
                if (row.identifier == identifier) {
                    return row
                }
            }
        }
        return nil
    }

    // MARK: - HomeworkTableViewCellDelegate

    func taskDeleted(_ task: RLMTask) {
        let indexPathForRow = self.homeVC.indexOfTask(task: task)
        let scheduleEditorIndexPath = self.indexOfTask(task: task)
        //insert code to customize HWCell in ScheduleEditor Here.
        if (indexPathForRow == nil) {
            let realm = try! Realm()
            realm.beginWrite()
            //realm.delete(task)
            task.removed = true
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription + " This is a rare issue.", preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
                return
            }
            self.dictionary[scheduleEditorIndexPath!.section]?.remove(at: scheduleEditorIndexPath!.row)
            self.homeVC.playDeleteSound()
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [scheduleEditorIndexPath!], with: .left)
            self.tableView.endUpdates()
            if (self.homeVC.splitViewController!.viewControllers.count >= 2) {
            if (self.homeVC.splitViewController!.viewControllers[1] is CellEditingTableViewController || (self.homeVC.splitViewController!.viewControllers[1] as? UINavigationController)?.topViewController is CellEditingTableViewController) {
                if let cellEditingVC = self.homeVC.splitViewController!.viewControllers[1] as? CellEditingTableViewController {
                    if (cellEditingVC.helperObject.task.id == task.id) {
                        self.homeVC.splitViewController!.viewControllers[1] = self.storyboard!.instantiateViewController(withIdentifier: "BlankTabBarController")
                    }
                } else {
                    let cellEditingVC = (self.homeVC.splitViewController!.viewControllers[1] as! UINavigationController).topViewController as! CellEditingTableViewController
                    if (cellEditingVC.helperObject.task.id == task.id) {
                        self.homeVC.splitViewController!.viewControllers[1] = self.storyboard!.instantiateViewController(withIdentifier: "BlankTabBarController")
                    }
                }
            }
            }
            return
        }

        var cellWasSelected = false
        if (self.homeVC.tableView.cellForRow(at: indexPathForRow!)?.isSelected == true) {
            cellWasSelected = true
        }

        let realm = try! Realm()
        realm.beginWrite()
        //realm.delete(task)
        task.removed = true
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription + " This is a rare issue.", preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
            return
        }
        self.dictionary[scheduleEditorIndexPath!.section]?.remove(at: scheduleEditorIndexPath!.row)

        // use the UITableView to animate the removal of this row
        self.homeVC.tableView.beginUpdates()
        self.homeVC.tableView.deleteRows(at: [indexPathForRow!], with: .left)
        self.homeVC.tableView.endUpdates()

        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [scheduleEditorIndexPath!], with: .left)
        self.tableView.endUpdates()

        self.homeVC.playDeleteSound()

        //Remove Completed Today Section if needed.
        self.homeVC.tableView.beginUpdates()
        if (self.homeVC.completedTodayTasks.count == 0) {
            if let completedTodaySection = self.homeVC.sections.first(where: { $0 == "Completed Today" }) {
                let indexOfSection = self.homeVC.sections.index(of: completedTodaySection)!
                self.homeVC.sections.removeObject(object: completedTodaySection)
                self.homeVC.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.homeVC.tableView.endUpdates()
        //

        //Remove Extended Section if needed.
        self.homeVC.tableView.beginUpdates()
        if (self.homeVC.extendedTasks.count == 0) {
            if let extendedTasksSection = self.homeVC.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.homeVC.sections.index(of: extendedTasksSection)!
                self.homeVC.sections.removeObject(object: extendedTasksSection)
                self.homeVC.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.homeVC.tableView.endUpdates()
        //

        if (self.homeVC.splitViewController!.isCollapsed == false && cellWasSelected == true) {
            self.homeVC.splitViewController!.viewControllers[1] = self.storyboard!.instantiateViewController(withIdentifier: "BlankTabBarController")
        }

        //Close SplitViewController secondary VC if it is a CellEditingTVC representing the deleted task.
        if (self.homeVC.splitViewController!.viewControllers.count <= 1) {
            return
        }
        if (self.homeVC.splitViewController!.viewControllers[1] is CellEditingTableViewController || (self.homeVC.splitViewController!.viewControllers[1] as? UINavigationController)?.topViewController is CellEditingTableViewController) {
            if let cellEditingVC = self.homeVC.splitViewController!.viewControllers[1] as? CellEditingTableViewController {
                if (cellEditingVC.helperObject.task.id == task.id) {
                    self.homeVC.splitViewController!.viewControllers[1] = self.storyboard!.instantiateViewController(withIdentifier: "BlankTabBarController")
                }
            } else {
                let cellEditingVC = (self.homeVC.splitViewController!.viewControllers[1] as! UINavigationController).topViewController as! CellEditingTableViewController
                if (cellEditingVC.helperObject.task.id == task.id) {
                    self.homeVC.splitViewController!.viewControllers[1] = self.storyboard!.instantiateViewController(withIdentifier: "BlankTabBarController")
                }
            }
        }

    }

    func taskCompleted(_ task: RLMTask) {
        let indexPath = self.homeVC.indexOfTask(task: task)
        //insert code to customize HWCell in ScheduleEditor Here.

        if (task.completed != true) {
            let cell = self.tableView.cellForRow(at: self.indexOfTask(task: task)!) as? HomeworkTableViewCell
            cell?.leadingCompletionConstraint.constant = 32
            self.homeVC.strikeThroughLabel(cell?.titleLabel)
            self.homeVC.strikeThroughLabel(cell?.courseLabel)
            self.homeVC.strikeThroughLabel(cell?.dueDateLabel)
            self.homeVC.strikeThroughLabel(cell?.dateLabel)
            //Fixes minor display bug on completion in iOS9 and earlier.
            cell?.cardView.sizeToFit()
            //
            cell?.completionImageView.layer.shadowRadius = 0.5
            cell?.completionImageView.layer.shadowOpacity = 1.0
        } else {
            let cell = self.tableView.cellForRow(at: self.indexOfTask(task: task)!) as? HomeworkTableViewCell
            cell?.leadingCompletionConstraint.constant = -60
            self.homeVC.unstrikeThroughLabel(cell?.titleLabel)
            self.homeVC.unstrikeThroughLabel(cell?.courseLabel)
            self.homeVC.unstrikeThroughLabel(cell?.dueDateLabel)
            self.homeVC.unstrikeThroughLabel(cell?.dateLabel)
            cell?.titleLabel.textColor = UIColor.black
            cell?.courseLabel.textColor = UIColor.black
            cell?.dueDateLabel.textColor = UIColor.black
            cell?.dateLabel.textColor = UIColor.black
            cell?.completionImageView.image = #imageLiteral(resourceName: "Grey Checkmark")
            cell?.completionImageView.layer.shadowRadius = 3.0
            cell?.completionImageView.layer.shadowOpacity = 0.25
            //cell?.repeatsImageView.image = #imageLiteral(resourceName: "Black Repeats")
        }
        if (indexPath == nil) {
            if (task.completed != true) {
                self.homeVC.playCompletedSound()
                self.homeVC.taptic.feedback()
            } else {
                self.homeVC.playNotCompletedSound()
                self.homeVC.taptic.feedback()
            }
            return
        }
        let section = indexPath!.section
        let index = indexPath!.row

        if (task.completed != true) {
            let indexPathForRow = IndexPath(row: index, section: section)
            let cell = self.homeVC.tableView.cellForRow(at: indexPathForRow) as? HomeworkTableViewCell
            UIView.animate(withDuration: 0.07, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { cell?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05) }, completion: {
                finished in
                UIView.animate(withDuration: 0.07, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) }, completion: {
                    finished in
                    UIView.animate(withDuration: 0.07, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { cell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) }, completion: { finished in

                    })
                })
            })
            cell?.leadingCompletionConstraint.constant = 32
            self.homeVC.strikeThroughLabel(cell?.titleLabel)
            self.homeVC.strikeThroughLabel(cell?.courseLabel)
            self.homeVC.strikeThroughLabel(cell?.dueDateLabel)
            self.homeVC.strikeThroughLabel(cell?.dateLabel)
            cell?.titleLabel.textColor = self.homeVC.FADED_BLACK_COLOR
            cell?.courseLabel.textColor = self.homeVC.FADED_BLACK_COLOR
            cell?.dueDateLabel.textColor = self.homeVC.FADED_BLACK_COLOR
            cell?.dateLabel.textColor = self.homeVC.FADED_BLACK_COLOR
            cell?.completionImageView.image = #imageLiteral(resourceName: "Green Checkmark")
            //Fixes minor display bug on completion in iOS9 and earlier.
            cell?.cardView.sizeToFit()
            //
            cell?.completionImageView.layer.shadowRadius = 0.5
            cell?.completionImageView.layer.shadowOpacity = 1.0
            self.homeVC.playCompletedSound()
            self.homeVC.taptic.feedback()

        } else {
            let indexPathForRow = IndexPath(row: index, section: section)
            let cell = self.homeVC.tableView.cellForRow(at: indexPathForRow) as? HomeworkTableViewCell
            UIView.animate(withDuration: 0.07, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { cell?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05) }, completion: {
                finished in
                UIView.animate(withDuration: 0.07, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) }, completion: {
                    finished in
                    UIView.animate(withDuration: 0.07, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: { cell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) }, completion: { finished in

                    })
                })
            })
            cell?.leadingCompletionConstraint.constant = -60
            self.homeVC.unstrikeThroughLabel(cell?.titleLabel)
            self.homeVC.unstrikeThroughLabel(cell?.courseLabel)
            self.homeVC.unstrikeThroughLabel(cell?.dueDateLabel)
            self.homeVC.unstrikeThroughLabel(cell?.dateLabel)
            cell?.titleLabel.textColor = UIColor.black
            cell?.courseLabel.textColor = UIColor.black
            cell?.dueDateLabel.textColor = UIColor.black
            cell?.dateLabel.textColor = UIColor.black
            cell?.completionImageView.image = #imageLiteral(resourceName: "Green Checkmark")
            cell?.completionImageView.layer.shadowRadius = 3.0
            cell?.completionImageView.layer.shadowOpacity = 0.25
            //cell.cardView.alpha = 1.0
            self.homeVC.playNotCompletedSound()
            self.homeVC.taptic.feedback()
        }
    }

    func moveTask(_ cell: HomeworkTableViewCell, _ task: RLMTask) {
        var indexPath = self.homeVC.indexOfTask(task: task)
        if (indexPath == nil) { //As of Tuesday, Feb 6, 2018: A bunch of code got deleted to stop tasks from SchedulesVC from appearing unexpectedly in Agenda view.

            //Save Task and Insert Task into Completed Today Section.
            let realm = try! Realm()
            realm.beginWrite()
            task.completed = !task.completed
            if (task.completed == true) {
                ///task.completionDate = NSDate()
            } else {
                task.completionDate = nil
                if (task.repeatingSchedule != nil) { task.repeatingTaskWasUncompleted = true }
            }
            //The following if statement exists purely to cover the following scenario: Completed task that had its due date extended to over two weeks from now since it was completed is now uncompleted. It doesn't go to extended section w/o setting property.
            if (task.dueDate != nil && task.dueDate!.overScopeThreshold(task: task) && task.dateOfExtension == nil) {
                if (task.completed == false) { //&& indexPath != nil
                    ///task.dateOfExtension = NSDate()
                } else {
                    task.dateOfExtension = nil
                }
            }
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription + " This is a rare issue.", preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
                return
            }
                //
            //
            self.homeVC.tableView.beginUpdates()
                if let indexPathInHomeVC = self.homeVC.indexOfTask(task: task) {
                    self.homeVC.tableView.insertRows(at: [indexPathInHomeVC], with: .fade)
                }
            self.homeVC.tableView.endUpdates()

            UIView.animate(withDuration: 0.27, delay: 0.0, options: [], animations: {
                if (task.completed == true) {
                    cell.titleLabel.textColor = self.homeVC.FADED_BLACK_COLOR
                    cell.courseLabel.textColor = self.homeVC.FADED_BLACK_COLOR
                    cell.dueDateLabel.textColor = self.homeVC.FADED_BLACK_COLOR
                    cell.dateLabel.textColor = self.homeVC.FADED_BLACK_COLOR
                    cell.repeatsImageView.image = #imageLiteral(resourceName: "Grey Repeats")
                }
            }, completion: nil)
            return
        }
        //Crash is from inconsistency in HomeVC Data Model. i.e. A task completed that wasn't originally on HomeVC now should be because it was Completed Today. The opposite also occurs: A completed task that is uncompleted and wasn't originally on HomeVC should now be deleted from HomeVC. For both of these circumstances, the task could also be 'Extended', meaning it SHOULD have a dateOfExtension set if the due date is over two weeks away. It is fine for tasks to become extended from completion/uncompletion, as uncompleting/completing a task does mean it is/was extended. (so do not modify saving or HomeVC)
        //^^ Fix HomeVC handling of completion/uncompletion in this method.

        //Add Completed Today Section if needed.
        self.homeVC.tableView.beginUpdates()
        if (task.completed == false && self.homeVC.completedTodayTasks.count == 0) {
            if self.homeVC.sections.first(where: { $0 == "Completed Today" }) == nil {
                self.homeVC.sections.insert("Completed Today", at: 1)
                self.homeVC.tableView.insertSections([1], with: .automatic)
            }
            //The following code allows for the Completed/Extended Sections to be 'replaced' - in the case that one is removed for the other.
            if (task.dueDate != nil) {
                if (self.homeVC.completedTodayTasks.count == 0 && (task.dueDate! as Date).overScopeThreshold(task: task)) {
                    indexPath?.section += 1
                }
            }
            //
        }
        self.homeVC.tableView.endUpdates()
        //


        //Add Extended Section if needed.
        self.homeVC.tableView.beginUpdates()
        if (task.dueDate?.overScopeThreshold(task: task) == true && self.homeVC.extendedTasks.count == 0) { //&& task.completed == true
            if self.homeVC.sections.first(where: { $0 == "Extended" }) == nil && self.homeVC.sections.first(where: { $0 == "Completed Today" }) == nil {
                self.homeVC.sections.insert("Extended", at: 1)
                self.homeVC.tableView.insertSections([1], with: .automatic)
            } else if self.homeVC.sections.first(where: { $0 == "Extended" }) == nil && self.homeVC.sections.first(where: { $0 == "Completed Today" }) != nil {
                self.homeVC.sections.insert("Extended", at: 2)
                self.homeVC.tableView.insertSections([2], with: .automatic)
            }
        }
        self.homeVC.tableView.endUpdates()
        //

        let realm = try! Realm()
        realm.beginWrite()
        task.completed = !task.completed
        if (task.completed == true) { task.completionDate = NSDate() } else { task.completionDate = nil }
        if (task.completed == false && task.repeatingSchedule != nil) { task.repeatingTaskWasUncompleted = true }
        //The following if statement exists purely to cover the following scenario: Completed task that had its due date extended to over two weeks from now since it was completed is now uncompleted. It doesn't go to extended section w/o setting property.
        if (task.dueDate != nil && task.dueDate!.overScopeThreshold(task: task) && task.dateOfExtension == nil) {
            if (task.completed == false) { //&& indexPath != nil
                task.dateOfExtension = NSDate()
            } else {
                task.dateOfExtension = nil
            }
        }
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription + " This is a rare issue.", preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
            return
        }

        var newIndexPath = self.homeVC.indexOfTask(task: task)!
        /*if (self.completedTodayTasks.count == 0) {
         newIndexPath.section += 1
         }*/

        UIView.animate(withDuration: 0.27, delay: 0.0, options: [], animations: {
            self.homeVC.tableView.beginUpdates()
            if (indexPath != nil) {
                self.homeVC.tableView.moveRow(at: indexPath!, to: newIndexPath)
                if (task.completed == true) {
                    cell.titleLabel.textColor = self.homeVC.FADED_BLACK_COLOR
                    cell.courseLabel.textColor = self.homeVC.FADED_BLACK_COLOR
                    cell.dueDateLabel.textColor = self.homeVC.FADED_BLACK_COLOR
                    cell.dateLabel.textColor = self.homeVC.FADED_BLACK_COLOR
                }
            }
            self.homeVC.tableView.endUpdates()
        }, completion: nil)

        //Remove Completed Today Section if needed.
        self.homeVC.tableView.beginUpdates()
        if (self.homeVC.completedTodayTasks.count == 0) {
            if let completedTodaySection = self.homeVC.sections.first(where: { $0 == "Completed Today" }) {
                let indexOfSection = self.homeVC.sections.index(of: completedTodaySection)!
                self.homeVC.sections.removeObject(object: completedTodaySection)
                self.homeVC.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.homeVC.tableView.endUpdates()
        //

        //Remove Extended Section if needed.
        self.homeVC.tableView.beginUpdates()
        if (self.homeVC.extendedTasks.count == 0) {
            if let extendedTasksSection = self.homeVC.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.homeVC.sections.index(of: extendedTasksSection)!
                self.homeVC.sections.removeObject(object: extendedTasksSection)
                self.homeVC.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.homeVC.tableView.endUpdates()
        //
    }

    func indexOfTask(task: RLMTask) -> IndexPath? {
        for (section, rows) in self.dictionary {
            var rowCounter = 0
            for row in rows {
                if (row.task == task) {
                    return IndexPath(row: rowCounter, section: section)
                }
                rowCounter = rowCounter + 1
            }
        }
        return nil
    }

    //

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.destination is WeeklyEditingTableViewController) {
            let weeklyEditingTVC = segue.destination as! WeeklyEditingTableViewController
            weeklyEditingTVC.scheduleEditorVC = self
            weeklyEditingTVC.course = self.course
            weeklyEditingTVC.coursesVC = self.coursesVC
            weeklyEditingTVC.homeVC = self.homeVC
            if (sender is LectureTableViewCell) {
                weeklyEditingTVC.type = "Lecture"
            } else if (sender is LabsTableViewCell) {
                weeklyEditingTVC.type = "Lab"
            } else if (sender is TutorialsTableViewCell) {
                weeklyEditingTVC.type = "Tutorial"
            }
        }
    }


}
