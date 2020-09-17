
//
//  TutorialEditingTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-09.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class TutorialEditingTableViewController: UITableViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    var dictionary :[Int:Array<ScheduleRowContent>] = [0 : [ScheduleRowContent(identifier: "InstructionsCell")], 1 : [ScheduleRowContent(identifier: "SectionCell"), ScheduleRowContent(identifier: "LocationCell")], 2 : [ScheduleRowContent(identifier: "WeekdayCell", defaultToggleArray: [false, false, false, false, false])], 3 : [ScheduleRowContent(identifier: "UseCell")] ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 71
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        if (cellContent.identifier == "LocationCell") {
            let locationCell = cell as! LocationTableViewCell
            locationCell.textField.delegate = self
        }
        
        if (cellContent.identifier == "WeekdayCell") {
            let weekdayCell = cell as! WeekdayTableViewCell
            
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
                    weeklyTimeCell.arrayOfLabels[index].text = "Select"
                } else {
                    weeklyTimeCell.arrayOfButtons[index].titleLabel!.font = UIFont.systemFont(ofSize: 16)
                    weeklyTimeCell.arrayOfButtons[index].setTitle(DateFormatter.localizedString(from: time as Date, dateStyle: .none, timeStyle: .short), for: UIControlState())
                    weeklyTimeCell.arrayOfLabels[index].text = "at"
                }
            }
            
            return weeklyTimeCell
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
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.dictionary[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row].identifier == "UseCell") {
            self.performSegue(withIdentifier: "UnwindToPreviousVC", sender: tableView.cellForRow(at: indexPath))
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
        textField.resignFirstResponder()
        return true
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
            //Close TimePickerCell when a [weekday]Button is set to false.
            if (updateWeeklyTimeCellStatus() && self.dictionary[section]![1].toggleArray![0] == false && indexOfLastTimeButtonTapped == 0 && self.dictionary[section]!.indices.contains(2)) {
                tableView.beginUpdates()
                self.dictionary[section]!.remove(at: 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            }
            
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
            //Close TimePickerCell when a [weekday]Button is set to false.
            if (updateWeeklyTimeCellStatus() && self.dictionary[section]![1].toggleArray![1] == false && indexOfLastTimeButtonTapped == 1 && self.dictionary[section]!.indices.contains(2)) {
                tableView.beginUpdates()
                self.dictionary[section]!.remove(at: 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            }
            
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
            //Close TimePickerCell when a [weekday]Button is set to false.
            if (updateWeeklyTimeCellStatus() && self.dictionary[section]![1].toggleArray![2] == false && indexOfLastTimeButtonTapped == 2 && self.dictionary[section]!.indices.contains(2)) {
                tableView.beginUpdates()
                self.dictionary[section]!.remove(at: 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            }
            
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
            //Close TimePickerCell when a [weekday]Button is set to false.
            if (updateWeeklyTimeCellStatus() && self.dictionary[section]![1].toggleArray![3] == false && indexOfLastTimeButtonTapped == 3 && self.dictionary[section]!.indices.contains(2)) {
                tableView.beginUpdates()
                self.dictionary[section]!.remove(at: 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            }
            
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
            //Close TimePickerCell when a [weekday]Button is set to false.
            if (updateWeeklyTimeCellStatus() && self.dictionary[section]![1].toggleArray![4] == false && indexOfLastTimeButtonTapped == 4 && self.dictionary[section]!.indices.contains(2)) {
                tableView.beginUpdates()
                self.dictionary[section]!.remove(at: 2)
                tableView.deleteRows(at: [IndexPath(row: 2, section: section)], with: .automatic)
                tableView.endUpdates()
            }
            
        }
    }
    
    func updateWeeklyTimeCellStatus() -> Bool {
        let section = 2
        var keepShowingWeeklyTimeCell = false
        for item in self.dictionary[section]![1].toggleArray! {
            if (item == true) {
                keepShowingWeeklyTimeCell = true
            }
        }
        if (keepShowingWeeklyTimeCell == false) {
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
        return keepShowingWeeklyTimeCell
    }
    
    //WeeklyTableViewCell Events
    
    var indexOfLastTimeButtonTapped : Int?
    
    @IBAction func mondayTimeTapped(_ sender: AnyObject) {
        let section = 2
        if (self.dictionary[section]!.indices.contains(2) == false) {
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
        }
        indexOfLastTimeButtonTapped = 0
    }
    
    @IBAction func tuesdayTimeTapped(_ sender: AnyObject) {
        let section = 2
        if (self.dictionary[section]!.indices.contains(2) == false) {
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
        }
        indexOfLastTimeButtonTapped = 1
    }
    
    @IBAction func wednesdayTimeTapped(_ sender: AnyObject) {
        let section = 2
        if (self.dictionary[section]!.indices.contains(2) == false) {
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
        }
        indexOfLastTimeButtonTapped = 2
    }
    
    @IBAction func thursdayTimeTapped(_ sender: AnyObject) {
        let section = 2
        if (self.dictionary[section]!.indices.contains(2) == false) {
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
        }
        indexOfLastTimeButtonTapped = 3
    }
    
    @IBAction func fridayTimeTapped(_ sender: AnyObject) {
        let section = 2
        if (self.dictionary[section]!.indices.contains(2) == false) {
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
        }
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
    
    
    // MARK: - Navigation
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

