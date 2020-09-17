//
//  CoursesViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-04-26.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class CoursesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var homeVC: HomeworkViewController!
    var sections = ["Current Term", ""]
    
    var coursesQuery: Results<RLMCourse> {
        let realm = try! Realm()
        return realm.objects(RLMCourse.self).sorted(byKeyPath: "createdDate", ascending: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        //If users will be able to access a schedule for tasks not assigned to a course, remove the following logic.
        if (self.coursesQuery.count == 0) {
            let addCourseTableViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddCourseTableViewController") as! AddCourseTableViewController
            addCourseTableViewController.mode = .Create
            addCourseTableViewController.coursesVC = self
            self.show(addCourseTableViewController, sender: self)
        }
    }
    
    @IBAction func addCourseButtonTapped(_ sender: Any) {
        let addCourseTableViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddCourseTableViewController") as! AddCourseTableViewController
        addCourseTableViewController.mode = .Create
        addCourseTableViewController.coursesVC = self
        self.show(addCourseTableViewController, sender: sender)
        //Original behaviour below.
        //self.show(self.storyboard!.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController, sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let selectedRowIndexPath = self.tableView.indexPathForSelectedRow
        if ((selectedRowIndexPath) != nil) {
            if let coordinator = transitionCoordinator {
                let animationBlock: (UIViewControllerTransitionCoordinatorContext?) -> () = { [weak self] _ in
                    self!.tableView.deselectRow(at: selectedRowIndexPath!, animated: true)
                }
                let completionBlock: (UIViewControllerTransitionCoordinatorContext?) -> () = { [weak self] context in
                    if context != nil && context!.isCancelled {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.coursesQuery.count > 0) {
            return self.sections.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return self.coursesQuery.count
        }
        if (section == 1) {
            if (self.coursesQuery.count > 0) {
                return 1
            } else {
                return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BeginNewTermCell", for: indexPath) as! BeginNewTermTableViewCell
            return cell
        }
        let course = self.coursesQuery[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseSavedTableViewCell", for: indexPath) as! CourseSavedTableViewCell
        if (course.courseCode != nil) {
            cell.courseLabel.text = course.courseCode! + " - " + course.courseName
        } else {
            cell.courseLabel.text = course.courseName
        }
        if (course.color != nil) {
            cell.circleView.color = course.color!.getUIColorObject()
            print(cell.circleView.color?.description)
        } else {
            cell.circleView.color = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CourseSavedTableViewCell {
            let course = self.coursesQuery[indexPath.row]
            /*let addCourseTableViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddCourseTableViewController") as! AddCourseTableViewController
             addCourseTableViewController.mode = .Edit
             addCourseTableViewController.course = self.coursesQuery[indexPath.row]
             addCourseTableViewController.coursesVC = self
             self.show(addCourseTableViewController, sender: cell)*/
            let scheduleEditingVC = self.storyboard!.instantiateViewController(withIdentifier: "ScheduleEditorViewController") as! ScheduleEditorViewController
            scheduleEditingVC.course = course
            scheduleEditingVC.coursesVC = self
            scheduleEditingVC.homeVC = self.homeVC
            let courseNameContent = scheduleEditingVC.getScheduleRowContentWithIdentifier(identifier: "CourseNameCell")!
            courseNameContent.name = course.courseName
            let courseCodeContent = scheduleEditingVC.getScheduleRowContentWithIdentifier(identifier: "CourseCodeCell")!
            courseCodeContent.name = course.courseCode
            self.show(scheduleEditingVC, sender: cell)
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? BeginNewTermTableViewCell {
            self.tableView.deselectRow(at: indexPath, animated: true)
            let alert = UIAlertController(title: "Confirmation - Begin New Term", message: "B4Grad will remove all existing courses & their tasks. There is no way to undo this. Continue?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                self.beginNewTerm()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func beginNewTerm() {
        let courses = self.coursesQuery
        let realm = try! Realm()
        
        var colors = [RLMColor]()
        var repeatingSchedules = [RLMRepeatingSchedule]()
        var dateTokens = [RLMDateToken]()
        var tasks = [RLMTask]()
        for course in courses {
            let coursePredicate = NSPredicate(format: "course = %@", course as CVarArg)
            //Get color object.
            if (course.color != nil) { colors.append(course.color!) }
            //Query RepeatingSchedules.
            let repeatingSchedulesForCourse = realm.objects(RLMRepeatingSchedule.self).filter(coursePredicate).toArray()
            repeatingSchedules.append(contentsOf: repeatingSchedulesForCourse)
            //Get their DateTokens.
            for schedule in repeatingSchedules {
                dateTokens.append(contentsOf: schedule.tokens)
            }
            //Get their Tasks.
            tasks.append(contentsOf: realm.objects(RLMTask.self).filter(coursePredicate))
        }
        
        //Remember: Realm lazily loads results from queries, so the order in which things are deleted, even inside the same commitWrite(), DOES MATTER !!!
        realm.beginWrite()
        realm.delete(tasks)
        realm.delete(dateTokens)
        realm.delete(repeatingSchedules)
        realm.delete(colors)
        realm.delete(courses)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription + " This is a rare issue.", preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
            return
        }
        var indexPathsInSection0 = [IndexPath]()
        for row in 0..<self.tableView.numberOfRows(inSection: 0) {
            indexPathsInSection0.append(IndexPath(row: row, section: 0))
        }
        self.tableView.beginUpdates()
        self.tableView.deleteSections(IndexSet([1]), with: .fade)
        self.tableView.deleteRows(at: indexPathsInSection0, with: .fade)
        self.tableView.endUpdates()
        UIView.animate(withDuration: 0.7, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.homeVC.tableView.alpha = 0 }, completion: { Void in
            if (self.homeVC.completedTodayTasks.count == 0) { self.homeVC.sections.removeObject(object: "Completed Today") }
            if (self.homeVC.extendedTasks.count == 0) { self.homeVC.sections.removeObject(object: "Extended") }
            self.homeVC.tableView.reloadData()
            UIView.animate(withDuration: 0.7, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.homeVC.tableView.alpha = 1 }, completion: { Void in
                self.addCourseButtonTapped(self)
            })
        })
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 0) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (indexPath.section != 0) { return }
        if editingStyle == UITableViewCellEditingStyle.delete {
            //Show Confirmation Dialog.
            let alert = UIAlertController(title: "Confirmation - Delete Course", message: "B4Grad will remove the course & its tasks. There is no way to undo this. Continue?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                self.deleteSingleCourse(indexPath: indexPath)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }

    func deleteSingleCourse(indexPath: IndexPath) {
        let course = self.coursesQuery[indexPath.row]
        let realm = try! Realm()
        let coursePredicate = NSPredicate(format: "course = %@", course as CVarArg)
        //Get color object.
        let colorObject = course.color
        //Query RepeatingSchedules.
        let repeatingSchedules = realm.objects(RLMRepeatingSchedule.self).filter(coursePredicate).toArray()
        //Get their DateTokens.
        var dateTokens = [RLMDateToken]()
        for schedule in repeatingSchedules {
            dateTokens.append(contentsOf: schedule.tokens)
        }
        //Get their Tasks.
        let tasks = realm.objects(RLMTask.self).filter(coursePredicate)
        
        //Remember: Realm lazily loads results from queries, so the order in which things are deleted, even inside the same commitWrite(), DOES MATTER !!!
        realm.beginWrite()
        realm.delete(tasks)
        realm.delete(dateTokens)
        realm.delete(repeatingSchedules)
        if (colorObject != nil) { realm.delete(colorObject!) }
        realm.delete(course)
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription + " This is a rare issue.", preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
            return
        }
        self.tableView.beginUpdates()
        if (self.coursesQuery.count == 0) {
            self.tableView.deleteSections(IndexSet([1]), with: .automatic)
        }
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
        UIView.animate(withDuration: 0.7, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.homeVC.tableView.alpha = 0 }, completion: { Void in
            if (self.homeVC.completedTodayTasks.count == 0) { self.homeVC.sections.removeObject(object: "Completed Today") }
            if (self.homeVC.extendedTasks.count == 0) { self.homeVC.sections.removeObject(object: "Extended") }
            self.homeVC.tableView.reloadData()
            UIView.animate(withDuration: 0.7, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { self.homeVC.tableView.alpha = 1 }, completion: nil)
        })
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: { })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
