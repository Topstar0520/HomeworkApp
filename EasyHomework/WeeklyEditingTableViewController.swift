//
//  WeeklyEditingTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-08-26.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class WeeklyEditingTableViewController: UITableViewController, UIPickerViewDelegate, UITextFieldDelegate, HomeworkTableViewCellDelegate {

    var dictionary :[Int:Array<ScheduleRowContent>] = [0 : [ScheduleRowContent(identifier: "InstructionsCell")], 1 : [ScheduleRowContent(identifier: "LocationCell")], 2 : [ScheduleRowContent(identifier: "WeekdayCell", defaultToggleArray: [false, false, false, false, false])], 3 : [ScheduleRowContent(identifier: "UseCell")], 4 : [ScheduleRowContent(identifier: "NoPastTypeCell")] ]
    var type: String!
    var course: RLMCourse!
    var repeatingSchedule: RLMRepeatingSchedule!
    var scheduleEditorVC: ScheduleEditorViewController!
    var coursesVC: CoursesViewController!
    var homeVC: HomeworkViewController!
    //The following 2 variables exist only to ensure that HWcells look selected after being reloaded (since reloading a tableView cell deselects it).
    var lastSelectedRowIndexPath : IndexPath?
    var useLastSelectedRowIndexPath = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 71
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if (type == "Lecture") {
            self.dictionary[0]![0].name = "Feel free to make any necessary changes to this weekly lecture schedule."
            self.title = "Lectures"
        } else if (type == "Lab") {
             self.dictionary[0]![0].name = "Feel free to make any necessary changes to this weekly lab schedule."
            self.title = "Labs"
        } else if (type == "Tutorial") {
             self.dictionary[0]![0].name = "Feel free to make any necessary changes to this weekly tutorial schedule."
            self.title = "Tutorials"
        }
        
        for case let scrollView as UIScrollView in self.tableView.subviews {
            scrollView.delaysContentTouches = false
        }
        
        let realm = try! Realm()
        let coursePredicate = NSPredicate(format: "course = %@", self.course as CVarArg)
        let typePredicate = NSPredicate(format: "type = %@", self.type as CVarArg)
        
        //Ensure that the VC can get its correct repeatingSchedule.
        var repeatingSchedule = realm.objects(RLMRepeatingSchedule.self).filter(coursePredicate).filter("builtIn = true").filter(typePredicate).first
        realm.beginWrite()
        if (repeatingSchedule == nil) { //Incase somehow it was deleted, create a new one.
            repeatingSchedule = RLMRepeatingSchedule(schedule: "Weekly", type: self.type, course: self.course, location: nil)
            repeatingSchedule!.builtIn = true
            realm.add(repeatingSchedule!)
        }
        do {
            try realm.commitWrite()
        } catch let error {}
        self.repeatingSchedule = repeatingSchedule
        
        //Set up VC's schedule interface for any existing data.
        //let realm = try! Realm()
        //let coursePredicate = NSPredicate(format: "course = %@", self.course as CVarArg)
        //let typePredicate = NSPredicate(format: "type = %@", self.type as CVarArg)
        let dateTokens = self.repeatingSchedule.tokens
        if (dateTokens.count > 0) {
            self.dictionary[2]!.append(ScheduleRowContent(identifier: "WeeklyTimeCell", defaultToggleArray: [false, false, false, false, false], usesTimeArray: true))
            self.dictionary[2]!.append(ScheduleRowContent(identifier: "WeeklyEndTimeCell", defaultToggleArray: [false, false, false, false, false], usesTimeArray: true))
        }
        for (counter, _) in self.dictionary[2]![0].toggleArray!.enumerated() {
            if (counter == 0) {
                let mondayResult = dateTokens.filter("startDayOfWeek = 'Monday'")
                if (mondayResult.count > 0) {
                    self.dictionary[2]![0].toggleArray![0] = true
                    self.dictionary[2]![1].toggleArray![0] = true
                    self.dictionary[2]![1].timeArray![0] = mondayResult[0].startTime! as Date
                    self.dictionary[2]![2].toggleArray![0] = true
                    self.dictionary[2]![2].timeArray![0] = mondayResult[0].endTime! as Date
                    self.dictionary[1]![0].name = self.repeatingSchedule.location
                }
            } else if (counter == 1) {
                let tuesdayResult = dateTokens.filter("startDayOfWeek = 'Tuesday'")
                if (tuesdayResult.count > 0) {
                    self.dictionary[2]![0].toggleArray![1] = true
                    self.dictionary[2]![1].toggleArray![1] = true
                    self.dictionary[2]![1].timeArray![1] = tuesdayResult[0].startTime! as Date
                    self.dictionary[2]![2].toggleArray![1] = true
                    self.dictionary[2]![2].timeArray![1] = tuesdayResult[0].endTime! as Date
                    self.dictionary[1]![0].name = self.repeatingSchedule.location
                }
            } else if (counter == 2) {
                let wednesdayResult = dateTokens.filter("startDayOfWeek = 'Wednesday'")
                if (wednesdayResult.count > 0) {
                    self.dictionary[2]![0].toggleArray![2] = true
                    self.dictionary[2]![1].toggleArray![2] = true
                    self.dictionary[2]![1].timeArray![2] = wednesdayResult[0].startTime! as Date
                    self.dictionary[2]![2].toggleArray![2] = true
                    self.dictionary[2]![2].timeArray![2] = wednesdayResult[0].endTime! as Date
                    self.dictionary[1]![0].name = self.repeatingSchedule.location
                }
            } else if (counter == 3) {
                let thursdayResult = dateTokens.filter("startDayOfWeek = 'Thursday'")
                if (thursdayResult.count > 0) {
                    self.dictionary[2]![0].toggleArray![3] = true
                    self.dictionary[2]![1].toggleArray![3] = true
                    self.dictionary[2]![1].timeArray![3] = thursdayResult[0].startTime! as Date
                    self.dictionary[2]![2].toggleArray![3] = true
                    self.dictionary[2]![2].timeArray![3] = thursdayResult[0].endTime! as Date
                    self.dictionary[1]![0].name = self.repeatingSchedule.location
                }
            } else if (counter == 4) {
                let fridayResult = dateTokens.filter("startDayOfWeek = 'Friday'")
                if (fridayResult.count > 0) {
                    self.dictionary[2]![0].toggleArray![4] = true
                    self.dictionary[2]![1].toggleArray![4] = true
                    self.dictionary[2]![1].timeArray![4] = fridayResult[0].startTime! as Date
                    self.dictionary[2]![2].toggleArray![4] = true
                    self.dictionary[2]![2].timeArray![4] = fridayResult[0].endTime! as Date
                    self.dictionary[1]![0].name = self.repeatingSchedule.location
                }
            }
        }
        
        //Now we use the RLMRecurringEvents of self.type to fetch corresponding tasks (if any exist) that either occurred (dueDate) before the current date & time OR have a nil dueDate.
        let dueDateIsBeforeCurrentDateAndTime = NSPredicate(format: "dueDate <= %@", Date() as CVarArg)
        let tasksWithoutNullDueDatesUncompleted = realm.objects(RLMTask.self).filter(coursePredicate).filter(typePredicate).filter("removed = false AND dueDate != null").filter(dueDateIsBeforeCurrentDateAndTime).sorted(byKeyPath: "dueDate", ascending: false)
        let dueDateIsAfterCurrentDateAndTime = NSPredicate(format: "dueDate > %@", Date() as CVarArg)
        let tasksWithoutNullDueDatesCompleted = realm.objects(RLMTask.self).filter(coursePredicate).filter(typePredicate).filter("removed = false AND dueDate != null AND completed = true").filter(dueDateIsAfterCurrentDateAndTime).sorted(byKeyPath: "dueDate", ascending: false)
        let tasksWithNullDueDates = realm.objects(RLMTask.self).filter(coursePredicate).filter(typePredicate).filter("removed = false AND dueDate = null").sorted(byKeyPath: "dueDate", ascending: false)
        let tasks = tasksWithoutNullDueDatesCompleted.toArray() + tasksWithoutNullDueDatesUncompleted.toArray() + tasksWithNullDueDates.toArray()
        if (tasks.count > 0) {
            let taskScheduleRowContentArray = self.scheduleEditorVC.convertRLMTaskCollectionToScheduleRowContentArray(tasks: tasks)
            self.dictionary[4]!.removeAll()
            self.dictionary[4]!.insert(contentsOf: taskScheduleRowContentArray, at: 0)
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let selectedRowIndexPath = self.tableView.indexPathForSelectedRow
        if ((selectedRowIndexPath) != nil) {
            if let coordinator = transitionCoordinator {
                let animationBlock: (UIViewControllerTransitionCoordinatorContext!) -> () = { [weak self] _ in
                    self!.tableView.deselectRow(at: selectedRowIndexPath!, animated: true)
                }
                let completionBlock: (UIViewControllerTransitionCoordinatorContext!) -> () = { [weak self] context in
                    if context != nil && context!.isCancelled {
                        self!.tableView.selectRow(at: selectedRowIndexPath!, animated: true, scrollPosition: .none)
                    }
                }
                coordinator.animate(alongsideTransition: animationBlock, completion: completionBlock)
            }
            else {
                self.tableView.deselectRow(at: selectedRowIndexPath!, animated: true)
            }
        } else {
            if (lastSelectedRowIndexPath != nil) { //This code is specifically for when this class is a UITableViewController, since those do not call deselectRow(..) automatically when tapping back in navigation bar like a UITableView inside a UIViewController does.
                if let coordinator = transitionCoordinator {
                    let animationBlock: (UIViewControllerTransitionCoordinatorContext!) -> () = { [weak self] _ in
                        self!.tableView.deselectRow(at: self!.lastSelectedRowIndexPath!, animated: true)
                    }
                    let completionBlock: (UIViewControllerTransitionCoordinatorContext!) -> () = { [weak self] context in
                        if context != nil && context!.isCancelled {
                            self!.tableView.selectRow(at: self!.lastSelectedRowIndexPath!, animated: true, scrollPosition: .none)
                        }
                    }
                    coordinator.animate(alongsideTransition: animationBlock, completion: completionBlock)
                }
            }
        }
    }
    
    //**Solves the odd tableView scrollView offset bug that occurs when tableView.beginUpdates(..) and tableView.endUpdates(..) get called.**
    //http://stackoverflow.com/a/33397350/6051635
    
    var heightAtIndexPath = NSMutableDictionary()
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.heightAtIndexPath.object(forKey: indexPath)
        if ((height) != nil) {
            return CGFloat((height! as AnyObject).floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = cell.frame.size.height
        self.heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            cell.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
            if (cell.contentView.backgroundColor != UIColor.clear) {
                cell.backgroundColor = cell.contentView.backgroundColor
            }
        }
    }
    
    //**End of Bug Solution.**
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dictionary.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dictionary[section]!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellContent = dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row] as ScheduleRowContent
        let cell = tableView.dequeueReusableCell(withIdentifier: cellContent.identifier, for: indexPath)
        
        if (cellContent.identifier == "InstructionsCell") {
            let instructionsCell = cell as! InstructionsTableViewCell
            instructionsCell.instructionsLabel.text = cellContent.name
        }
        
        if (cellContent.identifier == "LocationCell") {
            let locationCell = cell as! LocationTableViewCell
            locationCell.textField.delegate = self
            locationCell.textField.text = cellContent.name
        }
        
        if (cellContent.identifier == "WeekdayCell") {
            let weekdayCell = cell as! WeekdayTableViewCell
            for (index, isCheckmarked) in cellContent.toggleArray!.enumerated() {
                if (isCheckmarked == true && index == 0) {
                    weekdayCell.mondayCheckmark.image = #imageLiteral(resourceName: "Green Checkmark")
                }
                if (isCheckmarked == true && index == 1) {
                    weekdayCell.tuesdayCheckmark.image = #imageLiteral(resourceName: "Green Checkmark")
                }
                if (isCheckmarked == true && index == 2) {
                    weekdayCell.wednesdayCheckmark.image = #imageLiteral(resourceName: "Green Checkmark")
                }
                if (isCheckmarked == true && index == 3) {
                    weekdayCell.thursdayCheckmark.image = #imageLiteral(resourceName: "Green Checkmark")
                }
                if (isCheckmarked == true && index == 4) {
                    weekdayCell.fridayCheckmark.image = #imageLiteral(resourceName: "Green Checkmark")
                }
            }
            
            return weekdayCell
        }
        
        if (cellContent.identifier == "WeeklyTimeCell") {
            let weeklyTimeCell = cell as! WeeklyTimeTableViewCell
            for (index, isShowing) in cellContent.toggleArray!.enumerated() {
                if (isShowing == true) {
                    weeklyTimeCell.arrayOfButtons[index].isHidden = false
                    weeklyTimeCell.arrayOfLabels[index].isHidden = false
                } else {
                    weeklyTimeCell.arrayOfButtons[index].isHidden = true
                    weeklyTimeCell.arrayOfLabels[index].isHidden = true
                }
            }
            
            for (index, time) in cellContent.timeArray!.enumerated() {
                if (time as Date == Date(timeIntervalSince1970: 0)) {
                    weeklyTimeCell.arrayOfButtons[index].titleLabel!.font = UIFont.systemFont(ofSize: 20)
                    weeklyTimeCell.arrayOfButtons[index].setTitle("Time", for: UIControlState())
                    weeklyTimeCell.arrayOfLabels[index].text = "Start"
                } else {
                    weeklyTimeCell.arrayOfButtons[index].titleLabel!.font = UIFont.systemFont(ofSize: 16)
                    weeklyTimeCell.arrayOfButtons[index].setTitle(DateFormatter.localizedString(from: time as Date, dateStyle: .none, timeStyle: .short), for: UIControlState())
                    weeklyTimeCell.arrayOfLabels[index].text = "at"
                }
            }
            
            return weeklyTimeCell
        }
        
        if (cellContent.identifier == "WeeklyEndTimeCell") {
            let weeklyEndTimeCell = cell as! WeeklyTimeTableViewCell
            for (index, isShowing) in cellContent.toggleArray!.enumerated() {
                if (isShowing == true) {
                    weeklyEndTimeCell.arrayOfButtons[index].isHidden = false
                    weeklyEndTimeCell.arrayOfLabels[index].isHidden = false
                } else {
                    weeklyEndTimeCell.arrayOfButtons[index].isHidden = true
                    weeklyEndTimeCell.arrayOfLabels[index].isHidden = true
                }
            }
            
            for (index, time) in cellContent.timeArray!.enumerated() {
                if (time as Date == Date(timeIntervalSince1970: 0)) {
                    weeklyEndTimeCell.arrayOfButtons[index].titleLabel!.font = UIFont.systemFont(ofSize: 20)
                    weeklyEndTimeCell.arrayOfButtons[index].setTitle("Time", for: UIControlState())
                    weeklyEndTimeCell.arrayOfLabels[index].text = "End"
                } else {
                    weeklyEndTimeCell.arrayOfButtons[index].titleLabel!.font = UIFont.systemFont(ofSize: 16)
                    weeklyEndTimeCell.arrayOfButtons[index].setTitle(DateFormatter.localizedString(from: time as Date, dateStyle: .none, timeStyle: .short), for: UIControlState())
                    weeklyEndTimeCell.arrayOfLabels[index].text = "until"
                }
            }
            
            return weeklyEndTimeCell
        }
        
        if (cellContent.identifier == "TimePickerCell") {
            let timePickerCell = cell as! TimePickerTableViewCell
            if (cellContent.date != Date(timeIntervalSince1970: 0)) {
                timePickerCell.timePicker.setDate(cellContent.date! as Date, animated: false)
            }
        }
        
        if (cellContent.identifier == "SectionCell") {
            let semesterCell = cell as! SectionTableViewCell
            if (cellContent.pickerTitleForRow == nil) {
                cellContent.pickerTitleForRow = PickerDataSource(source: .upTo20Sections).dataArray.first
            }
            semesterCell.rhsLabel.text = cellContent.pickerTitleForRow
            return semesterCell
        }
        
        if (cellContent.identifier == "PickerTableViewCell") {
            let pickerCell = cell as! PickerTableViewCell
            pickerCell.pickerView.indexPath = indexPath
            pickerCell.pickerView.dataSource = cellContent.pickerDataSource
            pickerCell.pickerView.delegate = self
            for (index, element) in (cellContent.pickerDataSource?.dataArray)!.enumerated() {
                if (element == cellContent.pickerTitleForRow) {
                    pickerCell.pickerView.selectRow(index, inComponent: 0, animated: false)
                }
            }
            if (cellContent.pickerTitleForRow == nil) {
                pickerCell.pickerView.selectRow(0, inComponent: 0, animated: false)
            }
            
            return pickerCell
        }
        
        if (cellContent.identifier == "UseCell") {
            let useCell = cell as! UseTableViewCell
            if (type == "Lecture") {
                useCell.useLabel.text = "Use Lecture"
            } else if (type == "Lab") {
                useCell.useLabel.text = "Use Lab"

            } else if (type == "Tutorial") {
                useCell.useLabel.text = "Use Tutorial"

            }
        }
        
        if (cellContent.identifier == "NoPastTypeCell") {
            let noPastTypeCell = cell as! NoPastTypeTableViewCell
            noPastTypeCell.typeImageView.image = UIImage(named:  self.type + "0")
            if (self.course.courseCode != nil) {
                noPastTypeCell.label.text = "No " + self.type + "s for " + self.course.courseCode! + " have occurred yet."
            } else {
                noPastTypeCell.label.text = "No " + self.type + "s for " + self.course.courseName + " have occurred yet!"
            }
        }
        
        if (cellContent.identifier == "HomeworkTableViewCell") {
            let cell = cell as! HomeworkTableViewCell
            let task = cellContent.task!
            cell.task = task
            cell.delegate = self
            
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
        
        return cell
    }
    
    /*override func deselectRow(at indexPath: IndexPath, animated: Bool) {
        let cell = self.cellForRow(at: indexPath) as? HomeworkTableViewCell
        if (animated == true) {
            cell?.cardView.backgroundColor = UIColor.white //use whichever view inside cell, in this case: cardView
        }
        super.deselectRow(at: indexPath, animated: animated)
    }*/
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0) //This color is also set in a method above and in B4GradTableView.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor.white
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row].identifier == "UseCell") {
            if (self.dictionary[2]!.count == 1) {
                //Delete all Date Tokens since the user has decided to use an empty schedule.
                let realm = try! Realm()
                let dateTokens = self.repeatingSchedule!.tokens
                realm.beginWrite()
                //Delete all existing Date Tokens.
                realm.delete(dateTokens)
                //Delete all of the old ones.
                //realm.delete(recurringSchoolEventsOfSameTypeAndCoure)
                do {
                    try realm.commitWrite()
                } catch let error {
                
                }
                self.navigationController!.popViewController(animated: true)
                return
            }
            if (self.dictionary[2]!.count == 2) {
                tableView.deselectRow(at: indexPath, animated: true)
                let alertViewController = UIAlertController(title: "Oops..",
                                                            message: "We cannot use an empty schedule.",
                                                            preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    alertViewController.dismiss(animated: true, completion: nil)
                })
                alertViewController.addAction(okButton)
                self.present(alertViewController, animated: true, completion: nil)
                return
            }
            for (buttonNumber, item) in self.dictionary[2]![0].toggleArray!.enumerated() {
                if (item == true) {
                    if (self.dictionary[2]![2].timeArray![buttonNumber] == Date(timeIntervalSince1970: 0)) {
                        tableView.deselectRow(at: indexPath, animated: true)
                        let alertViewController = UIAlertController(title: "Oops..",
                                                                    message: "We cannot accept this schedule, provide a start & end time for each day you have chosen. Thank you.",
                                                                    preferredStyle: .alert)
                        let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                            alertViewController.dismiss(animated: true, completion: nil)
                        })
                        alertViewController.addAction(okButton)
                        self.present(alertViewController, animated: true, completion: nil)
                        return
                    }
                }
            }
            for (buttonNumber, item) in self.dictionary[2]![1].timeArray!.enumerated() {
                let correspondingItem = self.dictionary[2]![2].timeArray![buttonNumber]
                if (item == correspondingItem && self.dictionary[2]![1].toggleArray![buttonNumber] == true && self.dictionary[2]![2].toggleArray![buttonNumber] == true) {
                    tableView.deselectRow(at: indexPath, animated: true)
                    let alertViewController = UIAlertController(title: "Oops..",
                                                                message: "Your " + self.type + "s cannot start at identical times on the same day..unless you can can be in two places at once!",
                                                                preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        alertViewController.dismiss(animated: true, completion: nil)
                    })
                    alertViewController.addAction(okButton)
                    self.present(alertViewController, animated: true, completion: nil)
                    return
                }
            }
            for (buttonNumber, item) in self.dictionary[2]![1].timeArray!.enumerated() {
                let correspondingItem = self.dictionary[2]![2].timeArray![buttonNumber]
                if (item.time == correspondingItem.time && self.dictionary[2]![1].toggleArray![buttonNumber] == true && self.dictionary[2]![2].toggleArray![buttonNumber] == true) {
                    tableView.deselectRow(at: indexPath, animated: true)
                    let alertViewController = UIAlertController(title: "Oops..",
                                                                message: "Your " + self.type + "s cannot start at identical times on the same day..unless you can can be in two places at once!",
                                                                preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                        alertViewController.dismiss(animated: true, completion: nil)
                    })
                    alertViewController.addAction(okButton)
                    self.present(alertViewController, animated: true, completion: nil)
                    return
                }
            }
            
            //Check to ensure startTime isn't before endTime.
            for (buttonNumber, item) in self.dictionary[2]![0].toggleArray!.enumerated() {
                if (item == true) {
                    let startTime = self.dictionary[2]![1].timeArray![buttonNumber]
                    let endTime = self.dictionary[2]![2].timeArray![buttonNumber]
                    var startDayOfWeek = DayOfWeek.init(id: 0)
                    if (buttonNumber == 0) {
                        startDayOfWeek = DayOfWeek.monday
                    } else if (buttonNumber == 1) {
                        startDayOfWeek = DayOfWeek.tuesday
                    } else if (buttonNumber == 2) {
                        startDayOfWeek = DayOfWeek.wednesday
                    } else if (buttonNumber == 3) {
                        startDayOfWeek = DayOfWeek.thursday
                    } else if (buttonNumber == 4) {
                        startDayOfWeek = DayOfWeek.friday
                    }
                    //IMPORTANT: Compare Time objects, NOT DATES. So comparing timeIntervals of a Date object is inaccurate.
                    
                    /*if (startTime.time >= endTime.time) {
                        tableView.deselectRow(at: indexPath, animated: true)
                        let alertViewController = UIAlertController(title: "Oops..",
                                                                    message: "Your " + self.type + "s cannot have start times earlier or equal to their end times.",
                                                                    preferredStyle: .alert)
                        let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                            alertViewController.dismiss(animated: true, completion: nil)
                        })
                        alertViewController.addAction(okButton)
                        self.present(alertViewController, animated: true, completion: nil)
                        return
                    }*/
                    
                    ///
                    if (startTime.time == endTime.time) {
                        tableView.deselectRow(at: indexPath, animated: true)
                        let alertViewController = UIAlertController(title: "Oops..",
                                                                    message: "Your " + self.type + "s cannot have start times equal to their end times.",
                                                                    preferredStyle: .alert)
                        let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                            alertViewController.dismiss(animated: true, completion: nil)
                        })
                        alertViewController.addAction(okButton)
                        self.present(alertViewController, animated: true, completion: nil)
                        return
                    }
                    
                    if (startTime.time > endTime.time) {
                        //The RLMRecurringSchoolEvent ends on the following day...so let execution continue.
                        //This if statement helps state this logic clearly.
                        
                        
                    }
                    ///
                }
            }
            
            var dateTokensToSave = [RLMDateToken]()
            for (buttonNumber, item) in self.dictionary[2]![0].toggleArray!.enumerated() {
                if (item == true) {
                    let startTime = self.dictionary[2]![1].timeArray![buttonNumber]
                    var endTime = self.dictionary[2]![2].timeArray![buttonNumber]
                    var startDayOfWeek = DayOfWeek.init(id: 0)
                    //if (startTime.time > endTime.time) {
                        //The RLMRecurringSchoolEvent ends on the following day...(instead of the same day)
                    //    let newEndTime = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: endTime, wrappingComponents: false)!
                    //    endTime = newEndTime
                    //}
                    if (buttonNumber == 0) {
                        startDayOfWeek = DayOfWeek.monday
                    } else if (buttonNumber == 1) {
                        startDayOfWeek = DayOfWeek.tuesday
                    } else if (buttonNumber == 2) {
                        startDayOfWeek = DayOfWeek.wednesday
                    } else if (buttonNumber == 3) {
                        startDayOfWeek = DayOfWeek.thursday
                    } else if (buttonNumber == 4) {
                        startDayOfWeek = DayOfWeek.friday
                    }
                    let dateToken = RLMDateToken(startTime: startTime as NSDate, startDayOfWeek: startDayOfWeek!.rawValue, endTime: endTime as? NSDate)
                    dateTokensToSave.append(dateToken)
                }
                
            }
            
            let realm = try! Realm()
            let coursePredicate = NSPredicate(format: "course = %@", self.course as CVarArg)
            let typePredicate = NSPredicate(format: "type = %@", self.type as CVarArg)
            //let repeatingSchedule = realm.objects(RLMRepeatingSchedule.self).filter(coursePredicate).filter(typePredicate).first!
            let dateTokensForSchedule = self.repeatingSchedule.tokens
            
            
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: calendar.date(byAdding: .day, value: 1, to: Date())!)
            components.hour = 0
            components.minute = 0
            components.second = 0
            let earliestTimeTomorrow = calendar.date(from: components)! //Earliest possible time for tomorrow's day.
            let dueDateIsAfterToday = NSPredicate(format: "dueDate >= %@", earliestTimeTomorrow as CVarArg)
            var tasksToDelete = realm.objects(RLMTask.self).filter(coursePredicate).filter(typePredicate).filter("completed = false AND removed = false").filter(dueDateIsAfterToday).toArray()
            
            //let hasDefaultNameRegexPattern = "((Assignment)|(Quiz)|(Midterm)|(Final)|(Lecture)|(Lab)|(Tutorial)) [0123456789]*"
            //let regex = try! NSRegularExpression(pattern: hasDefaultNameRegexPattern, options: [])
            for task in tasksToDelete {
                //let matches = regex.matches(in: task.name, options: [], range: NSRange(location: 0, length: task.name.characters.count))
                //if (matches >= 1) {
                //    tasksToDelete.drop(while: hasDefaultNameRegexPattern)
                //}
                print(task.id + " " + task.name + " is a " + task.type + " for the course " + task.course!.courseName + ".")
            }
            
            
            let tuple = self.createInitialTasksForSavedDateTokensIfNeeded(dateTokens: &dateTokensToSave, tasksToDelete: &tasksToDelete, calendar: calendar)
            let tasksToSave = tuple.0
            //let lastTaskCreatedDueDate = tuple.2
            realm.beginWrite()
            //Delete all tasks due after the current day that are associated with the current recurringSchoolEvents that do not have a custom title or other custom modification like notes attached to it.
            realm.delete(tasksToDelete)
            //Delete all of the old DateTokens.
            realm.delete(dateTokensForSchedule)
            //Save lectures/labs/tutorials.
            self.repeatingSchedule.tokens.append(objectsIn: dateTokensToSave)
            //realm.add(dateTokensToSave)
            //Save newly created tasks (if any).
            realm.add(tasksToSave)
            //Save Repeating Schedule since it was updated.
            //self.repeatingSchedule.lastTaskCreatedDueDate = lastTaskCreatedDueDate
            realm.add(self.repeatingSchedule) //DateTokens are saved on this line since they are in the tokens list for repeatingSchedule.
            do {
                try realm.commitWrite()
            } catch let error {
                
            }
            //Update HWVC's UITableView just before popping this VC.
            self.scheduleEditorVC.homeVC.tableView.reloadSections([0], with: .automatic)
            self.navigationController!.popViewController(animated: true)
            return
        }
        
        if (self.dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row].identifier == "SectionCell") {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.endEditing(false)
            if (self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row + 1].identifier != "PickerTableViewCell") {
                tableView.beginUpdates()
                //Remove any existing pickerViewCells.
                for (index, rowContent) in (self.dictionary[(indexPath as NSIndexPath).section]?.enumerated())! {
                    if (rowContent.identifier == "PickerTableViewCell") {
                        self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: index)
                        tableView.deleteRows(at: [IndexPath(row: index, section: (indexPath as NSIndexPath).section)], with: .top)
                    }
                }
                //Add New pickerViewCell.
                let cellContent = ScheduleRowContent(identifier: "PickerTableViewCell")
                //Determine semester type based on University/Course information.
                cellContent.pickerDataSource = PickerDataSource(source: .upTo20Sections)
                cellContent.pickerTitleForRow = self.dictionary[(indexPath as NSIndexPath).section]?[(indexPath as NSIndexPath).row].pickerTitleForRow
                self.dictionary[(indexPath as NSIndexPath).section]?.insert(cellContent, at: (self.dictionary[(indexPath as NSIndexPath).section]!.count - 1))
                tableView.insertRows(at: [IndexPath(row: 1, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[(indexPath as NSIndexPath).section]?.remove(at: self.dictionary[(indexPath as NSIndexPath).section]!.count - 2)
                tableView.deleteRows(at: [IndexPath(row: 1, section: (indexPath as NSIndexPath).section)], with: .top)
                tableView.endUpdates()
            }
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        if (cell is HomeworkTableViewCell) {
            let hwCell = cell as! HomeworkTableViewCell
            hwCell.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
            self.lastSelectedRowIndexPath = indexPath
            //print(self.tableView.indexPathsForSelectedRows!.description)
        }
        
        if (self.dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row].identifier == "HomeworkTableViewCell") {
            let scheduleRowContent = self.dictionary[indexPath.section]![indexPath.row]
            let task = scheduleRowContent.task!
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cellEditingVC = storyboard.instantiateViewController(withIdentifier: "CellEditingVC") as! CellEditingTableViewController
            cellEditingVC.helperObject = WeeklyCellEditingHelperObject(cellEditingTVC: cellEditingVC, task: task, taskManagerVC: self, homeVC: self.homeVC)
            cellEditingVC.helperObject.mode = .Edit
            cellEditingVC.helperObject.dictionary[0]![0].name = task.name
            cellEditingVC.title = task.name
            cellEditingVC.helperObject.task = task
            cellEditingVC.helperObject.taskManagerVC = self
            self.show(cellEditingVC, sender: nil)
            return
        }
        
    }
    
    /* This is a complex algorithm that executes upon Date Tokens being saved. It returns a tuple containing (1) an array of tasks to save and (2) an RLMRepeatingSchedule. */
    func createInitialTasksForSavedDateTokensIfNeeded(dateTokens: inout [RLMDateToken], tasksToDelete: inout [RLMTask], calendar: Calendar) -> ([RLMTask], RLMRepeatingSchedule) {
        let realm = try! Realm()
        var tasksToBeSaved = [RLMTask]()
        //var lastTaskCreatedDueDate = self.repeatingSchedule.lastTaskCreatedDueDate
        for dateToken in dateTokens {
            let createdAtOfRLMDateToken = dateToken.createdDate
            //var createdAtDateComponents = calendar.dateComponents([.year, .month, .weekOfYear, .weekday, .hour, .minute], from: createdAtOfRLMDateToken as Date)

            //var lastTaskCreatedDueDate = dateToken.lastTaskCreatedDueDate
            
            //Get the date of the soonest targetDayOfWeek following the createdAt date of the RLMDateToken, since that should be the date and time of the first task for this RLMRepeatingSchedule.
            let targetDayOfWeek = DayOfWeek(rawValue: dateToken.startDayOfWeek)!.rawValue
            let newDate = self.findNext(targetDayOfWeek, afterDate: createdAtOfRLMDateToken as Date)! //will get date of next targetDayOfWeek including TODAY. (So if today is already targetDayOfWeek, it will today's date)
            
            let cal = Calendar(identifier: .gregorian) //Always use a new calendar object instead of reusing an existing one.
            var createdAtDateComponents = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
            
            createdAtDateComponents.hour = (dateToken.startTime! as Date).time.hour
            createdAtDateComponents.minute = (dateToken.startTime! as Date).time.minute
            createdAtDateComponents.second = 0
            var followingTargetDay = cal.date(from: createdAtDateComponents)
            
            //Since followingTargetDay could be today, we check if the event already happened earlier today. If it did then we must increment newDate to be the next possible date (AKA one week from today).
            let isPast = followingTargetDay!.isPast()
            let isToday = Calendar.current.isDateInToday(followingTargetDay!)
            if (isPast == true && isToday == true) {
                followingTargetDay = calendar.date(byAdding: .day, value: 7, to: followingTargetDay!, wrappingComponents: false)!
                createdAtDateComponents = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: followingTargetDay!)
            }
            
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .full
            print(formatter.string(from: followingTargetDay!))
            
            var endDateAndTime : Date!
            if (dateToken.endTime! != nil) {
                createdAtDateComponents.hour = (dateToken.endTime! as Date).time.hour
                createdAtDateComponents.minute = (dateToken.endTime! as Date).time.minute
                endDateAndTime = calendar.date(from: createdAtDateComponents)!
                if ((dateToken.startTime as Date).time > (dateToken.endTime! as Date).time) {
                    //The date token ends on the following day...(instead of the same day)
                    endDateAndTime = calendar.date(byAdding: .day, value: 1, to: endDateAndTime!, wrappingComponents: false)
                }
                print(formatter.string(from: endDateAndTime!))
            }
            
            if (dateToken.lastTaskCreatedDueDate == nil) {
                dateToken.lastTaskCreatedDueDate = followingTargetDay! as NSDate
                
            } else if (followingTargetDay!.timeIntervalSinceReferenceDate > dateToken.lastTaskCreatedDueDate!.timeIntervalSinceReferenceDate) {
                dateToken.lastTaskCreatedDueDate = followingTargetDay! as NSDate
            }
            
            //if the followingTargetDay date is now or in the future, create the task.
            
            //let isWithinSameDayOfCurrentDate = Calendar.current.isDateInToday(followingTargetDay!)
            
            
            
                //let tasksOfSameTypeAndSameCourse = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@", recurringSchoolEvent.type, recurringSchoolEvent.course!, recurringSchoolEvent.createdDate).sorted(byKeyPath: "createdDate", ascending: false)
                //All RLMRecurringEvents get recreated (deleted & created new again) when the user exits WeeklyEditingVC. WeeklyEditingVC also handles deleting tasks due in the future for these RLMRecurringEvents EXCEPT for ones due the same day! (To ensure if the user already modified it with a custom title, etc, it doesn't get deleted.) Therefore, a bug can occur that causes any newly recreated RLMRecurringEvent to create an already existing task since it doesn't realize an old one exists for the current day. This bug occurs when an RLMRecurringEvent is recreated on the day of the week it is supposed to create a task. Below code fixes this bug, although alternatively this algorithm could be moved to WeeklyEditingVC, remove the bit of code below, and then ensure that the WeeklyEditingVC actually deletes even those tasks that are due today. Or we could just move this algo to WeeklyEditingVC, keep the bit of code below, and not modify the deletion algo (preferred).
                if (realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND dueDate = %@ AND endDateAndTime = %@ AND removed = false", self.repeatingSchedule.type, self.repeatingSchedule.course!, followingTargetDay!, endDateAndTime!).sorted(byKeyPath: "createdDate", ascending: false).first != nil) {
                    if let duplicateTask = tasksToDelete.first(where: { $0.dueDate?.timeIntervalSinceReferenceDate == followingTargetDay!.timeIntervalSinceReferenceDate && $0.endDateAndTime?.timeIntervalSinceReferenceDate == endDateAndTime!.timeIntervalSinceReferenceDate }) {
                        tasksToDelete.removeObject(object: duplicateTask)
                    }
                    //Don't create new duplicate task incase this RLMRepeatingSchedule was simply a recreated version of an old one.
                } else {
                    //create task
                    let task = RLMTask(name: self.repeatingSchedule.type + " ", type: self.repeatingSchedule.type, dueDate: followingTargetDay! as NSDate, course: self.repeatingSchedule.course!)
                    task.endDateAndTime = endDateAndTime as NSDate?
                    task.timeSet = true
                    task.originalDueDate = followingTargetDay! as NSDate
                    task.repeatingSchedule = self.repeatingSchedule
                    tasksToBeSaved.append(task)
                    /*if (dateToken.lastTaskCreatedDueDate == nil) {
                        dateToken.lastTaskCreatedDueDate = followingTargetDay! as NSDate
                        
                    } else if (followingTargetDay!.timeIntervalSinceReferenceDate > dateToken.lastTaskCreatedDueDate!.timeIntervalSinceReferenceDate) {
                        dateToken.lastTaskCreatedDueDate = followingTargetDay! as NSDate
                    }*/
                }
            ///}
        }
        if (tasksToBeSaved.count > 0) {
            let tasksOfSameTypeAndSameCourse = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@ AND removed = false", tasksToBeSaved.first!.type, tasksToBeSaved.first!.course!, Date()).sorted(byKeyPath: "createdDate", ascending: false)
            for (index, task) in tasksToBeSaved.sorted(by: { $0.dueDate!.timeIntervalSinceReferenceDate < $1.dueDate!.timeIntervalSinceReferenceDate }).enumerated() {
                task.name = task.name + String(tasksOfSameTypeAndSameCourse.count + index + 1)
                task.createdDate = task.createdDate.addingTimeInterval(Double(index)) //So the placeholder names are correct.
            }
        }
        
        return (tasksToBeSaved, self.repeatingSchedule)
    }
        
    func findNext(_ day: String, afterDate date: Date) -> Date? {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let weekDaySymbols = calendar.weekdaySymbols
        let indexOfDay = weekDaySymbols.index(of: day)
        let weekDay = indexOfDay! + 1
        let components = calendar.component(.weekday, from: date)
        if components == weekDay {
            return date
        }
        var matchingComponents = DateComponents()
        matchingComponents.weekday = weekDay // Monday
        let nextDay = calendar.nextDate(after: date,
                                            matching: matchingComponents,
                                            matchingPolicy:.nextTime)
        return nextDay!
    }
        
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        if (section == 1) {
            let headerView = SectionHeaderView.construct("General", owner: tableView)
            return headerView
        }
        
        if (section == 2) {
            let headerView = SectionHeaderView.construct("Weekly Schedule", owner: tableView)
            return headerView
        }
        
        if (section == 4) {
            let headerView = SectionHeaderView.construct("Past " + self.type + "s", owner: tableView)
            return headerView
        }
        
        let invisView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        invisView.backgroundColor = UIColor.clear
        return invisView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return CGFloat.leastNormalMagnitude
        } else {
            return 21.0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let point = self.tableView.convert(CGPoint.zero, from: textField)
        let indexPath = self.tableView.indexPathForRow(at: point)
        if (textField.text != "") {
            self.dictionary[((indexPath! as NSIndexPath).section)]![(indexPath! as NSIndexPath).row].name = textField.text
        } else {
            self.dictionary[((indexPath! as NSIndexPath).section)]![(indexPath! as NSIndexPath).row].name = nil
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let point = self.tableView.convert(CGPoint.zero, from: textField)
        let indexPath = self.tableView.indexPathForRow(at: point)
        if (textField.text != "") {
            self.dictionary[((indexPath! as NSIndexPath).section)]![(indexPath! as NSIndexPath).row].name = textField.text
        } else {
            self.dictionary[((indexPath! as NSIndexPath).section)]![(indexPath! as NSIndexPath).row].name = nil
        }
        self.dictionary[((indexPath! as NSIndexPath).section)]![(indexPath! as NSIndexPath).row].name = textField.text
        
        let identifier = self.dictionary[((indexPath! as NSIndexPath).section)]![(indexPath! as NSIndexPath).row].identifier
        if (identifier == "LocationCell") {
            textField.resignFirstResponder()
            let realm = try! Realm()
            realm.beginWrite()
            self.repeatingSchedule.location = textField.text!
            do {
                try realm.commitWrite()
            } catch let error {
                
            }
        }
    }
    
    //WeekdayTableViewCell Events
    
    @IBAction func mondayTapped(_ sender: AnyObject) {
        let button = sender as! UIButton
        let cell = button.superview?.superview as! WeekdayTableViewCell
        let section = 2
        self.dictionary[section]![0].toggleArray![0] = !self.dictionary[section]![0].toggleArray![0]
        if (self.dictionary[section]![0].toggleArray![0] == true) {
            cell.mondayCheckmark.image = UIImage(named: "Green Checkmark")
        } else {
            cell.mondayCheckmark.image = UIImage(named: "Red X")
        }
        
        if (self.dictionary[section]!.indices.contains(1) == false) { //If no WeeklyTimeCell exists.
            tableView.beginUpdates()
            let newWeeklyTimeRow = ScheduleRowContent(identifier: "WeeklyTimeCell", defaultToggleArray: [true, false, false, false, false], usesTimeArray: true)
            self.dictionary[section]!.insert(newWeeklyTimeRow, at: 1)
            tableView.insertRows(at: [IndexPath(row: 1, section: section)], with: .top)
            tableView.endUpdates()
        } else {
            let weeklyTimeCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as! WeeklyTimeTableViewCell
            weeklyTimeCell.mondayAtLabel.isHidden = !weeklyTimeCell.mondayAtLabel.isHidden
            weeklyTimeCell.mondayTimeButton.isHidden = !weeklyTimeCell.mondayTimeButton.isHidden
            self.dictionary[section]![1].toggleArray![0] = !self.dictionary[section]![1].toggleArray![0]
            self.dictionary[section]![1].timeArray![0] = Date(timeIntervalSince1970: 0)
            weeklyTimeCell.arrayOfButtons[0].setTitle("Time", for: .normal)
            weeklyTimeCell.mondayAtLabel.text = "Start"
            if let weeklyEndTimeCell = tableView.cellForRow(at: IndexPath(row: 2, section: section)) as? WeeklyTimeTableViewCell {
                if (self.dictionary[section]![1].timeArray![0] == Date(timeIntervalSince1970: 0)) {
                    self.dictionary[section]![2].toggleArray![0] = false
                    weeklyEndTimeCell.mondayAtLabel.isHidden = true
                    weeklyEndTimeCell.mondayTimeButton.isHidden = true
                } else {
                    self.dictionary[section]![2].toggleArray![0] = true
                    weeklyEndTimeCell.mondayAtLabel.isHidden = false
                    weeklyEndTimeCell.mondayTimeButton.isHidden = false
                }
                self.dictionary[section]![2].timeArray![0] = Date(timeIntervalSince1970: 0)
                weeklyEndTimeCell.arrayOfButtons[0].setTitle("Time", for: .normal)
                weeklyEndTimeCell.mondayAtLabel.text = "End"
            }
            
            //Close WeeklyEndTimeCell when no row 2 toggles are set to true.
            var indexPaths = [IndexPath]()
            tableView.beginUpdates()
            if (removeWeeklyEndTimeCell()) {
                self.dictionary[section]!.remove(at: 2)
                indexPaths.append(IndexPath(row: 2, section: section))
            }
            if (removeWeeklyTimeCell()) {
                self.dictionary[section]!.remove(at: 1)
                indexPaths.append(IndexPath(row: 1, section: section))
            }
            if (indexPaths.count != 0) {
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            tableView.endUpdates()
        }
        
    }
    
    @IBAction func tuesdayTapped(_ sender: AnyObject) {
        let button = sender as! UIButton
        let cell = button.superview?.superview as! WeekdayTableViewCell
        let section = 2
        self.dictionary[section]![0].toggleArray![1] = !self.dictionary[section]![0].toggleArray![1]
        if (self.dictionary[section]![0].toggleArray![1] == true) {
            cell.tuesdayCheckmark.image = UIImage(named: "Green Checkmark")
        } else {
            cell.tuesdayCheckmark.image = UIImage(named: "Red X")
        }
        
        if (self.dictionary[section]!.indices.contains(1) == false) { //If no WeeklyTimeCell exists.
            tableView.beginUpdates()
            let newWeeklyTimeRow = ScheduleRowContent(identifier: "WeeklyTimeCell", defaultToggleArray: [false, true, false, false, false], usesTimeArray: true)
            self.dictionary[section]!.insert(newWeeklyTimeRow, at: 1)
            tableView.insertRows(at: [IndexPath(row: 1, section: section)], with: .top)
            tableView.endUpdates()
        } else {
            let weeklyTimeCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as! WeeklyTimeTableViewCell
            weeklyTimeCell.tuesdayAtLabel.isHidden = !weeklyTimeCell.tuesdayAtLabel.isHidden
            weeklyTimeCell.tuesdayTimeButton.isHidden = !weeklyTimeCell.tuesdayTimeButton.isHidden
            self.dictionary[section]![1].toggleArray![1] = !self.dictionary[section]![1].toggleArray![1]
            self.dictionary[section]![1].timeArray![1] = Date(timeIntervalSince1970: 0)
            weeklyTimeCell.arrayOfButtons[1].setTitle("Time", for: .normal)
            weeklyTimeCell.tuesdayAtLabel.text = "Start"
            if let weeklyEndTimeCell = tableView.cellForRow(at: IndexPath(row: 2, section: section)) as? WeeklyTimeTableViewCell {
                if (self.dictionary[section]![1].timeArray![1] == Date(timeIntervalSince1970: 0)) {
                    self.dictionary[section]![2].toggleArray![1] = false
                    weeklyEndTimeCell.tuesdayAtLabel.isHidden = true
                    weeklyEndTimeCell.tuesdayTimeButton.isHidden = true
                } else {
                    self.dictionary[section]![2].toggleArray![1] = true
                    weeklyEndTimeCell.tuesdayAtLabel.isHidden = false
                    weeklyEndTimeCell.tuesdayTimeButton.isHidden = false
                }
                self.dictionary[section]![2].timeArray![1] = Date(timeIntervalSince1970: 0)
                weeklyEndTimeCell.arrayOfButtons[1].setTitle("Time", for: .normal)
                weeklyEndTimeCell.tuesdayAtLabel.text = "End"
            }
            //Close WeeklyEndTimeCell when no row 2 toggles are set to true.
            var indexPaths = [IndexPath]()
            tableView.beginUpdates()
            if (removeWeeklyEndTimeCell()) {
                self.dictionary[section]!.remove(at: 2)
                indexPaths.append(IndexPath(row: 2, section: section))
            }
            if (removeWeeklyTimeCell()) {
                self.dictionary[section]!.remove(at: 1)
                indexPaths.append(IndexPath(row: 1, section: section))
            }
            if (indexPaths.count != 0) {
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            tableView.endUpdates()
        }
    }
    
    @IBAction func wednesdayTapped(_ sender: AnyObject) {
        let button = sender as! UIButton
        let cell = button.superview?.superview as! WeekdayTableViewCell
        let section = 2
        self.dictionary[section]![0].toggleArray![2] = !self.dictionary[section]![0].toggleArray![2]
        if (self.dictionary[section]![0].toggleArray![2] == true) {
            cell.wednesdayCheckmark.image = UIImage(named: "Green Checkmark")
        } else {
            cell.wednesdayCheckmark.image = UIImage(named: "Red X")
        }
        
        if (self.dictionary[section]!.indices.contains(1) == false) { //If no WeeklyTimeCell exists.
            tableView.beginUpdates()
            let newWeeklyTimeRow = ScheduleRowContent(identifier: "WeeklyTimeCell", defaultToggleArray: [false, false, true, false, false], usesTimeArray: true)
            self.dictionary[section]!.insert(newWeeklyTimeRow, at: 1)
            tableView.insertRows(at: [IndexPath(row: 1, section: section)], with: .top)
            tableView.endUpdates()
        } else {
            let weeklyTimeCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as! WeeklyTimeTableViewCell
            weeklyTimeCell.wednesdayAtLabel.isHidden = !weeklyTimeCell.wednesdayAtLabel.isHidden
            weeklyTimeCell.wednesdayTimeButton.isHidden = !weeklyTimeCell.wednesdayTimeButton.isHidden
            self.dictionary[section]![1].toggleArray![2] = !self.dictionary[section]![1].toggleArray![2]
            self.dictionary[section]![1].timeArray![2] = Date(timeIntervalSince1970: 0)
            weeklyTimeCell.arrayOfButtons[2].setTitle("Time", for: .normal)
            weeklyTimeCell.wednesdayAtLabel.text = "Start"
            if let weeklyEndTimeCell = tableView.cellForRow(at: IndexPath(row: 2, section: section)) as? WeeklyTimeTableViewCell {
                if (self.dictionary[section]![1].timeArray![2] == Date(timeIntervalSince1970: 0)) {
                    self.dictionary[section]![2].toggleArray![2] = false
                    weeklyEndTimeCell.wednesdayAtLabel.isHidden = true
                    weeklyEndTimeCell.wednesdayTimeButton.isHidden = true
                } else {
                    self.dictionary[section]![2].toggleArray![2] = true
                    weeklyEndTimeCell.wednesdayAtLabel.isHidden = false
                    weeklyEndTimeCell.wednesdayTimeButton.isHidden = false
                }
                self.dictionary[section]![2].timeArray![2] = Date(timeIntervalSince1970: 0)
                weeklyEndTimeCell.arrayOfButtons[2].setTitle("Time", for: .normal)
                weeklyEndTimeCell.wednesdayAtLabel.text = "End"
            }
            //Close WeeklyEndTimeCell when no row 2 toggles are set to true.
            var indexPaths = [IndexPath]()
            tableView.beginUpdates()
            if (removeWeeklyEndTimeCell()) {
                self.dictionary[section]!.remove(at: 2)
                indexPaths.append(IndexPath(row: 2, section: section))
            }
            if (removeWeeklyTimeCell()) {
                self.dictionary[section]!.remove(at: 1)
                indexPaths.append(IndexPath(row: 1, section: section))
            }
            if (indexPaths.count != 0) {
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            tableView.endUpdates()
        }
    }
    
    @IBAction func thursdayTapped(_ sender: AnyObject) {
        let button = sender as! UIButton
        let cell = button.superview?.superview as! WeekdayTableViewCell
        let section = 2
        self.dictionary[section]![0].toggleArray![3] = !self.dictionary[section]![0].toggleArray![3]
        if (self.dictionary[section]![0].toggleArray![3] == true) {
            cell.thursdayCheckmark.image = UIImage(named: "Green Checkmark")
        } else {
            cell.thursdayCheckmark.image = UIImage(named: "Red X")
        }
        
        if (self.dictionary[section]!.indices.contains(1) == false) { //If no WeeklyTimeCell exists.
            tableView.beginUpdates()
            let newWeeklyTimeRow = ScheduleRowContent(identifier: "WeeklyTimeCell", defaultToggleArray: [false, false, false, true, false], usesTimeArray: true)
            self.dictionary[section]!.insert(newWeeklyTimeRow, at: 1)
            tableView.insertRows(at: [IndexPath(row: 1, section: section)], with: .top)
            tableView.endUpdates()
        } else {
            let weeklyTimeCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as! WeeklyTimeTableViewCell
            weeklyTimeCell.thursdayAtLabel.isHidden = !weeklyTimeCell.thursdayAtLabel.isHidden
            weeklyTimeCell.thursdayTimeButton.isHidden = !weeklyTimeCell.thursdayTimeButton.isHidden
            self.dictionary[section]![1].toggleArray![3] = !self.dictionary[section]![1].toggleArray![3]
            self.dictionary[section]![1].timeArray![3] = Date(timeIntervalSince1970: 0)
            weeklyTimeCell.arrayOfButtons[3].setTitle("Time", for: .normal)
            weeklyTimeCell.thursdayAtLabel.text = "Start"
            if let weeklyEndTimeCell = tableView.cellForRow(at: IndexPath(row: 2, section: section)) as? WeeklyTimeTableViewCell {
                if (self.dictionary[section]![1].timeArray![3] == Date(timeIntervalSince1970: 0)) {
                    self.dictionary[section]![2].toggleArray![3] = false
                    weeklyEndTimeCell.thursdayAtLabel.isHidden = true
                    weeklyEndTimeCell.thursdayTimeButton.isHidden = true
                } else {
                    self.dictionary[section]![2].toggleArray![3] = true
                    weeklyEndTimeCell.thursdayAtLabel.isHidden = false
                    weeklyEndTimeCell.thursdayTimeButton.isHidden = false
                }
                self.dictionary[section]![2].timeArray![3] = Date(timeIntervalSince1970: 0)
                weeklyEndTimeCell.arrayOfButtons[3].setTitle("Time", for: .normal)
                weeklyEndTimeCell.thursdayAtLabel.text = "End"
            }
            //Close WeeklyEndTimeCell when no row 2 toggles are set to true.
            var indexPaths = [IndexPath]()
            tableView.beginUpdates()
            if (removeWeeklyEndTimeCell()) {
                self.dictionary[section]!.remove(at: 2)
                indexPaths.append(IndexPath(row: 2, section: section))
            }
            if (removeWeeklyTimeCell()) {
                self.dictionary[section]!.remove(at: 1)
                indexPaths.append(IndexPath(row: 1, section: section))
            }
            if (indexPaths.count != 0) {
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            tableView.endUpdates()
        }
    }
    
    @IBAction func fridayTapped(_ sender: AnyObject) {
        let button = sender as! UIButton
        let cell = button.superview?.superview as! WeekdayTableViewCell
        let section = 2
        self.dictionary[section]![0].toggleArray![4] = !self.dictionary[section]![0].toggleArray![4]
        if (self.dictionary[section]![0].toggleArray![4] == true) {
            cell.fridayCheckmark.image = UIImage(named: "Green Checkmark")
        } else {
            cell.fridayCheckmark.image = UIImage(named: "Red X")
        }
        
        if (self.dictionary[section]!.indices.contains(1) == false) { //If no WeeklyTimeCell exists.
            tableView.beginUpdates()
            let newWeeklyTimeRow = ScheduleRowContent(identifier: "WeeklyTimeCell", defaultToggleArray: [false, false, false, false, true], usesTimeArray: true)
            self.dictionary[section]!.insert(newWeeklyTimeRow, at: 1)
            tableView.insertRows(at: [IndexPath(row: 1, section: section)], with: .top)
            tableView.endUpdates()
        } else {
            let weeklyTimeCell = tableView.cellForRow(at: IndexPath(row: 1, section: section)) as! WeeklyTimeTableViewCell
            weeklyTimeCell.fridayAtLabel.isHidden = !weeklyTimeCell.fridayAtLabel.isHidden
            weeklyTimeCell.fridayTimeButton.isHidden = !weeklyTimeCell.fridayTimeButton.isHidden
            self.dictionary[section]![1].toggleArray![4] = !self.dictionary[section]![1].toggleArray![4]
            self.dictionary[section]![1].timeArray![4] = Date(timeIntervalSince1970: 0)
            weeklyTimeCell.arrayOfButtons[4].setTitle("Time", for: .normal)
            weeklyTimeCell.fridayAtLabel.text = "Start"
            if let weeklyEndTimeCell = tableView.cellForRow(at: IndexPath(row: 2, section: section)) as? WeeklyTimeTableViewCell {
                if (self.dictionary[section]![1].timeArray![4] == Date(timeIntervalSince1970: 0)) {
                    self.dictionary[section]![2].toggleArray![4] = false
                    weeklyEndTimeCell.fridayAtLabel.isHidden = true
                    weeklyEndTimeCell.fridayTimeButton.isHidden = true
                } else {
                    self.dictionary[section]![2].toggleArray![4] = true
                    weeklyEndTimeCell.fridayAtLabel.isHidden = false
                    weeklyEndTimeCell.fridayTimeButton.isHidden = false
                }
                self.dictionary[section]![2].timeArray![4] = Date(timeIntervalSince1970: 0)
                weeklyEndTimeCell.arrayOfButtons[4].setTitle("Time", for: .normal)
                weeklyEndTimeCell.fridayAtLabel.text = "End"
            }
            //Close WeeklyEndTimeCell when no row 2 toggles are set to true.
            var indexPaths = [IndexPath]()
            tableView.beginUpdates()
            if (removeWeeklyEndTimeCell()) {
                self.dictionary[section]!.remove(at: 2)
                indexPaths.append(IndexPath(row: 2, section: section))
            }
            if (removeWeeklyTimeCell()) {
                self.dictionary[section]!.remove(at: 1)
                indexPaths.append(IndexPath(row: 1, section: section))
            }
            if (indexPaths.count != 0) {
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            tableView.endUpdates()
        }
    }
    
    func removeWeeklyEndTimeCell() -> Bool {
        let section = 2
        if (self.dictionary[section]!.count >= 3) {
            for item in self.dictionary[section]![2].toggleArray! {
                if (item == true) {
                    return false
                }
            }
        } else {
            return false
        }
        return true
        /*if (keepShowingWeeklyTimeCell == false) {
            tableView.beginUpdates()
            self.dictionary[section]!.remove(at: 1)
            var indexes = [IndexPath(row: 1, section: section)]
            if (self.dictionary[section]!.indices.contains(1) == true) { //check if timePickerCell is also in the section.
                self.dictionary[section]!.remove(at: 1)
                indexes.append(IndexPath(row: 2, section: section))
            }
            tableView.deleteRows(at: indexes, with: .automatic)
            tableView.endUpdates()
        }
        return keepShowingWeeklyTimeCell*/
    }
    
    func removeWeeklyTimeCell() -> Bool {
        let section = 2
        if (self.dictionary[section]!.count >= 2) {
            for item in self.dictionary[section]![1].toggleArray! {
                if (item == true) {
                    return false
                }
            }
        } else {
            return false
        }
        return true
    }
    
    //WeeklyTableViewCell Events
    
    var indexOfLastTimeButtonTapped : Int?
    
    @IBAction func mondayTimeTapped(_ sender: AnyObject) {
        let section = 2
        let timePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "TimePickerVC") as! TimePickerViewController
        timePickerVC.title = "Start Time"
        timePickerVC.weeklyEditingTVC = self
        let navigationController = UINavigationController(rootViewController: timePickerVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = UIColor.white
        self.showDetailViewController(navigationController, sender: sender)
        /*if (self.dictionary[section]!.indices.contains(2) == false) {
            tableView.beginUpdates()
            let timePickerCellData = ScheduleRowContent(identifier: "TimePickerCell")
            timePickerCellData.date = self.dictionary[section]![1].timeArray![0]
            self.dictionary[section]!.insert(timePickerCellData, at: 2)
            tableView.insertRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
            tableView.endUpdates()
        } else {
            if (indexOfLastTimeButtonTapped == 0) {
                tableView.beginUpdates()
                self.dictionary[section]!.remove(at: 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[section]![2].date = self.dictionary[section]![1].timeArray![0]
                tableView.reloadRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            }
        }*/
        indexOfLastTimeButtonTapped = 0
    }
    
    @IBAction func tuesdayTimeTapped(_ sender: AnyObject) {
        let section = 2
        let timePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "TimePickerVC") as! TimePickerViewController
        timePickerVC.title = "Start Time"
        timePickerVC.weeklyEditingTVC = self
        let navigationController = UINavigationController(rootViewController: timePickerVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = UIColor.white
        self.showDetailViewController(navigationController, sender: sender)
        /*if (self.dictionary[section]!.indices.contains(2) == false) {
            tableView.beginUpdates()
            let timePickerCellData = ScheduleRowContent(identifier: "TimePickerCell")
            timePickerCellData.date = self.dictionary[section]![1].timeArray![1]
            self.dictionary[section]!.insert(timePickerCellData, at: 2)
            tableView.insertRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
            tableView.endUpdates()
        } else {
            if (indexOfLastTimeButtonTapped == 1) {
                tableView.beginUpdates()
                self.dictionary[section]!.remove(at: 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[section]![2].date = self.dictionary[section]![1].timeArray![1]
                tableView.reloadRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            }
        }*/
        indexOfLastTimeButtonTapped = 1
    }
    
    @IBAction func wednesdayTimeTapped(_ sender: AnyObject) {
        let section = 2
        let timePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "TimePickerVC") as! TimePickerViewController
        timePickerVC.title = "Start Time"
        timePickerVC.weeklyEditingTVC = self
        let navigationController = UINavigationController(rootViewController: timePickerVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = UIColor.white
        self.showDetailViewController(navigationController, sender: sender)
        /*if (self.dictionary[section]!.indices.contains(2) == false) {
            tableView.beginUpdates()
            let timePickerCellData = ScheduleRowContent(identifier: "TimePickerCell")
            timePickerCellData.date = self.dictionary[section]![1].timeArray![2]
            self.dictionary[section]!.insert(timePickerCellData, at: 2)
            tableView.insertRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
            tableView.endUpdates()
        } else {
            if (indexOfLastTimeButtonTapped == 2) {
                tableView.beginUpdates()
                self.dictionary[section]!.remove(at: 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[section]![2].date = self.dictionary[section]![1].timeArray![2]
                tableView.reloadRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            }
        }*/
        indexOfLastTimeButtonTapped = 2
    }
    
    @IBAction func thursdayTimeTapped(_ sender: AnyObject) {
        let section = 2
        let timePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "TimePickerVC") as! TimePickerViewController
        timePickerVC.title = "Start Time"
        timePickerVC.weeklyEditingTVC = self
        let navigationController = UINavigationController(rootViewController: timePickerVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = UIColor.white
        self.showDetailViewController(navigationController, sender: sender)
        /*if (self.dictionary[section]!.indices.contains(2) == false) {
            tableView.beginUpdates()
            let timePickerCellData = ScheduleRowContent(identifier: "TimePickerCell")
            timePickerCellData.date = self.dictionary[section]![1].timeArray![3]
            self.dictionary[section]!.insert(timePickerCellData, at: 2)
            tableView.insertRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
            tableView.endUpdates()
        } else {
            if (indexOfLastTimeButtonTapped == 3) {
                tableView.beginUpdates()
                self.dictionary[section]!.remove(at: 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[section]![2].date = self.dictionary[section]![1].timeArray![3]
                tableView.reloadRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            }
        }*/
        indexOfLastTimeButtonTapped = 3
    }
    
    @IBAction func fridayTimeTapped(_ sender: AnyObject) {
        let section = 2
        let timePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "TimePickerVC") as! TimePickerViewController
        timePickerVC.title = "Start Time"
        timePickerVC.weeklyEditingTVC = self
        let navigationController = UINavigationController(rootViewController: timePickerVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = UIColor.white
        self.showDetailViewController(navigationController, sender: sender)
        /*if (self.dictionary[section]!.indices.contains(2) == false) {
            tableView.beginUpdates()
            let timePickerCellData = ScheduleRowContent(identifier: "TimePickerCell")
            timePickerCellData.date = self.dictionary[section]![1].timeArray![4]
            self.dictionary[section]!.insert(timePickerCellData, at: 2)
            tableView.insertRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
            tableView.endUpdates()
        } else {
            if (indexOfLastTimeButtonTapped == 4) {
                tableView.beginUpdates()
                self.dictionary[section]!.remove(at: 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            } else {
                tableView.beginUpdates()
                self.dictionary[section]![2].date = self.dictionary[section]![1].timeArray![4]
                tableView.reloadRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            }
        }*/
        indexOfLastTimeButtonTapped = 4
    }
    
    @IBAction func mondayEndTimeTapped(_ sender: Any) {
        let timePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "TimePickerVC") as! TimePickerViewController
        timePickerVC.title = "End Time"
        timePickerVC.weeklyEditingTVC = self
        let navigationController = UINavigationController(rootViewController: timePickerVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = UIColor.white
        self.showDetailViewController(navigationController, sender: sender)
        indexOfLastTimeButtonTapped = 0
    }
    
    @IBAction func tuesdayEndTimeTapped(_ sender: Any) {
        let timePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "TimePickerVC") as! TimePickerViewController
        timePickerVC.title = "End Time"
        timePickerVC.weeklyEditingTVC = self
        let navigationController = UINavigationController(rootViewController: timePickerVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = UIColor.white
        self.showDetailViewController(navigationController, sender: sender)
        indexOfLastTimeButtonTapped = 1
    }
    
    @IBAction func wednesdayEndTimeTapped(_ sender: Any) {
        let timePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "TimePickerVC") as! TimePickerViewController
        timePickerVC.title = "End Time"
        timePickerVC.weeklyEditingTVC = self
        let navigationController = UINavigationController(rootViewController: timePickerVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = UIColor.white
        self.showDetailViewController(navigationController, sender: sender)
        indexOfLastTimeButtonTapped = 2
    }
    
    @IBAction func thursdayEndTimeTapped(_ sender: Any) {
        let timePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "TimePickerVC") as! TimePickerViewController
        timePickerVC.title = "End Time"
        timePickerVC.weeklyEditingTVC = self
        let navigationController = UINavigationController(rootViewController: timePickerVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = UIColor.white
        self.showDetailViewController(navigationController, sender: sender)
        indexOfLastTimeButtonTapped = 3

    }
    
    @IBAction func fridayEndTimeTapped(_ sender: Any) {
        let timePickerVC = self.storyboard?.instantiateViewController(withIdentifier: "TimePickerVC") as! TimePickerViewController
        timePickerVC.title = "End Time"
        timePickerVC.weeklyEditingTVC = self
        let navigationController = UINavigationController(rootViewController: timePickerVC)
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = true
        navigationController.modalPresentationStyle = .formSheet
        navigationController.navigationBar.tintColor = UIColor.white
        self.showDetailViewController(navigationController, sender: sender)
        indexOfLastTimeButtonTapped = 4
    }
    
    
    @IBAction func timePickerValueChanged(_ sender: AnyObject) {
        let section = 2
        //Everytime value is changed for datePickerCell, adjust the mondayTimeButton.title (& save data to data model).
        let timePicker = sender as! CustomDatePickerView
        tableView.beginUpdates()
        self.dictionary[section]![2].date = timePicker.date
        if (indexOfLastTimeButtonTapped != nil) {
            self.dictionary[section]![1].timeArray![indexOfLastTimeButtonTapped!] = timePicker.date
        }
        tableView.reloadRows(at: [IndexPath(row: 1, section: section)], with: .none)
        tableView.endUpdates()
    }
    
    //UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let customPickerView = pickerView as! CustomPickerView
        let cellContent = self.dictionary[customPickerView.indexPath.section]![customPickerView.indexPath.row]
        let titleForRow = cellContent.pickerDataSource?.dataArray[row]
        let attributedTitleForRow = NSAttributedString(string: titleForRow!, attributes: [NSAttributedStringKey.foregroundColor : UIColor.init(red: 255, green: 255, blue: 255, alpha: 1.0)])
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
        if (self.homeVC.tableView.cellForRow(at: indexPathForRow!)!.isSelected == true) {
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
            cell?.repeatsImageView.image = #imageLiteral(resourceName: "Black Repeats")
        }
        if (indexPath == nil) {
            if (task.completed != true) {
                self.homeVC.playCompletedSound()
            } else {
                self.homeVC.playNotCompletedSound()
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
        }
    }
    
    func moveTask(_ cell: HomeworkTableViewCell, _ task: RLMTask) {
        var indexPath = self.homeVC.indexOfTask(task: task)
        if (indexPath == nil) {
            //Save Task and Insert Task into Completed Today Section.
            let realm = try! Realm()
            realm.beginWrite()
            task.completed = !task.completed
            if (task.completed == true) {
                if (task.repeatingSchedule != nil) { task.repeatingTaskWasUncompleted = true }
                ///task.completionDate = NSDate()
            } else {
                task.completionDate = nil
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

}
