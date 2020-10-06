//
//  RemindersSettingsTableViewController.swift
//  B4Grad
//
//  Created by Pratik Patel on 1/7/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class RemindersSettingsTableViewController: UITableViewController {
    
    //[Rows]
    //var taskTypes : [String] = ["Assignment", "Quiz", "Midterm", "Final", "Lecture", "Lab", "Tutorial"] //, "Lab", "Tutorial"
    
    var taskTypes : [Int : Array<String>] = [0 : [], 1 : ["Assignments", "Quizzes", "Midterms", "Finals"], 2: ["Lectures", "Tutorials", "Labs"], 3: ["Restore Defaults"]]
    var taskTypeImages : [Int : Array<String>] = [0 : [], 1 : ["Assignment", "Quiz", "Midterm", "Final"], 2: ["Lecture", "Tutorial", "Lab"], 3: ["restore_defaults"]]
    var taskFirstIds = [1,2,3,4]
    var tastSeconsIds = [5,6,7]
    var taskThirdIds = [8]
    var task: RLMTask!
    var reminderSettings : Results<RLMReminderSetting>!
    var homeVC: HomeworkViewController?
    var taskManager: UIViewController? //if relevant
    var cellEditingVC: CellEditingTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageeee = UIImage(named: "restore_defaults")
        if (self.cellEditingVC?.helperObject.mode == .Edit) {
            if (self.task.scope == "Regular") {
                self.taskTypes = [0 : [], 1 : ["Assignments", "Quizzes", "Midterms", "Finals"]]
            } else if (self.task.scope == "Event") {
                self.taskTypes = [0 : [], 1: ["Lectures", "Tutorials", "Labs"]]
            }
        }
        
        //self.title = self.task.type
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.separatorColor = UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1.0)
        
        let realm = try! Realm()
        reminderSettings = realm.objects(RLMReminderSetting.self)
        print(reminderSettings.count)
        if reminderSettings.count == 0 {
            var i = 1
            for key in 1..<4 {
                //let str = (self.taskTypes as NSDictionary).allKeys(for: key) as! [String]
                let arrSettings = self.taskTypes[key]
                for item in arrSettings!{
                    let realm = try! Realm()
                    let setting = RLMReminderSetting(id: i, name: item)
                    realm.beginWrite()
                    realm.add(setting)
                    do {
                        try realm.commitWrite()
                    } catch let error {
                        let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                        errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                    }
                    
                    i = i + 1
                    
                }
            }
            reminderSettings = realm.objects(RLMReminderSetting.self)
        }
        
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
        let taskTypeImage = self.taskTypeImages[indexPath.section]![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeTableViewCell", for: indexPath) as! TaskTypeTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.taskLabel.text = taskType
        if indexPath.section == 3 {
            cell.taskImageView.image = UIImage(named: taskTypeImage)
        } else {
            cell.taskImageView.image = UIImage(named: "Default" + taskTypeImage)
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //if (self.cellEditingVC?.helperObject.mode == .Create) {
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
       // }
        
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
        if (cell.accessoryType == .disclosureIndicator) {
            cell.accessoryView = UIImageView(image: UIImage(named: "disclosure indicator"))
        }
        cell.contentView.backgroundColor = nil //since iOS13
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let taskTypeCell = cell as? TaskTypeTableViewCell {
            taskTypeCell.taskLabel.textColor = UIColor.white
            if indexPath.section == 3 {
                taskTypeCell.taskImageView.image = UIImage(named: self.taskTypeImages[indexPath.section]![indexPath.row])
            } else {
            taskTypeCell.taskImageView.image = UIImage(named: "Default" + self.taskTypeImages[indexPath.section]![indexPath.row])
            }
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
        if indexPath.section == 3 {
            let alert = UIAlertController(title: "Alert", message: "'Are you sure you want to make Restore Defaults?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                UserDefaults.standard.set(true, forKey: "IsRestoreDefaults")
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                appdelegate.setPredefinedRemindersForFirstTime()
                self.tableView.reloadData()
            }
            let noAction = UIAlertAction(title: "No", style: .default) { (action) in
                self.tableView.reloadData()
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
            
            
        } else {
            self.performSegue(withIdentifier: "GotoReminder", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is RemindersTableViewController {
            if let indexPath = tableView.indexPathForSelectedRow{
                let arrTasks = taskTypes[indexPath.section]
                let strType = arrTasks![indexPath.row]
                print(strType)
                let realm = try! Realm()
                let filteredSettings = realm.objects(RLMReminderSetting.self).filter("name = %@",strType)
                print(filteredSettings.count)
                let setting = filteredSettings[0]
                let controller = segue.destination as! RemindersTableViewController
                controller.reminderSetting = setting
                controller.segueFromSettingsScreen = true
                print(setting.name)
                
            }
        }
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
