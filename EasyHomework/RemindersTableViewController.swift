//
//  RemindersTableViewController.swift
//  B4Grad
//
//  Created by Pratik Patel on 1/8/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class RemindersTableViewController: UITableViewController, TimeSelectedDelegate {
    
    var arrSameDays =  ["At Time of Event", "5 Minutes Before", "15 Minutes Before", "30 Minutes Before", "1 Hour Before", "2 Hours Before"]
    var arrSameDaysImages =  ["At Time of Event", "5 Minutes Before", "15 Minutes Before", "30 Minutes Before", "1 Hour Before", "2 Hours Before"]
    var arrDiffDaysImages =  ["1 day before", "3 days before", "1 week before", "2 weeks before", "1 month before"]
    var arrDiffDays = ["1 Day Before", "3 Days Before", "1 Week Before", "2 Weeks Before", "1 Month Before"]
    var arrSameDaysIDs = [1, 2, 3, 4, 5, 6]
    var arrDiffDayIDs = [7, 8, 9, 10, 11]
    var selectedItems  = [NSMutableDictionary]()
    var selectedID : Int!
    var selectedName : String!
    var task : RLMTask!
    var reminderSetting : RLMReminderSetting!
    var mode : TaskEditingMode!
    var selectedItem = 0
    
    var segueFromSettingsScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        if self.task != nil {
            let reminders = self.task.reminders
            for reminder in reminders {
                let dict = NSMutableDictionary()
                dict.setValue(reminder.selectedID, forKey: "Id")
                dict.setValue(reminder.notificationId, forKey: "name")
                if reminder.reminderDate != nil {
                    dict.setValue(reminder.reminderDate! as Date, forKey: "date")
                }
                selectedItems.append(dict)
            }
        } else if self.reminderSetting != nil {
            let reminders = self.reminderSetting.reminders ?? List<RLMReminder>()
            for reminder in reminders {
                let dict = NSMutableDictionary()
                dict.setValue(reminder.selectedID, forKey: "Id")
                dict.setValue(reminder.notificationId, forKey: "name")
                if reminder.reminderDate != nil {
                    dict.setValue(reminder.reminderDate! as Date, forKey: "date")
                }
                selectedItems.append(dict)
            }
        }
        
        self.tableView.register(UINib(nibName: "ReminderCell", bundle: nil), forCellReuseIdentifier: "ReminderCell")
        self.tableView.contentInset.top = 40
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return arrSameDays.count
        } else {
            return arrDiffDays.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12)
        cell.selectedBackgroundView = selectedBackgroundView
        //cell.layer.cornerRadius = cell.frame.size.width / 12
        cell.layer.masksToBounds = true
        
        if indexPath.section == 0 {
            cell.lblName.text = arrSameDays[indexPath.row]
            cell.imgIcon.image = UIImage(named: arrSameDaysImages[indexPath.row])
            cell.accessoryType = UITableViewCellAccessoryType.none
            
            var isselected = false
            for dict in selectedItems {
                let selectedID = dict.value(forKey: "Id") as! Int
                if selectedID == arrSameDaysIDs[indexPath.row] {
                    isselected = true
                    break
                }
            }
            if isselected == true{
                cell.imgCheck.isHidden = false
            } else {
                cell.imgCheck.isHidden = true
            }
            
        } else {
            cell.lblName.text = arrDiffDays[indexPath.row]
            cell.imgIcon.image = UIImage(named: arrDiffDaysImages[indexPath.row])
            var isselected = false
            var selectedDict : NSMutableDictionary? = nil
            for dict in selectedItems {
                let selectedID = dict.value(forKey: "Id") as! Int
                if selectedID == arrDiffDayIDs[indexPath.row] {
                    isselected = true
                    selectedDict = dict
                    break
                }
            }
            if isselected == true{
                let selectedDate = ((selectedDict?.value(forKey: "date") as? Date) as? NSDate)?.toReadableTimeString()
                
                if (selectedDate != nil) {
                    cell.lblName.text = arrDiffDays[indexPath.row] + "  (\(selectedDate!))"
                    cell.lblName.halfTextColorChange(fullText: cell.lblName.text!, changeText: "(\(selectedDate!))")
                    //cell.lblName.halfTextColorChange(fullText: cell.lblName.text!, changeText:"(\(selectedDate))")
                }
                cell.imgCheck.isHidden = false
                cell.accessoryType = UITableViewCellAccessoryType.none
            } else {
                cell.imgCheck.isHidden = true
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        //tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath) as! ReminderCell
            
            let dict = NSMutableDictionary()
            dict.setValue(arrSameDaysIDs[indexPath.row], forKey: "Id")
            dict.setValue(arrSameDays[indexPath.row], forKey: "name")
            
            if cell.imgCheck.isHidden == true {
                cell.imgCheck.isHidden = false
                selectedItems.append(dict)
            } else {
                cell.imgCheck.isHidden = true
                selectedItems.removeObject(object: dict)
            }
            selectedItem = arrSameDaysIDs[indexPath.row]
            saveReminders()
            self.tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selectedItem = arrDiffDayIDs[indexPath.row]
            selectedID = arrDiffDayIDs[indexPath.row]
            selectedName = arrDiffDays[indexPath.row]
            self.performSegue(withIdentifier: "showTimePickerSegue", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            let headerView = SectionHeaderView.construct("Short Term", owner: tableView)
            headerView.contentView.backgroundColor = UIColor.clear
            return headerView
        } else {
            let headerView = SectionHeaderView.construct("Long Term", owner: tableView)
            headerView.contentView.backgroundColor = UIColor.clear
            return headerView
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*cell.backgroundColor = UIColor(red: 36/255, green: 41/255, blue: 36/255, alpha: 1.0)
         if (cell.contentView.backgroundColor != UIColor.clear) {
         cell.backgroundColor = cell.contentView.backgroundColor
         }*/
        if (cell.accessoryType == .disclosureIndicator) {
            cell.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator"))
        }
        cell.contentView.backgroundColor = nil //since iOS13
    }
    
    func didselectDate(selectedArray: [NSMutableDictionary]) {
        self.selectedItems = selectedArray
        self.tableView.reloadData()
        saveReminders()
        upDateNotifications()
    }
    
    func saveReminders() {
        
        if self.task != nil {
//            if (self.mode == .Create) {
//                self.task.reminders.removeAll()
//                for dict in self.selectedItems {
//                    let ID = dict.value(forKey: "Id") as! Int
//                    let date = dict.value(forKey: "date") as? Date
//                    let name = dict.value(forKey: "name") as! String
//
//                    if date != nil {
//                        let reminder = RLMReminder(selectedID: ID, notificationId: name, date: date! as NSDate)
//                        self.task.reminders.append(reminder)
//                    } else {
//                        let reminder = RLMReminder(selectedID: ID, notificationId: name, date: nil)
//                        self.task.reminders.append(reminder)
//                    }
//                }
//            } else {
                let realm = try! Realm()
                realm.beginWrite()
                self.task.reminders.removeAll()
                for dict in self.selectedItems {
                    let ID = dict.value(forKey: "Id") as! Int
                    let date = dict.value(forKey: "date") as? Date
                    let name = dict.value(forKey: "name") as! String
                    self.task.isReminderModified = true
                    if (date != nil && self.task.dueDate != nil) {
                        let reminder = RLMReminder(selectedID: ID, notificationId: name, date: date! as NSDate)
                        self.task.reminders.append(reminder)
                    } else {
                        if (self.segueFromSettingsScreen == true) {
                            let reminder = RLMReminder(selectedID: ID, notificationId: name, date: nil)
                            self.task.reminders.append(reminder)
                        } else {
                            if date != nil {
                                let reminder = RLMReminder(selectedID: ID, notificationId: name, date: date! as NSDate)
                                self.task.reminders.append(reminder)
                            } else if date == nil {
                                let reminder = RLMReminder(selectedID: ID, notificationId: name, date: nil)
                                self.task.reminders.append(reminder)
                            }
                        }
                    }
                }
                do {
                    try realm.commitWrite()
                } catch let error {
                    let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                    errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                }
            //let rcm1 = realm.objects(RLMReminderSetting.self)
           // }
        }
        /*else if self.reminderSetting != nil { //When accessed from ReminderSettingsTableViewController.
            let realm = try! Realm()
            realm.beginWrite()
            self.task.reminders.removeAll()
            for dict in self.selectedItems {
                let ID = dict.value(forKey: "Id") as! Int
                let date = dict.value(forKey: "date") as? Date
                let name = dict.value(forKey: "name") as! String
                self.task.isReminderModified = true
                if (date != nil && self.task.dueDate != nil) {
                    let reminder = RLMReminder(selectedID: ID, notificationId: name, date: date! as NSDate)
                    self.task.reminders.append(reminder)
                } else {
                    if (self.segueFromSettingsScreen == true) {
                        let reminder = RLMReminder(selectedID: ID, notificationId: name, date: nil)
                        self.task.reminders.append(reminder)
                    } else {
                        if date == nil {
                            let reminder = RLMReminder(selectedID: ID, notificationId: name, date: nil)
                            self.task.reminders.append(reminder)
                        }
                    }
                }
            }
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            }
            // }
        }*/
        else if self.reminderSetting != nil { //When accessed from ReminderSettingsTableViewController.
            
            let alert = UIAlertController(title: "Alert", message: "'Would you like this change to affect already made \(reminderSetting.name)?", preferredStyle: .actionSheet)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                self.saveReminder()
                self.updatetasks()
            }
            let noAction = UIAlertAction(title: "No", style: .default) { (action) in
                self.saveReminder()
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func saveReminder(){
        let realm = try! Realm()
        realm.beginWrite()
        self.reminderSetting.reminders.removeAll()
        for dict in self.selectedItems {
            let ID = dict.value(forKey: "Id") as! Int //i.e.) 7
            let date = dict.value(forKey: "date") as? Date //i.e.) nil
            let name = dict.value(forKey: "name") as! String //i.e.) "1 Day Before  (4:00 PM)"
            
            if date != nil {
                let reminder = RLMReminder(selectedID: ID, notificationId: name, date: date! as NSDate)
                self.reminderSetting.reminders.append(reminder)
            } else {
                let reminder = RLMReminder(selectedID: ID, notificationId: name, date: nil)
                self.reminderSetting.reminders.append(reminder)
            }
        }
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
        }
    }
    
    func updatetasks(){
        let realm = try! Realm()
        let tasks = realm.objects(RLMTask.self)
        
        for taskObject in tasks{
            if self.getReminderStringFromType(name: taskObject.type) == reminderSetting.name{
                let settingReminders = getReminderSettingFromtype(name: taskObject.type)
                var isReminderRemoved = true
                for setting in settingReminders {
                    //let taskReminders = taskObject.reminders.filter("selectedID = %@",setting.selectedID)
                    if setting.selectedID == selectedItem {
                        isReminderRemoved = false
                    }
                }
                if isReminderRemoved == true {
                    let oldReminders = taskObject.reminders.filter("selectedID = %@",selectedItem)
                    if oldReminders.count > 0 {
                        var index = 0
                        for taskreminder in taskObject.reminders {
                            if let oldReminderFirst = oldReminders.first {
                                if taskreminder.selectedID == oldReminderFirst.selectedID{
                                    realm.beginWrite()
                                    taskObject.reminders.remove(at: index)
                                    do {
                                        try realm.commitWrite()
                                    } catch let error {
                                        print(error)
                                    }
                                }
                            }
                            index += 1
                        }
                    }
                } else {
                    let newReminders = settingReminders.filter("selectedID = %@",selectedItem)
                    if newReminders.count > 0 {
                        
                        var isReminderAlreadyAdded = false
                        for taskreminder in taskObject.reminders {
                            if let newReminderFirst = newReminders.first {
                                if taskreminder.selectedID == newReminderFirst.selectedID{
                                    isReminderAlreadyAdded = true
                                }
                            }
                        }
    
                        if isReminderAlreadyAdded == false {
                             if let newReminderFirst = newReminders.first {
                                realm.beginWrite()
                                taskObject.reminders.append(newReminderFirst)
                                do {
                                    try realm.commitWrite()
                                } catch let error {
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*func updatetasks(){
        let realm = try! Realm()
        let tasks = realm.objects(RLMTask.self)
        
        for taskObject in tasks{
            if self.getReminderStringFromType(name: taskObject.type) == reminderSetting.name{
                let settingReminders = getReminderSettingFromtype(name: taskObject.type)
                var isReminderRemoved = true
                for setting in settingReminders {
                    let taskReminders = taskObject.reminders.filter("selectedID = %@",setting.selectedID)
                    if setting.selectedID == selectedItem {
                        isReminderRemoved = false
                    }
                    if taskReminders.count == 0 {
                        realm.beginWrite()
                        taskObject.reminders.append(setting)
                        do {
                            try realm.commitWrite()
                        } catch let error {
                            print(error)
                        }
                    }
                }
                if isReminderRemoved == true {
                    let oldReminders = taskObject.reminders.filter("selectedID = %@",selectedItem)
                    if oldReminders.count > 0 {
                        if let indexofReminder = taskObject.reminders.index(of: oldReminders.first!){
                            realm.beginWrite()
                            taskObject.reminders.remove(at: indexofReminder)
                            do {
                                try realm.commitWrite()
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
    }*/
    
    func upDateNotifications(){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.setRemindersNotifications()
        
        /*if (UserDefaults.standard.bool(forKey: "isSubscribed") == false) {
            UIApplication.shared.cancelAllLocalNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }*/
    }
    
    func getReminderStringFromType(name : String) -> String {
        var strType = ""
        if name == "Assignment" {
            strType = "Assignments"
        } else if name == "Quiz" {
            strType = "Quizzes"
        } else if name == "Midterm" {
            strType = "Midterms"
        } else if name == "Final" {
            strType = "Finals"
        } else if name == "Lecture" {
            strType = "Lectures"
        } else if name == "Lab" {
            strType = "Labs"
        } else if name == "Tutorial" {
            strType = "Tutorials"
        }
        return strType
    }
    
    func getReminderSettingFromtype(name : String) -> List<RLMReminder> {
        var strType = ""
        if name == "Assignment" {
            strType = "Assignments"
        } else if name == "Quiz" {
            strType = "Quizzes"
        } else if name == "Midterm" {
            strType = "Midterms"
        } else if name == "Final" {
            strType = "Finals"
        } else if name == "Lecture" {
            strType = "Lectures"
        } else if name == "Lab" {
            strType = "Labs"
        } else if name == "Tutorial" {
            strType = "Tutorials"
        }
        
        let realm = try! Realm()
        let reminderSettings = realm.objects(RLMReminderSetting.self).filter("name = %@",strType)
        let reminderSetting = reminderSettings[0]
        return reminderSetting.reminders ?? List<RLMReminder>()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ReminderTimePickerViewController {
            let controller = segue.destination as! ReminderTimePickerViewController
            controller.delegate = self
            controller.selectedArray = self.selectedItems
            controller.selectedID = self.selectedID
            controller.selectedName = self.selectedName
            
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
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension UILabel {
    func halfTextColorChange (fullText : String , changeText : String ) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(white: 1, alpha: 0.6) , range: range)
        self.attributedText = attribute
    }
}
