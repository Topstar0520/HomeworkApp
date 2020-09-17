//
//  HomeworkViewController.swift
//  EasyHomework
//
//  Created by Anthony Giugno on 2016-02-14.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse
import RealmSwift
import AVFoundation

class HomeworkViewController: B4GradViewController, UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate, HomeworkTableViewCellDelegate, AVAudioPlayerDelegate, NotificationBannerViewDelegate {
    
    var sections = ["", "Completed Today", "Extended"]
    @IBOutlet var tableView: B4GradTableView!
    let refreshControl = UIRefreshControl()
    var emptyHomescreenView : EmptyHomescreenView!
    var audioPlayers = [AVAudioPlayer]()
    var loadRealmFailedError: Error?
    var earliestTimeToday: Date! //Used for Task Queries with Regular/Project Scopes.
    var timeWhenAppLaunched = Date() //Used for Task Queries with Event Scope.
    var endOfDay: Date! //
    var fifteenMinutesBeforeAppLaunch: Date! //
    var oneHourBeforeAppLaunch: Date!
    //The following 2 variables exist only to ensure that cells look selected after being reloaded (since reloading a tableView cell deselects it).
    var lastSelectedRowIndexPath : IndexPath?
    var useLastSelectedRowIndexPath = false
    
    //This method technically should be based on section name rather than section #. Adding a third section could cause inconsistency due to this. Edit: A third section, 'Extended', has been added with little problem by adding the additional if statement in (section == 1)'s nest. Also modify numberOfSections(..).
    func tasks(inSection section: Int) -> [RLMTask] {
        if (section == 0) {
            return self.activeTasks
        }
        if (section == 1) {
            if self.sections.first(where: { $0 == "Completed Today" }) != nil {
                return self.completedTodayTasks.toArray()
            } else {
                return self.extendedTasks
            }
        }
        if (section == 2) {
            return self.extendedTasks
        }
        print("Section Number inaccurate. Check tasks(inSection section: Int) function.")
        return self.activeTasks
    }
    
    var tasksCount: Int {
        return (self.activeTasks.count + self.completedTodayTasks.count + self.extendedTasks.count)
    }
    
    //Realm version of this method crashes, so this is the alternative at the cost of performance.
    func indexOfTask(task: RLMTask) -> IndexPath? {
        var section = 0
        var row = Int()
        var dataArray = [RLMTask]()
        let tasksInSection0 = self.tasks(inSection: 0)
        for task in tasksInSection0 {
            dataArray.append(task)
        }
        if (dataArray.index(of: task) != nil) {
            row = dataArray.index(of: task)!
            return IndexPath(row: row, section: section)
        }
        dataArray.removeAll()
        let tasksInSection1 = self.tasks(inSection: 1)
        for task in tasksInSection1 {
            dataArray.append(task)
        }
        if (dataArray.index(of: task) != nil) {
            section = 1
            row = dataArray.index(of: task)!
            return IndexPath(row: row, section: section)
        }
        dataArray.removeAll()
        let tasksInSection2 = self.tasks(inSection: 2)
        for task in tasksInSection2 {
            dataArray.append(task)
        }
        if (dataArray.index(of: task) != nil) {
            section = 2
            row = dataArray.index(of: task)!
            return IndexPath(row: row, section: section)
        }
        return nil
    }
    
    var activeTasks: [RLMTask] { //uncompleted tasks.  //used to be Results<RLMTask>
        let realm = try! Realm()
        //Event Tasks sorted using TWO queries: Events with both startTimes & endTimes & Events with only startTimes. objectsWithNullDueDates handles those with null dueDates. One query is (kind've) missing: Events with dueDates but no startTime actually set.
        let eventsWithEndTimesAfter_CVarArg = NSPredicate(format: "endDateAndTime > %@", self.fifteenMinutesBeforeAppLaunch as CVarArg)
        let eventsWithStartTimesBeforeEndOfDay = NSPredicate(format: "dueDate <= %@", self.endOfDay as CVarArg)
        let eventsWithStartTimesAndEndTimes = realm.objects(RLMTask.self).filter("scope = 'Event' AND completed = false AND removed = false AND dueDate != null AND tempVisible = false").filter(eventsWithEndTimesAfter_CVarArg).filter(eventsWithStartTimesBeforeEndOfDay).sorted(byKeyPath: "dueDate", ascending: true)
        
        let eventsWithStartTimesAfter_CVarArg = NSPredicate(format: "dueDate >= %@", self.oneHourBeforeAppLaunch as CVarArg)
        let eventsWithOnlyStartTimes = realm.objects(RLMTask.self).filter("scope = 'Event' AND completed = false AND removed = false AND endDateAndTime = null AND dueDate != null AND tempVisible = false").filter(eventsWithStartTimesAfter_CVarArg).filter(eventsWithStartTimesBeforeEndOfDay).sorted(byKeyPath: "dueDate", ascending: true)
        
        //Now, events that had their dueDate set to sometime in the past from the Agenda. (so that they remain in-place) Storing the row # would be problematic as other tasks could be modified thus the row # would be outdated and thus inaccurate.
        let todayOrBefore = NSPredicate(format: "dueDate <= %@", self.endOfDay as CVarArg)
        let eventsThatAlreadyHappenedArray = realm.objects(RLMTask.self).filter("tempVisible = true AND scope = 'Event' AND completed = false AND removed = false").filter(todayOrBefore).sorted(byKeyPath: "tempDueDate", ascending: true).toArray()
        
        //Now mix the results of both queries and sort them.
        var eventsArray = eventsWithStartTimesAndEndTimes.toArray() + eventsWithOnlyStartTimes.toArray()
        eventsArray = eventsArray.sorted(by: { $0.dueDate!.timeIntervalSince1970 < $1.dueDate!.timeIntervalSince1970 })
        for tempEvent in eventsThatAlreadyHappenedArray {
            for (index, event) in eventsArray.enumerated() {
                if (tempEvent.tempDueDate!.timeIntervalSinceReferenceDate < event.dueDate!.timeIntervalSinceReferenceDate) {
                    eventsArray.insert(tempEvent, at: index)
                }
            }
        }
        if (eventsArray.count == 0) {
            eventsArray.append(contentsOf: eventsThatAlreadyHappenedArray)
        }
        
        ///self.ensureEventsInAgendaAreTempVisible(tasksArray: eventsArray) //moved to end of method to handle nil events.
        
        //twoWeeksFromNow now uses self.earliestTimeToday & 15 days instead of Date() w/ 14 days, same w/ extendedTasks.
        let twoWeeksFromNow = Calendar.current.date(byAdding: .day, value: 15, to: self.earliestTimeToday)!
        let beforeTwoWeeksFromNow = NSPredicate(format: "dueDate < %@", twoWeeksFromNow as CVarArg)
        let objectsWithoutNullDueDates = realm.objects(RLMTask.self).filter("scope = 'Regular' AND completed = false AND removed = false AND dueDate != null").filter(beforeTwoWeeksFromNow).sorted(byKeyPath: "dueDate", ascending: true)
        let objectsWithNullDueDates = realm.objects(RLMTask.self).filter("completed = false AND removed = false AND dueDate = null").sorted(byKeyPath: "dueDate", ascending: true)
        
        let tasks = eventsArray + objectsWithoutNullDueDates.toArray() + objectsWithNullDueDates.toArray()
        //print(tasks.description)
        
        self.ensureEventsInAgendaAreTempVisible(tasksArray: tasks)
        
        return tasks
    }
    
    var completedTodayTasks: Results<RLMTask> { //completed tasks.
        let realm = try! Realm()
        //let predicate = NSPredicate(format: "completionDate >= %@", midnightOfToday as CVarArg)
        let completedTodayTasks = realm.objects(RLMTask.self).filter("completed = true AND completionDate >= %@ AND removed = false", self.earliestTimeToday).sorted(byKeyPath: "completionDate", ascending: false)
        self.ensureEventsInAgendaAreTempVisible(tasksArray: completedTodayTasks.toArray())
        return completedTodayTasks
    }
    
    var extendedTasks: [RLMTask] { //extended tasks. //used to be Results<RLMTask>
        let realm = try! Realm()
        let twoWeeksFromNow = Calendar.current.date(byAdding: .day, value: 15, to: self.earliestTimeToday)!
        let atOrAfterTwoWeeksFromNow = NSPredicate(format: "dueDate >= %@", twoWeeksFromNow as CVarArg)
        //return extendedRegularTasks = realm.objects(RLMTask.self).filter("dateOfExtension != null AND completed = false AND removed = false AND dueDate != null").filter(atOrAfterTwoWeeksFromNow).sorted(byKeyPath: "dueDate", ascending: true)
        let extendedRegularTasks = realm.objects(RLMTask.self).filter("dateOfExtension != null AND scope = 'Regular' AND completed = false AND removed = false AND dueDate != null").filter(atOrAfterTwoWeeksFromNow).sorted(byKeyPath: "dueDate", ascending: true)
        //return extendedRegularTasks//
        
        let afterToday = NSPredicate(format: "dueDate > %@", self.endOfDay as CVarArg)
        let extendedEventTasks = realm.objects(RLMTask.self).filter("dateOfExtension != null AND scope = 'Event' AND completed = false AND removed = false AND dueDate != null").filter(afterToday).sorted(byKeyPath: "dueDate", ascending: true)
        self.ensureEventsInAgendaAreTempVisible(tasksArray: extendedEventTasks.toArray())
        
        let tasks = extendedRegularTasks.toArray() + extendedEventTasks.toArray()
        tasks.sorted(by: { $0.dueDate!.timeIntervalSinceReferenceDate > $1.dueDate!.timeIntervalSinceReferenceDate })
        return tasks
        
    }
    
    func ensureEventsInAgendaAreTempVisible(tasksArray: [RLMTask]) {
        // All event tasks shown in Agenda should have tempVisible = true to fix crashes involving changing event times, due dates, etc.
        // This code also occurs in completed tasks and extended tasks.
        // For example, 1) Create Event w/ start/end times. 2) Put start time to before App Launch time. 3) Remove End Time (crash)
        let realm = try! Realm()
        realm.beginWrite()
        for task in tasksArray {
            if (task.scope == "Event" && task.tempVisible == false) {
                task.tempVisible = true
                task.tempDueDate = task.dueDate
            }
        }
        do {
            try realm.commitWrite()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    let FADED_BLACK_COLOR = UIColor(red: 103/255, green: 103/255, blue: 103/255, alpha: 1.0)
    
    //Dynamic heights cause jerkiness and (rare) misplacement of the sectionHeader. Consider using manually set heights.
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        do {
            //If Realm will cause an error, it will certainly occur at its first 
            //instance which would be here in the initializer.
            try Realm()
        } catch let error {
            self.loadRealmFailedError = error
        }
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        self.earliestTimeToday = calendar.date(from: components)! //Earliest possible date in the current day.
        self.endOfDay = self.generateEndTimeOfToday()
        self.fifteenMinutesBeforeAppLaunch = self.numberOfMinutesBeforeDate(minutes: 15, date: self.timeWhenAppLaunched)
        self.oneHourBeforeAppLaunch = self.numberOfMinutesBeforeDate(minutes: 60, date: self.timeWhenAppLaunched)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 113
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //Disable calendar and discussion TabBarButtonItems.
        self.tabBarController!.tabBar.items?[0].isEnabled = false
        self.tabBarController!.tabBar.items?[0].image = nil //uncomment configureCalendarButton() if these 2 lines are removed.
        self.tabBarController!.tabBar.items?[2].isEnabled = false
        self.tabBarController!.tabBar.items?[2].image = nil //uncomment fillSpeechBubble() if these 2 lines are removed.
        //
        //Hide Sign Up/Login/Profile NavigationBarButtonItem. (TEMPORARY)
        //self.navigationItem.leftBarButtonItem!.isEnabled = false
        //self.navigationItem.leftBarButtonItem!.image = nil
        //
        if (self.loadRealmFailedError == nil) {
            if (self.completedTodayTasks.count == 0) {
                self.sections.removeObject(object: "Completed Today")
            }
            if (self.extendedTasks.count == 0) {
                self.sections.removeObject(object: "Extended")
            }
            self.tableView.dataSource = self
            self.tableView.delegate = self
        } else {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + self.loadRealmFailedError!.localizedDescription + " This is a rare error.", preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
        }
        self.configureCalendarButton()
        self.splitViewController!.view.backgroundColor = UIColor.clear
        self.splitViewController!.delegate = self
        self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        
        //emptyHomescreenView frame set in viewDidLayoutSubviews(..)
        self.emptyHomescreenView = EmptyHomescreenView.construct(self, title: "Let's Make School Easier.", description: "Tap on the Add Course button above to get started!") as EmptyHomescreenView
        self.emptyHomescreenView.translatesAutoresizingMaskIntoConstraints = true
        self.tableView.addSubview(emptyHomescreenView)
        self.emptyHomescreenView.alpha = 0
        if (self.tableView.numberOfRows(inSection: 0) == 0 && self.tableView.numberOfRows(inSection: 1) == 0) {
            self.emptyHomescreenView.alpha = 1
        } else {
            self.tableView.contentInset.top = self.tableView.contentInset.top + 3
            self.tableView.contentInset.bottom = self.tableView.contentInset.bottom + 3
        }
        self.fixIPadContentInsetBug()
        self.prepareAudioPlayers()
        
        let attributedString = NSAttributedString(string: "Clean Up", attributes: [ NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.7) ] )
        refreshControl.attributedTitle = attributedString
        refreshControl.tintColor = UIColor.white.withAlphaComponent(0.35)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        /*if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }*/
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        let cleaningUpAttributedString = NSAttributedString(string: "Cleaning Up..", attributes: [ NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.7) ] )
        refreshControl.attributedTitle = cleaningUpAttributedString
        let realm = try! Realm()
        realm.beginWrite()
        for task in self.extendedTasks {
            task.dateOfExtension = nil
        }
        do {
            try realm.commitWrite()
        } catch let error {
            print(error.localizedDescription)
        }
        self.tableView.beginUpdates()
        self.tableView.reloadData()
        var sectionsToDelete = IndexSet()
        for (index, section) in self.sections.enumerated() {
            if (index != 0) {
                self.sections.removeObject(object: section)
                sectionsToDelete.insert(index)
            }
        }
        self.tableView.deleteSections(sectionsToDelete, with: .none)
        self.tableView.endUpdates()
        
        //Remove Completed Today Section if needed.
        /*self.tableView.beginUpdates()
        if (self.completedTodayTasks.count == 0) {
            if let completedTodaySection = self.sections.first(where: { $0 == "Completed Today" }) {
                let indexOfSection = self.sections.index(of: completedTodaySection)!
                self.sections.removeObject(object: completedTodaySection)
                self.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.tableView.endUpdates()
        //
        
        //Remove Extended Section if needed.
        self.tableView.beginUpdates()
        if (self.extendedTasks.count == 0) {
            if let extendedTasksSection = self.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.sections.index(of: extendedTasksSection)!
                self.sections.removeObject(object: extendedTasksSection)
                self.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.tableView.endUpdates()*/
        //
        // Do your job, when done:
        refreshControl.endRefreshing()
        //let cleanUpAttributedString = NSAttributedString(string: "Clean Up..", attributes: [ NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.7) ] )
        //refreshControl.attributedTitle = cleanUpAttributedString
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (self.refreshControl.isRefreshing == false) {
            let cleanUpAttributedString = NSAttributedString(string: "Clean Up..", attributes: [ NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.7) ] )
            self.refreshControl.attributedTitle = cleanUpAttributedString
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            self.emptyHomescreenView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height - (self.tableView.contentInset.bottom + self.tableView.contentInset.top + self.additionalSafeAreaInsets.top + self.additionalSafeAreaInsets.bottom + self.tabBarController!.tabBar.frame.size.height + self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height))
        } else {
            self.emptyHomescreenView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height - (self.tableView.contentInset.bottom + self.tableView.contentInset.top))
        }
    }
    
    var currentNotification: B4GradNotification? //For NotificationBanners that appear at the bottom of the Agenda for special user events.
        
    func setNotification(notificationType: String, task: RLMTask) {
        self.currentNotification = B4GradNotification(type: notificationType, task: task)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("viewDidAppear(..) executed.")
        if (self.startingSoonTimer == nil) {
            self.startingSoonTimer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(self.startingSoonUpdateText), userInfo: nil, repeats: true)
            RunLoop.current.add(self.startingSoonTimer, forMode: RunLoopMode.commonModes)
        }
        if (self.updateLabelsTimer == nil) {
            self.updateLabelsTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.UpdateDateLabels), userInfo: nil, repeats: true)
            //RunLoop.current.add(self.startingSoonTimer, forMode: RunLoopMode.commonModes)
        }
        if (self.currentNotification == nil) {
            return
        }
        for view in self.view.subviews {
            if (view is NotificationBannerView) {
                let bannerNotificationView = view as! NotificationBannerView
                UIView.animate(withDuration: 0.65, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: { bannerNotificationView.alpha = 0.0; bannerNotificationView.visualEffectView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) }, completion: { Void in bannerNotificationView.removeFromSuperview() })
                bannerNotificationView.timer.invalidate()
            }
        }
        let bannerTimer = Timer.scheduledTimer(timeInterval: 9.0, target: self, selector: #selector(closeBannerNotification), userInfo: nil, repeats: false)
        RunLoop.current.add(bannerTimer, forMode: RunLoopMode.commonModes)
        let bannerNotificationView = NotificationBannerView.construct(self, title: self.currentNotification!.title, description: "", timer: bannerTimer) as NotificationBannerView
        bannerNotificationView.notificationObject = self.currentNotification
        bannerNotificationView.delegate = self
        self.currentNotification = nil
        bannerNotificationView.alpha = 0.0
        bannerNotificationView.visualEffectView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        bannerNotificationView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(bannerNotificationView)
        UIView.animate(withDuration: 0.65, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: { bannerNotificationView.alpha = 1.0; bannerNotificationView.visualEffectView.transform = CGAffineTransform.identity }, completion: nil)
    }
    
    @objc func closeBannerNotification(timer: Timer) {
        for view in self.view.subviews {
            if (view is NotificationBannerView) {
                let bannerNotificationView = view as! NotificationBannerView
                UIView.animate(withDuration: 0.65, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: { bannerNotificationView.alpha = 0.0; bannerNotificationView.visualEffectView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) }, completion: { Void in bannerNotificationView.removeFromSuperview() })
                timer.invalidate()
                return
            }
        }
    }
    
    func notificationBannerViewButtonTapped(_ b4GradNotification: B4GradNotification) {
        if (b4GradNotification.type == "DueDateFarAway") {
            let coursesNavVC = self.storyboard!.instantiateViewController(withIdentifier: "CourseSelection.CoursesNavigationViewController") as! CoursesNavigationViewController
            coursesNavVC.modalPresentationStyle = .formSheet
            coursesNavVC.navigationBar.tintColor = UIColor.white
            let courseVC = coursesNavVC.viewControllers[0] as! CoursesViewController
            courseVC.homeVC = self
            var indexOfCourse : Int?
            for course in courseVC.coursesQuery {
                if (course.id == b4GradNotification.task.course?.id) {
                    indexOfCourse = courseVC.coursesQuery.index(of: course)
                }
            }
            self.present(coursesNavVC, animated: true, completion: {
                if (indexOfCourse != nil && courseVC.coursesQuery.count > indexOfCourse!) {
                    courseVC.tableView.selectRow(at: IndexPath(row: indexOfCourse!, section: 0), animated: true, scrollPosition: .none)
                    courseVC.tableView(courseVC.tableView, didSelectRowAt: IndexPath(row: indexOfCourse!, section: 0))
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) { //Subclassing the UITableView as B4GradTableView is what makes the animation work for cells that have subviews intended to change color.
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if (self.splitViewController!.isCollapsed == false) {
            /*let detailVC = self.splitViewController!.viewControllers[1]
            if (self.lastSelectedRowIndexPath != nil && self.splitViewController!.viewControllers[1].isKindOfClass(UITabBarController) == true) {
                print("row is selected")
                self.tableView.selectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true, scrollPosition: .None)
            }*/
        }
    }
    
    @IBAction func profileButtonTapped(_ sender: AnyObject) {
        let userIsAnonymous = PFAnonymousUtils.isLinked(with: PFUser.current())
        print(PFUser.current()?.username ?? "")
        print(PFUser.current()?.email ?? "")
        print(PFUser.current()?.createdAt ?? "")
        if (userIsAnonymous == true) {
            let signUpVC = self.storyboard!.instantiateViewController(withIdentifier: "Profile.SignUpNavigationController") as! UINavigationController
            signUpVC.modalPresentationStyle = .formSheet
            self.present(signUpVC, animated: true, completion: { })
        } else {
            let accountVC = self.storyboard!.instantiateViewController(withIdentifier: "Profile.ProfileNavigationController") as! UINavigationController
            accountVC.modalPresentationStyle = .formSheet
            self.present(accountVC, animated: true, completion: { })
        }
    }
    
    func configureCalendarButton() { //Look in viewDidLoad(..) on how to enable this button again.
        /*let components = (Calendar.current as NSCalendar).components([.day, .month, .year], from: Date())
        let day = components.day
        let calendarImageName = "Calendar " + String(day!)
        self.tabBarController!.tabBar.items?[0].image = UIImage(named: calendarImageName)
        self.tabBarController!.tabBar.items?[0].selectedImage = UIImage(named: calendarImageName)*/
    }
    
    //Network call checks if new items are avail, then fill speech bubble if true.
    func fillSpeechBubble() { //Look in viewDidLoad(..) on how to enable this button again.
        /*if (self.tabBarController!.tabBar.selectedItem != self.tabBarController!.tabBar.items?[2]) {
            let secondItemView = self.tabBarController!.tabBar.subviews[2] //The array gets modified by UIKit if other changes are made to UITabBar.
            let secondItemImageView = secondItemView.subviews.first as! UIImageView
            secondItemImageView.contentMode = .center
            //self.tabBarController!.tabBar.items![2].image = UIImage(named: "Speech Bubble Filled")
            UIView.transition(with: secondItemImageView, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { secondItemImageView.image = UIImage(named: "Speech Bubble Filled") }, completion: nil)
        }*/
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        //Since splitViewController!.showViewController changes secondaryViewController to no longer be a UINavigationController, this must first be checked for there to even be a BlankVC.
        //print("collapse occurred.")
        if let secondaryNavController = secondaryViewController as? UINavigationController {
            let bottomSecondaryView = secondaryNavController.viewControllers.first
            if (bottomSecondaryView == nil) {
                return true
            }
            if (bottomSecondaryView!.isKind(of: BlankViewController.self)) {
                return true
            }
            
            let masterVC = primaryViewController as! UITabBarController
            let navController = masterVC.selectedViewController! as! UINavigationController
            navController.viewControllers.append(bottomSecondaryView!)
            if (secondaryNavController.viewControllers.count != 0) {
                for index in 0...(secondaryNavController.viewControllers.count - 1) {
                    let vc = secondaryNavController.viewControllers[index]
                    navController.pushViewController(vc, animated: false)
                }
            }
            return true
        }
        
        return false
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        let masterVC = splitViewController.viewControllers[0] as! UITabBarController
        //print("showDetailVC")
        if splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact {
            masterVC.selectedViewController?.show(vc, sender: sender)
        } else {
            let navController = self.storyboard!.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
            if let detailNavController = splitViewController.viewControllers[1] as? UINavigationController {
                if (sender == nil || ((sender! as AnyObject).isDescendant(of: detailNavController.view) == true || (sender! as AnyObject).isDescendant(of: detailNavController.visibleViewController!.view) == true)) {
                    detailNavController.pushViewController(vc, animated: true)
                    return true
                }
            }
            navController.viewControllers = [vc]
            splitViewController.viewControllers = [masterVC, navController]
        }
        return true
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        let masterVC = splitViewController.viewControllers[0] as! UITabBarController
        //print("separateSecondVCFromPrimaryVC")
        if let navController = masterVC.selectedViewController as? UINavigationController {
            if navController.viewControllers.count > 1 {
                let poppedVC = navController.popViewController(animated: false)!
                if (poppedVC is UINavigationController) {
                    return poppedVC
                } else {
                    let newNavController = self.storyboard!.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
                    if (navController.viewControllers.count > 1) {
                        newNavController.viewControllers = []
                        newNavController.viewControllers.append(contentsOf: navController.popToRootViewController(animated: false)!)
                        newNavController.pushViewController(poppedVC, animated: false)
                    } else {
                        newNavController.viewControllers = [poppedVC]
                    }
                    
                    return newNavController
                }
            }
        }
        
        return self.storyboard!.instantiateViewController(withIdentifier: "BlankTabBarController") as! UITabBarController
        //return nil //(w/o UITabBarController)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
        /*if (self.completedTodayTasks.count != 0) {
            if (self.extendedTasks.count != 0) {
                return 3
            } else {
                return 2
            }
        } else {
            if (self.extendedTasks.count != 0) {
                return 2
            } else {
                return 1
            }
        }
        print("numberOfSections(..) inaccurate.")
        return self.sections.count*/
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.activeTasks.count == 0 && self.completedTodayTasks.count == 0 && self.extendedTasks.count == 0) {
            self.handleEmptyTableView()
            return 0
        }
        if (self.emptyHomescreenView.alpha == 1) {
            UIView.animate(withDuration: 0.3, delay: 0.2, options: UIViewAnimationOptions.curveEaseOut, animations: { self.emptyHomescreenView.alpha = 0 }, completion: nil)
        }
        let sectionName = self.sections[section]
        if (sectionName == "") { return self.activeTasks.count }
        if (sectionName == "Completed Today") { return self.completedTodayTasks.count }
        if (sectionName == "Extended") { return self.extendedTasks.count }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = self.tasks(inSection: indexPath.section)[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTableViewCell", for: indexPath) as! HomeworkTableViewCell
        cell.task = task
        cell.delegate = self
        //cell.titleLabel.attributedText = NSAttributedString(string: task.name, attributes: cell.titleLabel.attributedText?.attributes(at: 0, effectiveRange: nil))
        
        CellCustomizer.cellForRowCustomization(task: task, cell: cell, taskManager: self)
        
        // Logic for cells changing text corresponding to a timer.
        //if (task == startingSoonTask && cell.dateLabel.text != "Starting Soon..") {
            
        //}
        if (cell.dateLabel.text == "Starting Soon.." && startingSoonTask == nil) {
            startingSoonTask = task
            startingSoonText = cell.dateLabel.text
        }
        //
        
        /*cell.titleLabel.text = task.name
        if (task.course == nil) {
            cell.colorView.color = UIColor.darkGray
            cell.courseLabel.text = "N/A"
            cell.homeworkImageView.image = UIImage(named: task.type + String(0))
        } else {
            cell.homeworkImageView.image = UIImage(named: task.type + String(task.course!.colorStaticValue))
            //cell.colorView.color = UIColor(red: 43/255, green: 132/255, blue: 210/255, alpha: 1.0)
            cell.colorView.color = task.course?.color?.getUIColorObject()
            if (task.course?.courseCode != nil) {
                cell.courseLabel.text = task.course?.courseCode
            } else {
                cell.courseLabel.text = task.course?.courseName
            }
            if (task.course?.facultyName != nil) {
                cell.facultyImageView.image = UIImage(named: task.course!.facultyName!)
            }
        }
        if (task.dueDate == nil) {
            if (task.type == "Assignment") {
                cell.dueDateLabel.text = "No due date."
                cell.dateLabel.text = "Due anytime."
            } else {
                cell.dueDateLabel.text = "No date."
                cell.dateLabel.text = "Happens anytime."
            }
        } else {
            if (task.type == "Assignment") {
                cell.dueDateLabel.text = task.dueDate!.toRemainingDaysString()
            } else {
                var remainingDaysString = task.dueDate!.toRemainingDaysString()
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                remainingDaysString.remove(at: remainingDaysString.startIndex)
                cell.dueDateLabel.text = "Scheduled" + remainingDaysString
                if (task.timeSet == true && task.dueDate != nil) {
                    let timeString = DateFormatter.localizedString(from: task.dueDate! as Date, dateStyle: .none, timeStyle: .short)
                    remainingDaysString = remainingDaysString.substring(to: remainingDaysString.index(before: remainingDaysString.endIndex))
                    remainingDaysString += (" at " + timeString + ".")
                    if (task.dueDate!.numberOfDaysUntilDate() == 0 || task.dueDate!.numberOfDaysUntilDate() == 1 || task.dueDate!.numberOfDaysUntilDate() == -1) {
                        remainingDaysString.remove(at: remainingDaysString.startIndex)
                        cell.dueDateLabel.text = remainingDaysString
                    } else {
                        cell.dueDateLabel.text = "Scheduled" + remainingDaysString
                    }
                }
            }
            cell.dateLabel.text = task.dueDate!.toReadableString()
            if (task.dueDate!.overScopeThreshold(task: task)) {
                cell.cardView.alpha = 0.7
            } else {
                cell.cardView.alpha = 1.0
            }
        }
        //prepareForReuse(..) implemented in Cell Custom Subclass to reset cell state.
        if (task.completed) {
            cell.leadingCompletionConstraint.constant = 32
            cell.bringSubview(toFront: cell.completionImageView)
            strikeThroughLabel(cell.titleLabel)
            strikeThroughLabel(cell.courseLabel)
            strikeThroughLabel(cell.dueDateLabel)
            strikeThroughLabel(cell.dateLabel)
            cell.titleLabel.textColor = FADED_BLACK_COLOR
            cell.courseLabel.textColor = FADED_BLACK_COLOR
            cell.dueDateLabel.textColor = FADED_BLACK_COLOR
            cell.dateLabel.textColor = FADED_BLACK_COLOR
            cell.completionImageView.layer.shadowRadius = 0.5
            cell.completionImageView.layer.shadowOpacity = 1.0
            cell.completionImageView.image = #imageLiteral(resourceName: "Green Checkmark")
        }*/
        
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
    
    var startingSoonTimer: Timer!
    var startingSoonTask: RLMTask!
    var startingSoonText: String!
    @objc func startingSoonUpdateText() {
        /*let tasksInSection1 = self.tasks(inSection: 0)
        for task in tasksInSection1 {
            
        }*/
        var startingSoonIndex: IndexPath?
        if (startingSoonTask != nil) { startingSoonIndex = self.indexOfTask(task: startingSoonTask) }
        if (startingSoonIndex == nil) { return }
        let cell = self.tableView.cellForRow(at: startingSoonIndex!) as? HomeworkTableViewCell
        //print(startingSoonText)
        if ((cell?.dateLabel.text != "Starting Soon." && cell?.dateLabel.text != "Starting Soon.." && cell?.dateLabel.text != "Starting Soon...") && startingSoonText != nil) { return }
        if (startingSoonText == "Starting Soon..") { cell?.dateLabel.attributedText = NSAttributedString(string: "Starting Soon...", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil)); startingSoonText = "Starting Soon..."; return }
        if (startingSoonText == "Starting Soon...") { cell?.dateLabel.attributedText = NSAttributedString(string: "Starting Soon.", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil)); startingSoonText = "Starting Soon."; return }
        if (startingSoonText == "Starting Soon.") { cell?.dateLabel.attributedText = NSAttributedString(string: "Starting Soon..", attributes: cell?.dateLabel.attributedText?.attributes(at: 0, effectiveRange: nil)); startingSoonText = "Starting Soon.."; return }
    }
    
    var updateLabelsTimer: Timer!
    @objc func UpdateDateLabels() {
        let indexPathsForVisibleCells = self.tableView.indexPathsForVisibleRows
        if (indexPathsForVisibleCells == nil) { return }
        self.tableView.beginUpdates()
        for indexPath in indexPathsForVisibleCells! {
            if let hwCell = self.tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell {
                if (hwCell.isSelected == false) {
                    let task = self.tasks(inSection: indexPath.section)[indexPath.row]
                    if (task.dueDate == nil) { continue }
                    let numberOfMinutesUntilDueDate = (task.dueDate! as NSDate).numberOfMinutesUntilDate()
                    let numberOfSecondsUntilDueDate = numberOfMinutesUntilDueDate * 60
                    //Skip cells 'Starting Soon..' as the animation relies on cellForRow to begin which messes with animation. This behaviour will change cell's label only when it is no longer 'Starting Soon..'
                    if ((task.type == "Quiz" || task.type == "Midterm" || task.type == "Final" || task.scope == "Event") && (numberOfSecondsUntilDueDate <= 3600 && numberOfSecondsUntilDueDate > 0)) { continue }
                    CellCustomizer.customizeHWCellAppearanceBasedOnDate(date: task.dueDate as Date?, task: task, cell: hwCell, taskManager: self)
                    hwCell.cardView.backgroundColor = UIColor.white
                }
            }
        }
        self.tableView.endUpdates()
      //  self.tableView.reloadData()
        //print("Update Labels Method executed.")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName = self.sections[section]
        if (sectionName == "") {
            return nil
        }
        if (sectionName != "") {
            return sectionName
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionName = self.sections[section]
        if (sectionName == "") {
            return nil
        }
        if (sectionName != "") {
            let sectionHeader = TransparentSectionHeaderView.construct(sectionName, owner: tableView)
            return sectionHeader
        }
        return nil
        /*if (self.sections[section] == "Completed Today") {
            let sectionHeader = TransparentSectionHeaderView.construct("Completed Today", owner: tableView)
            return sectionHeader
        }
        return nil*/
    }
    
    //The following method is implemented purely because of the newly changed behaviour for section headers in iOS11.
    //https://stackoverflow.com/questions/46594585/how-can-i-hide-section-headers-in-ios-11/46634556#46634556
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            //return CGFloat.leastNormalMagnitude // causes crash if reloadSections(..) is called, so DO NOT USE.
            return 0 // This works fine.
        }
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear //A bug only in iPad version of app.
        
        //Bug Solution (read more below)
        let height = cell.frame.size.height
        self.heightAtIndexPath[indexPath] = height
        //
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Bug Solution (read more below)
        let height = cell.frame.size.height
        self.heightAtIndexPath[indexPath] = height
        //    
    }
    
    @IBAction func coursesBarButtonItemTapped(_ sender: AnyObject) {
        let coursesNavVC = self.storyboard!.instantiateViewController(withIdentifier: "CourseSelection.CoursesNavigationViewController") as! CoursesNavigationViewController
        coursesNavVC.modalPresentationStyle = .formSheet
        coursesNavVC.navigationBar.tintColor = UIColor.white
        let courseVC = coursesNavVC.viewControllers[0] as! CoursesViewController
        courseVC.homeVC = self
        self.present(coursesNavVC, animated: true, completion: nil)
        
        //For showing the SearchViewController for searching courses combined with the original VC, simply uncomment the code below! (But also comment the code above.)
        /*let searchNavigationViewController = self.storyboard!.instantiateViewController(withIdentifier: "SearchNavigationViewController") as! SearchNavigationViewController
        searchNavigationViewController.modalPresentationStyle = .formSheet
        searchNavigationViewController.navigationBar.tintColor = UIColor.white
        searchNavigationViewController.viewControllers.insert(self.storyboard!.instantiateViewController(withIdentifier: "CourseSelection.CoursesViewController"), at: 0)
        self.present(searchNavigationViewController, animated: true, completion: { })*/
        
        //When # of courses = 0, then just go straight to searchVC. (Maybe)
    }
    
    func handleEmptyTableView() { //The placeholder shown when the Agenda has no tasks to show.
        //self.emptyHomescreenView.alpha = 0
        //self.emptyHomescreenView.hidden = false
        let realm = try! Realm()
        let courses = realm.objects(RLMCourse.self)
        //let eventsWithStartTimesAndEndTimes = realm.objects(RLMTask.self).filter("scope = 'Event' AND completed = false AND removed = false AND dueDate != null AND tempVisible = false").filter(eventsWithEndTimesAfter_CVarArg).filter(eventsWithStartTimesBeforeEndOfDay).sorted(byKeyPath: "dueDate", ascending: true)
        if (courses.count == 0) {
            self.emptyHomescreenView.mainTitleLabel.text = "Let's Make School Easier."
            self.emptyHomescreenView.descriptionLabel.text = "Tap on the Add Course button above to get started!"
            self.emptyHomescreenView.arrowImageView.image = #imageLiteral(resourceName: "Brush Arrow")
        } else {
            self.emptyHomescreenView.mainTitleLabel.text = "No Upcoming Tasks."
            self.emptyHomescreenView.descriptionLabel.text = "You also have no more Classes Today!"
            self.emptyHomescreenView.arrowImageView.image = nil
        }
        
        if (self.emptyHomescreenView.alpha != 1) {
            UIView.animate(withDuration: 0.8, delay: 0.2, options: UIViewAnimationOptions.curveEaseOut, animations: { self.emptyHomescreenView.alpha = 1 }, completion: nil)
        }
    }
    
    // MARK: - HomeworkTableViewCellDelegate
    
    func taskDeleted(_ task: RLMTask) {
        let indexPathForRow = self.indexOfTask(task: task)!
        
        var cellWasSelected = false
        if (tableView.cellForRow(at: indexPathForRow)!.isSelected == true) {
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
        
        // use the UITableView to animate the removal of this row
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPathForRow], with: .left)
        tableView.endUpdates()
        
        playDeleteSound()
        
        //Remove Completed Today Section if needed.
        self.tableView.beginUpdates()
        if (self.completedTodayTasks.count == 0) {
            if let completedTodaySection = self.sections.first(where: { $0 == "Completed Today" }) {
                let indexOfSection = self.sections.index(of: completedTodaySection)!
                self.sections.removeObject(object: completedTodaySection)
                self.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.tableView.endUpdates()
        //
        
        //Remove Extended Section if needed.
        self.tableView.beginUpdates()
        if (self.extendedTasks.count == 0) {
            if let extendedTasksSection = self.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.sections.index(of: extendedTasksSection)!
                self.sections.removeObject(object: extendedTasksSection)
                self.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.tableView.endUpdates()
        //
        
        if (splitViewController!.isCollapsed == false && cellWasSelected == true) {
            self.splitViewController!.viewControllers[1] = self.storyboard!.instantiateViewController(withIdentifier: "BlankTabBarController")
        }
        if (self.splitViewController!.viewControllers.count <= 1) {
            return
        }
        if (self.splitViewController!.viewControllers[1] is CellEditingTableViewController || (self.splitViewController!.viewControllers[1] as? UINavigationController)?.topViewController is CellEditingTableViewController) {
            if let cellEditingVC = self.splitViewController!.viewControllers[1] as? CellEditingTableViewController {
                if (cellEditingVC.helperObject.task.id == task.id) {
                    self.splitViewController!.viewControllers[1] = self.storyboard!.instantiateViewController(withIdentifier: "BlankTabBarController")
                }
            } else {
                let cellEditingVC = (self.splitViewController!.viewControllers[1] as! UINavigationController).topViewController as! CellEditingTableViewController
                if (cellEditingVC.helperObject.task.id == task.id) {
                    self.splitViewController!.viewControllers[1] = self.storyboard!.instantiateViewController(withIdentifier: "BlankTabBarController")
                }
            }
        }
    }
    
    func taskCompleted(_ task: RLMTask) {
        let indexPath = self.indexOfTask(task: task)!
        let section = indexPath.section
        let index = indexPath.row
        
        if (task.completed != true) {
            let indexPathForRow = IndexPath(row: index, section: section)
            let cell = tableView.cellForRow(at: indexPathForRow) as? HomeworkTableViewCell
            cell?.leadingCompletionConstraint.constant = 32
            strikeThroughLabel(cell?.titleLabel)
            strikeThroughLabel(cell?.courseLabel)
            strikeThroughLabel(cell?.dueDateLabel)
            strikeThroughLabel(cell?.dateLabel)
            //Fixes minor display bug on completion in iOS9 and earlier.
            cell?.cardView.sizeToFit()
            //
            /*if (section == 1) {
                cell?.titleLabel.textColor = FADED_BLACK_COLOR
                cell?.courseLabel.textColor = FADED_BLACK_COLOR
                cell?.dueDateLabel.textColor = FADED_BLACK_COLOR
                cell?.dateLabel.textColor = FADED_BLACK_COLOR
            }*/
            cell?.completionImageView.layer.shadowRadius = 0.5
            cell?.completionImageView.layer.shadowOpacity = 1.0
            playCompletedSound()
            
        } else {
            let indexPathForRow = IndexPath(row: index, section: section)
            let cell = tableView.cellForRow(at: indexPathForRow) as? HomeworkTableViewCell
            cell?.leadingCompletionConstraint.constant = -60
            unstrikeThroughLabel(cell?.titleLabel)
            unstrikeThroughLabel(cell?.courseLabel)
            unstrikeThroughLabel(cell?.dueDateLabel)
            unstrikeThroughLabel(cell?.dateLabel)
            cell?.titleLabel.textColor = UIColor.black
            cell?.courseLabel.textColor = UIColor.black
            cell?.dueDateLabel.textColor = UIColor.black
            cell?.dateLabel.textColor = UIColor.black
            cell?.completionImageView.image = UIImage(named: "Grey Checkmark")
            cell?.completionImageView.layer.shadowRadius = 3.0
            cell?.completionImageView.layer.shadowOpacity = 0.25
            cell?.repeatsImageView.image = #imageLiteral(resourceName: "Black Repeats")
            //cell.cardView.alpha = 1.0
            playNotCompletedSound()
        }
    }
    
    func moveTask(_ cell: HomeworkTableViewCell, _ task: RLMTask) {
        var indexPath = self.indexOfTask(task: task)!
        /*var row: Int?
        var section = 0
        row = self.activeTasks.index(of: task)
        if (row == nil) {
            row = self.completedTodayTasks.index(of: task)
            section = 1
        }
        let indexPath = IndexPath(row: row!, section: section)*/
        
        //Add Completed Today Section if needed.
        self.tableView.beginUpdates()
        if (task.completed == false && self.completedTodayTasks.count == 0) {
            if self.sections.first(where: { $0 == "Completed Today" }) == nil {
                self.sections.insert("Completed Today", at: 1)
                self.tableView.insertSections([1], with: .automatic)
            }
            //The following code allows for the Completed/Extended Sections to be 'replaced' - in the case that one is removed for the other.
            if (task.dueDate != nil) {
                if (self.completedTodayTasks.count == 0 && (task.dueDate! as Date).overScopeThreshold(task: task)) {
                    indexPath.section += 1
                }
            }
            //
        }
        self.tableView.endUpdates()
        //
        
        //Add Extended Section if needed.
        self.tableView.beginUpdates()
        if (task.dueDate?.overScopeThreshold(task: task) == true && self.extendedTasks.count == 0) {
            if self.sections.first(where: { $0 == "Extended" }) == nil && self.sections.first(where: { $0 == "Completed Today" }) == nil {
                self.sections.insert("Extended", at: 1)
                self.tableView.insertSections([1], with: .automatic)
            } else if self.sections.first(where: { $0 == "Extended" }) == nil && self.sections.first(where: { $0 == "Completed Today" }) != nil {
                self.sections.insert("Extended", at: 2)
                self.tableView.insertSections([2], with: .automatic)
            }
        }
        self.tableView.endUpdates()
        //
        
        let realm = try! Realm()
        realm.beginWrite()
        task.completed = !task.completed
        if (task.completed == true) { task.completionDate = NSDate() } else { task.completionDate = nil }
        //The following if statement exists purely to cover the following scenario: Completed task that had its due date extended to over two weeks from now since it was completed is now uncompleted. It doesn't go to extended section w/o setting property.
        if (task.dueDate != nil && task.dueDate!.overScopeThreshold(task: task) && task.dateOfExtension == nil) {
            if (task.completed == false) {
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
        
        let newIndexPath = self.indexOfTask(task: task)! //Can crash here if the current day changes (goes from 11:59PM to 12:00AM) when completing/modifying tasks.
        /*if (self.completedTodayTasks.count == 0) {
            newIndexPath.section += 1
        }*/
        
        UIView.animate(withDuration: 0.27, delay: 0.0, options: [], animations: {
            self.tableView.beginUpdates()
            self.tableView.moveRow(at: indexPath, to: newIndexPath)
            if (task.completed == true) {
                cell.titleLabel.textColor = self.FADED_BLACK_COLOR
                cell.courseLabel.textColor = self.FADED_BLACK_COLOR
                cell.dueDateLabel.textColor = self.FADED_BLACK_COLOR
                cell.dateLabel.textColor = self.FADED_BLACK_COLOR
                cell.repeatsImageView.image = #imageLiteral(resourceName: "Grey Repeats")
            }
            self.tableView.endUpdates()
        }, completion: nil)
        
        //Remove Completed Today Section if needed.
        self.tableView.beginUpdates()
        if (self.completedTodayTasks.count == 0) {
            if let completedTodaySection = self.sections.first(where: { $0 == "Completed Today" }) {
                let indexOfSection = self.sections.index(of: completedTodaySection)!
                self.sections.removeObject(object: completedTodaySection)
                self.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.tableView.endUpdates()
        //
        
        //Remove Extended Section if needed.
        self.tableView.beginUpdates()
        if (self.extendedTasks.count == 0) {
            if let extendedTasksSection = self.sections.first(where: { $0 == "Extended" }) {
                let indexOfSection = self.sections.index(of: extendedTasksSection)!
                self.sections.removeObject(object: extendedTasksSection)
                self.tableView.deleteSections([indexOfSection], with: .fade)
            }
        }
        self.tableView.endUpdates()
        //
    }
    
    //
    
    //**Solves the odd tableView scrollView offset bug that occurs when tableView.beginUpdates(..) and tableView.endUpdates(..) get called.**
    //http://stackoverflow.com/a/33397350/6051635
    //Rest of solution in: tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    
    var heightAtIndexPath = Dictionary<IndexPath, CGFloat>()
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.heightAtIndexPath[indexPath]//.object(forKey: indexPath)
        if ((height) != nil) {
            return CGFloat((height! as AnyObject).floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    //**End of Bug Solution.**

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HomeworkTableViewCell
        cell?.cardView.backgroundColor = UIColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 1.0)
        //performSegue(withIdentifier: "showDetail", sender: indexPath)
        self.lastSelectedRowIndexPath = indexPath
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
    
    func strikeThroughLabel(_ label: UILabel?) {
        if (label == nil) { return }
        let attributedString = NSMutableAttributedString(string: label!.text!, attributes: [NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue])
        attributedString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSMakeRange(0, attributedString.length))
        label!.attributedText = attributedString
    }
    
    /*func strikeThroughCapitalLabel(label: UILabel) {
        let attributedString = NSAttributedString(string: label.text!, attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle(rawValue: 4)!.rawValue])
        label.attributedText = attributedString
    }*/
    
    func unstrikeThroughLabel(_ label: UILabel?) {
        if (label == nil) { return }
        let attributedString = NSAttributedString(string: label!.text!, attributes: [:])
        label!.attributedText = attributedString
    }
    
    func generateEndTimeOfToday() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        let startOfDay = calendar.date(from: components)!
        
        var endOfDayComponents = DateComponents()
        endOfDayComponents.day = 1
        let date = Calendar.current.date(byAdding: endOfDayComponents, to: startOfDay)!
        return (date.addingTimeInterval(-1))
    }
    
    func numberOfMinutesBeforeDate(minutes: Int, date: Date) -> Date {
        let newDate = Calendar.current.date(byAdding: .minute, value: -minutes, to: date)!
        return newDate
    }
    
    //AVAudioPlayer Handling
    
    let completedSound = URL(fileURLWithPath: Bundle.main.path(forResource: "Completed", ofType: "wav")!)
    let notCompletedSound = URL(fileURLWithPath: Bundle.main.path(forResource: "NotCompleted", ofType: "wav")!)
    let deleteSound = URL(fileURLWithPath: Bundle.main.path(forResource: "Delete", ofType: "wav")!)
    var completedSoundPlayers = [AVAudioPlayer](), notCompletedSoundPlayers = [AVAudioPlayer](), deleteSoundPlayers = [AVAudioPlayer]()
    
    func prepareAudioPlayers() {
        do {
            for _ in 0...(self.tasks(inSection: 0).count + self.tasks(inSection: 1).count + 5) { //for each cell, create one of each AudioPlayers.
            
                let completedSoundPlayer = try AVAudioPlayer(contentsOf: completedSound)
                completedSoundPlayer.volume = 0.38
                completedSoundPlayer.delegate = self
                completedSoundPlayer.prepareToPlay()
                
                let notCompletedSoundPlayer = try AVAudioPlayer(contentsOf: notCompletedSound)
                completedSoundPlayer.volume = 0.25
                notCompletedSoundPlayer.delegate = self
                notCompletedSoundPlayer.prepareToPlay()
                
                let deleteSoundPlayer = try AVAudioPlayer(contentsOf: deleteSound)
                completedSoundPlayer.volume = 0.38
                deleteSoundPlayer.delegate = self
                deleteSoundPlayer.prepareToPlay()
                    
                completedSoundPlayers.append(completedSoundPlayer)
                notCompletedSoundPlayers.append(notCompletedSoundPlayer)
                deleteSoundPlayers.append(deleteSoundPlayer)
            }
        } catch {
            print("Error getting the audio file(s)")
        }
    }
    
    func playCompletedSound() {
        //get soundplayer from correct array, then play it if it is available.
        for soundPlayer in completedSoundPlayers {
            if (soundPlayer.isPlaying == false) {
                soundPlayer.play()
                break
            }
        }
    }
    
    func playNotCompletedSound() {
        //get soundplayer from correct array, then play it if it is available.
        for soundPlayer in notCompletedSoundPlayers {
            if (soundPlayer.isPlaying == false) {
                soundPlayer.play()
                break
            }
        }
    }
    
    func playDeleteSound() {
        //get soundplayer from correct array, then play it if it is available.
        for soundPlayer in deleteSoundPlayers {
            if (soundPlayer.isPlaying == false) {
                soundPlayer.play()
                break
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (flag == true) {
            player.prepareToPlay()
        }
    }
    
    /*
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        
    }*/
    
    //
    
    func fixIPadContentInsetBug() {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            self.automaticallyAdjustsScrollViewInsets = false
            self.tableView.contentInset.top = self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height + 4
            self.tableView.contentInset.bottom = self.tabBarController!.tabBar.frame.size.height + 4
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        let cellEditingVC = self.storyboard!.instantiateViewController(withIdentifier: "CellEditingVC") as! CellEditingTableViewController
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
        //create task (but don't save it yet)
        let newTask = RLMTask(name: "Assignment", type: "Assignment", dueDate: nil, course: nil)
        
        cellEditingVC.helperObject = HomeworkCellEditingHelperObject(cellEditingTVC: cellEditingVC, task: newTask, taskManagerVC: self, homeVC: self)
        cellEditingVC.helperObject.mode = TaskEditingMode.Create
        cellEditingVC.helperObject.task = newTask
        cellEditingVC.helperObject.taskManagerVC = self
        navigationController.viewControllers = [cellEditingVC]
        navigationController.modalPresentationStyle = .formSheet
        self.present(navigationController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination.isKind(of: CellEditingTableViewController.self) == false) {
            return
        }
        
        let cellEditingVC = segue.destination as! CellEditingTableViewController
        
        //        if (sender is HomeworkTableViewCell) {
        //let hwCell = sender as! HomeworkTableViewCell

        ///if let index = sender as? IndexPath {
        if let index = self.tableView.indexPathForSelectedRow {
            let task = self.tasks(inSection: index.section)[index.row]

            cellEditingVC.helperObject = HomeworkCellEditingHelperObject(cellEditingTVC: cellEditingVC, task: task, taskManagerVC: self, homeVC: self)
            cellEditingVC.helperObject.dictionary[0]![0].name = task.name
            cellEditingVC.title = task.name
            cellEditingVC.helperObject.task = task
            cellEditingVC.helperObject.taskManagerVC = self
            //handle type information for placeholder like is it assignment versus is it quiz plus then get the number to append to it.
        }

    }
//    }

}
