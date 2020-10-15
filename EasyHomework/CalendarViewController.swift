//
//  ViewController.swift
//  CalendarTutorial
//
//  Created by Jeron Thomas on 2016-10-15.
//  Copyright © 2016 OS-Tech. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
//import JTAppleCalendar



class CalendarViewController: B4GradViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate, UIScrollViewDelegate, UISplitViewControllerDelegate  {
    
    
    
    
    // MARK:- Outlets
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var selectedDatesLabel: UILabel!
    
    
    
    // MARK:- Properties
    
    // Dates which are reserved
    let formatter           = DateFormatter()
    let monthFormatter      = DateFormatter()
    
    var currentDate: (date: Date, indexPath: IndexPath)?
    
    var arrayallRLMTasks:[RLMTask]      = []
    var events:[Any]        	        = []
    var arrayTypesForFilters:[String]   = ["Assignment", "Quiz", "Midterm", "Final"]
    
    var homeVC: HomeworkViewController?
    
    // MARK:- View Life Cycle Starts here...
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureTitleView()
        self.setupView()
        self.calendarView.contentInset.top += 80
        
        //set homeVC instance variable
        self.setHomeVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.checkForCellAnimation()
        self.fetchTasks() ///
    }
    
    var didAnimation = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.fetchTasks()
        
        // Handle Paywall. //
        /*if (UserDefaults.standard.bool(forKey: "isSubscribed") == false && didAnimation == false) {
            self.navigationController!.navigationBar.isUserInteractionEnabled = false
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
            blurVisualEffectView.frame = self.view.frame
            blurVisualEffectView.frame.size = CGSize(width: 2000, height: 2000)
            blurVisualEffectView.center = self.navigationController!.view.center
            
            blurVisualEffectView.effect = nil
            
            let label = UILabel(frame: self.view.frame)
            label.frame.size = CGSize(width: 2000, height: 2000)
            label.center = self.view.center
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 18.0)
            label.text = "Subscribe to Unlock Calendar."
            
            self.navigationController!.view.addSubview(blurVisualEffectView)
            
            self.navigationController!.view.addSubview(label)
            
            label.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            label.alpha = 0
            
            UIView.animate(withDuration: 0.5, animations: {
                blurVisualEffectView.effect = blurEffect
                label.alpha = 1
                label.transform = CGAffineTransform.identity
            }) { (true) in
                let storyboard = UIStoryboard(name: "Subscription", bundle: nil)
                let subscriptionPlansVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlansViewController")
                self.present(subscriptionPlansVC, animated: true, completion: nil)
            }
            didAnimation = true
        }*/
        // //

    }
    
    /*override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupView()
    }*/
    
    // MARK:- Setup View
    func setupView() {
        self.configureView()
        self.setupCalendar()
    }
    
    func configureView() {
        // Disable default swipe gesture
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled   = true
        self.navigationController?.isNavigationBarHidden                        = false
        
        self.formatter.dateFormat                   = "yyyy MM dd"
        self.monthFormatter.dateFormat              = "MMMM yyyy"
        
        //Setup Split View Controller
        self.extendedLayoutIncludesOpaqueBars           = true
        self.splitViewController!.view.backgroundColor  = UIColor.clear
        self.splitViewController!.preferredDisplayMode  = UISplitViewControllerDisplayMode.allVisible
    }
    
    override func awakeFromNib() { //since iOS 13
        self.splitViewController!.delegate              = self
    }
    
    func setupCalendar() {
        self.calendarView.minimumInteritemSpacing   = 0
        self.calendarView.minimumLineSpacing        = 0
        self.calendarView.allowsMultipleSelection   = false
        self.calendarView.isRangeSelectionUsed      = false
        self.calendarView.scrollDirection           = .vertical
        self.calendarView.scrollingMode             = ScrollingMode.none
        self.calendarView.calendarDataSource        = self
        self.calendarView.calendarDelegate          = self
        self.calendarView.cellSize                  = CGFloat(75)
        //self.calendarView.delaysContentTouches = false //doesn't work
        
        // change cell
        self.calendarView.register(UINib(nibName: "CellView1", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.calendarView.register(UINib(nibName: "PinkSectionHeaderView", bundle: nil),
                                   forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    
    
    
    func fetchTasks() {
        let realm = try! Realm()
        
        var arrayPredicates:[NSPredicate] = []
        for i in 0..<self.arrayTypesForFilters.count {
            let predicateForTasks   = NSPredicate(format: "type == %@", self.arrayTypesForFilters[i])
            arrayPredicates.append(predicateForTasks)
        }
        
        let predicateForNotDeletedTasks     = NSPredicate(format: "removed == false")
//        let predicateForNoMasterTask_Task   = NSPredicate(format: "repeatingSchedule.masterTask == nil")
//        let predicateForNoMasterTask        = NSPredicate(format: "masterTask == nil")
        
        let compoundPredicate   = NSCompoundPredicate.init(orPredicateWithSubpredicates: arrayPredicates)
        let allEvents           = realm.objects(RLMTask.self)
        var filteredEvents      = allEvents.filter(compoundPredicate)
        filteredEvents          = filteredEvents.filter(predicateForNotDeletedTasks)
//        filteredEvents          = filteredEvents.filter(predicateForNoMasterTask_Task)
        self.events             = filteredEvents.toArray()
        self.arrayallRLMTasks   = filteredEvents.toArray()
        
        let allRepeatingEvents      = realm.objects(RLMRepeatingSchedule.self)
        let filteredRepeatingEvents = allRepeatingEvents.filter(compoundPredicate)
//        filteredRepeatingEvents     = filteredRepeatingEvents.filter(predicateForNoMasterTask)
//        self.events.append(contentsOf: filteredRepeatingEvents.toArray())
        
        for repeatingSchedule in filteredRepeatingEvents {
            var appendArray     = true
            for rlmTask in filteredEvents{
                if (rlmTask.repeatingSchedule != nil && rlmTask.repeatingSchedule?.id == repeatingSchedule.id) {
                    appendArray     = false
                    break
                }
            }
            if appendArray{
                self.events.append(repeatingSchedule)
            }
            
//            let filteredArray   = filteredEvents.filter{($0.repeatingSchedule?.id.elementsEqual(repeatingSchedule.id))!}
//            if filteredArray.count <= 0{
//                self.events.append(repeatingSchedule)
//            }
        }

        if (self.calendarView != nil) {
            self.calendarView.reloadData()
        }
    }
    
    
    
    // MARK:- Utility Methods
    
    func getEventsForDate(cellDate:CellState) -> [Any] {
        
        let cellDateOnly    = cellDate.date.dateOnly()
        
        if cellDate.text == "28"{
            print("16")
        }
        
        
        var arrayRLMTasks:[Any]             = []
        var arrayRLMRepeatingTasks:[Any]    = []
        for i in 0..<self.events.count{
            if let task = self.events[i] as? RLMTask{
                if let schedule = task.repeatingSchedule {
                    if !(self.isThereAnyDuplicateTask(task: task, inArray: arrayRLMTasks, forDate: cellDate)) && cellDate.date.dateOnly().compare((task.dueDate! as Date).dateOnly()) == ComparisonResult.orderedSame {
                        arrayRLMTasks.append(task)
                    } else if self.isValidRepeatingTask(task: task, cellDateOnly: cellDateOnly, arrayRLMTasks: arrayRLMTasks) {
//                    if self.isValidRepeatingTask(repeatingTask: schedule, cellDateOnly: cellDateOnly, arrayRLMTasks: arrayRLMTasks) {
                        arrayRLMTasks.append(task)
                    } else {
                        print("none")
                    }
                } else if (task.dueDate != nil) && (cellDate.date.dateOnly().compare((task.dueDate as! Date).dateOnly()) == ComparisonResult.orderedSame) {
                    arrayRLMTasks.append(task)
                }
            } else {
                let repeatingTask   = self.events[i] as! RLMRepeatingSchedule
                if self.isValidRepeatingTask(repeatingTask: repeatingTask, cellDateOnly: cellDateOnly, arrayRLMTasks: arrayRLMTasks){
                    arrayRLMRepeatingTasks.append(self.events[i])
                }
            }
        }
        
        var dateEvents:[Any] = []
        dateEvents.append(contentsOf: arrayRLMTasks)
        dateEvents.append(contentsOf: arrayRLMRepeatingTasks)
        return dateEvents
    }
    
    
    func isValidRepeatingTask(repeatingTask:RLMRepeatingSchedule, cellDateOnly:Date, arrayRLMTasks:[Any]) -> Bool {
//            let filteredArray   = arrayTemp.filter{($0.repeatingSchedule?.id.elementsEqual(repeatingTask.id))!}
        var isValid = false

        
        if repeatingTask.tokens.count > 0 {
            if let master = repeatingTask.masterTask{
                
                let dateToken       = repeatingTask.tokens[0]
//                let startDateOnly   = (dateToken.lastTaskCreatedDueDate! as Date).dateOnly()
                let startDateOnly   = (master.dueDate! as Date).dateOnly()
                if repeatingTask.schedule == "Daily" && (cellDateOnly.compare(startDateOnly) == ComparisonResult.orderedDescending || cellDateOnly.compare(startDateOnly) == ComparisonResult.orderedSame){
                    isValid = true
                }else if repeatingTask.schedule == "Weekly" && cellDateOnly.isWeeklyDateOf(inputDate: startDateOnly){
                    isValid = true
                }else if repeatingTask.schedule == "Bi-Weekly" && cellDateOnly.isBiWeeklyDateOf(inputDate: startDateOnly){
                    isValid = true
                }else if repeatingTask.schedule == "Monthly" && cellDateOnly.isMonthlyDateOf(inputDate: startDateOnly){ // Monthly
                    isValid = true
                }
                
                
                if isValid{
                    if master.dueDate?.compare((dateToken.lastTaskCreatedDueDate as Date?)!) != ComparisonResult.orderedSame{
                        isValid = false
                    }
                }
            }
            
        }
        
        
        //TODO: I was working here...
        //
        
//        let startDateOnly   = (repeatingTask.masterTask?.dueDate as Date?)!.dateOnly()

        
        return isValid
    }
    
    func isValidRepeatingTask(task:RLMTask, cellDateOnly:Date, arrayRLMTasks:[Any]) -> Bool {
        var isValid = false
        
        let repeatingTask   = task.repeatingSchedule
        if repeatingTask!.tokens.count > 0 {
            let dateToken       = repeatingTask!.tokens[0]
            let startDateOnly   = (task.dueDate! as Date).dateOnly()
            
            if repeatingTask!.schedule == "Daily" && (cellDateOnly.compare(startDateOnly) == ComparisonResult.orderedDescending || cellDateOnly.compare(startDateOnly) == ComparisonResult.orderedSame){
                isValid = true
            }else if repeatingTask!.schedule == "Weekly" && cellDateOnly.isWeeklyDateOf(inputDate: startDateOnly){
                isValid = true
            }else if repeatingTask!.schedule == "Bi-Weekly" && cellDateOnly.isBiWeeklyDateOf(inputDate: startDateOnly){
                isValid = true
            }else if repeatingTask!.schedule == "Monthly" && cellDateOnly.isMonthlyDateOf(inputDate: startDateOnly){ // Monthly
                isValid = true
            }
            
            
            if isValid{
                if task.originalDueDate?.compare((dateToken.lastTaskCreatedDueDate as Date?)!) != ComparisonResult.orderedSame{
                    isValid = false
                }
                
                
            }
        }
        return isValid
    }
    
    
    
    func didSelectDate(cellState:CellState, cell: JTAppleCell?, andEditThisTaskOnly editThisTaskOnly:Bool) {
        let eventsForDate = self.getEventsForDate(cellDate: cellState)
        
        //if eventsForDate.count > 0 {
            let calendarTaskManager = self.storyboard?.instantiateViewController(withIdentifier: "CalendarTaskManagerViewController") as! CalendarTaskManagerViewController
            var arrayForHomeVC:[RLMTask]  = []
            for i in 0..<eventsForDate.count{
                if let task = eventsForDate[i] as? RLMTask{
                    if task.repeatingSchedule == nil || task.repeatingSchedule?.schedule == "none" || !editThisTaskOnly {
                        arrayForHomeVC.append(task)
                    }else if let task = self.createNewTaskForTask(tappedTask: task, cellState: cellState){
                        arrayForHomeVC.append(task)
                    }
                }else{
                    let rSchedule = eventsForDate[i] as? RLMRepeatingSchedule
                    if editThisTaskOnly{
                        if let task = self.createNewTaskForRepeatingTask(repeatingSchedule: rSchedule!, cellState: cellState){
                            arrayForHomeVC.append(task)
                        }
                    }else if rSchedule?.masterTask != nil{
                        arrayForHomeVC.append((rSchedule?.masterTask)!)
                    }
                }
            }
            calendarTaskManager.tasksFromCalendar        = arrayForHomeVC //eventsForDate as! [RLMTask]
            calendarTaskManager.calendarViewController   = self
            calendarTaskManager.selectedDate             = cellState.date.dateOnly()
            //calendarTaskManager.navigationItem.titleView = nil
            let dateFormatter = DateFormatter(); dateFormatter.dateStyle = .long; dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale.current
            calendarTaskManager.title = dateFormatter.string(from: cellState.date)
            if let myCustomCell = cell as? CellView1{
                myCustomCell.handleTextColorFor(cellState: cellState)
            }
            //self.splitViewController?.showDetailViewController(calendarTaskManager, sender: cell)
            //self.show(calendarTaskManager, sender: cell)
            self.showDetailViewController(calendarTaskManager, sender: cell)
            //self.navigationController?.pushViewController(calendarTaskManager, animated: true)
        //}
    }
    
    func isThereAnyDuplicateTask(task: RLMTask, inArray arrayTasks:[Any], forDate cellState: CellState) -> Bool {
        var isTask = false
        let repeatingSchedule = task.repeatingSchedule
        
        for task in arrayTasks{
            let rlmTask  = task as! RLMTask
            if rlmTask.repeatingSchedule != nil && rlmTask.repeatingSchedule?.id != repeatingSchedule!.id && rlmTask.repeatingSchedule?.masterTask?.id == repeatingSchedule!.masterTask?.id{
                isTask = true
            }
        }
        return isTask
    }
    
    func createNewTaskForTask(tappedTask:RLMTask, cellState:CellState) -> RLMTask? {
        
        var task:RLMTask!
        let repeatingSchedule = tappedTask.repeatingSchedule
        
        
        for rlmTask in self.arrayallRLMTasks{
            if rlmTask.originalDueDate != nil && rlmTask.dueDate == tappedTask.dueDate{
                if repeatingSchedule != nil && (repeatingSchedule?.tokens.count)! > 0{
                    let dateToken       = repeatingSchedule?.tokens[0]
                    if rlmTask.originalDueDate?.compare((dateToken!.lastTaskCreatedDueDate as Date?)!) != ComparisonResult.orderedSame{
                        task = rlmTask
                        break
                    }else if (rlmTask.repeatingSchedule?.masterTask?.id == repeatingSchedule?.masterTask?.id && rlmTask.repeatingSchedule?.schedule == "none"){
                        task = rlmTask
                        break
                    }
                }
                
            }
        }
        
        if task == nil {
            let date            = cellState.date.stringWithFormat(format: "dd MM yyyy", setUTCTimeZone: false)
            let masterTaskDate  = repeatingSchedule!.masterTask?.dueDate as Date?
            let time            = masterTaskDate!.stringWithFormat(format: "HH:mm:ss", setUTCTimeZone: true)
            let dateTime        = String.init(format: "%@ %@", date,time)
            let finalDateTime   = dateTime.convertToDateWith(format: "dd MM yyyy HH:mm:ss", setUTCTimeZone: true)
            let finalDT         = finalDateTime as NSDate?
            
            let realm = try! Realm()
            realm.beginWrite()
            
            task        = RLMTask.init(name: (repeatingSchedule!.masterTask?.name)!, type: (repeatingSchedule!.masterTask?.type)!, dueDate: finalDT, course: repeatingSchedule!.masterTask?.course)
            
            if let n_scope = repeatingSchedule!.masterTask?.scope {
                task.scope          = n_scope
            }
            
            if let n_Completed = repeatingSchedule!.masterTask?.completed {
                task.completed      = n_Completed
            }
            
            if let n_completionDate = repeatingSchedule!.masterTask?.completionDate  {
                task.completionDate = n_completionDate
            }
            
            if let n_removed = repeatingSchedule!.masterTask?.removed  {
                task.removed = n_removed
            }
            
            
            if let n_dateOfExtension = repeatingSchedule!.masterTask?.dateOfExtension{
                task.dateOfExtension        = n_dateOfExtension
            }
            
            if let n_timeSet = repeatingSchedule!.masterTask?.timeSet{
                task.timeSet        = n_timeSet
            }
            
            if let n_endDateAndTime = repeatingSchedule!.masterTask?.endDateAndTime {
                task.endDateAndTime        = n_endDateAndTime
            }
            
            if let n_originalDueDate = repeatingSchedule!.masterTask?.originalDueDate {
                task.originalDueDate        = n_originalDueDate
            }
            
            if let n_repeatingSchedule = repeatingSchedule!.masterTask?.repeatingSchedule {
                let repeatingSchedule = RLMRepeatingSchedule.init(schedule: "none", type: n_repeatingSchedule.type, course: n_repeatingSchedule.course, location: n_repeatingSchedule.location)
                repeatingSchedule.tokens        = n_repeatingSchedule.tokens
                repeatingSchedule.masterTask    = n_repeatingSchedule.masterTask
                task.repeatingSchedule          = repeatingSchedule
            }
            
            
            if let n_tempVisible = repeatingSchedule!.masterTask?.tempVisible {
                task.tempVisible            = n_tempVisible
            }
            
            
            if let n_tempDueDate = repeatingSchedule!.masterTask?.tempDueDate {
                task.tempDueDate            = n_tempDueDate
            }
            
            
            realm.add(task)
            do {
                try realm.commitWrite()
                NotificationCenter.default.post(name: NSNotification.Name.init("event_updated"), object: nil)
                return task
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
                return nil
            }
        }else{
            return task
        }
    }
    
    
    func createNewTaskForRepeatingTask(repeatingSchedule:RLMRepeatingSchedule, cellState:CellState) -> RLMTask? {
        
        var task:RLMTask!
        
        
        for rlmTask in self.arrayallRLMTasks{
            if rlmTask.repeatingSchedule != nil && rlmTask.repeatingSchedule?.id != repeatingSchedule.id && rlmTask.repeatingSchedule?.masterTask?.id == repeatingSchedule.masterTask?.id{
                task = rlmTask
            }
        }
        
        if task == nil {
            let date            = cellState.date.stringWithFormat(format: "dd MM yyyy", setUTCTimeZone: false)
            let masterTaskDate  = repeatingSchedule.masterTask?.dueDate as Date?
            let time            = masterTaskDate!.stringWithFormat(format: "HH:mm:ss", setUTCTimeZone: true)
            let dateTime        = String.init(format: "%@ %@", date,time)
            let finalDateTime   = dateTime.convertToDateWith(format: "dd MM yyyy HH:mm:ss", setUTCTimeZone: true)
            let finalDT         = finalDateTime as NSDate?
            
            let realm = try! Realm()
            realm.beginWrite()
            
            task        = RLMTask.init(name: (repeatingSchedule.masterTask?.name)!, type: (repeatingSchedule.masterTask?.type)!, dueDate: finalDT, course: repeatingSchedule.masterTask?.course)
            
            if let n_scope = repeatingSchedule.masterTask?.scope {
                task.scope          = n_scope
            }
            
            if let n_Completed = repeatingSchedule.masterTask?.completed {
                task.completed      = n_Completed
            }
            
            if let n_completionDate = repeatingSchedule.masterTask?.completionDate  {
                task.completionDate = n_completionDate
            }
            
            if let n_removed = repeatingSchedule.masterTask?.removed  {
                task.removed = n_removed
            }
            
            
            if let n_dateOfExtension = repeatingSchedule.masterTask?.dateOfExtension{
                task.dateOfExtension        = n_dateOfExtension
            }
            
            if let n_timeSet = repeatingSchedule.masterTask?.timeSet{
                task.timeSet        = n_timeSet
            }
            
            if let n_endDateAndTime = repeatingSchedule.masterTask?.endDateAndTime {
                task.endDateAndTime        = n_endDateAndTime
            }
            
            if let n_originalDueDate = repeatingSchedule.masterTask?.originalDueDate {
                task.originalDueDate        = n_originalDueDate
            }
            
            if let n_repeatingSchedule = repeatingSchedule.masterTask?.repeatingSchedule {
                let repeatingSchedule = RLMRepeatingSchedule.init(schedule: "none", type: n_repeatingSchedule.type, course: n_repeatingSchedule.course, location: n_repeatingSchedule.location)
                repeatingSchedule.tokens        = n_repeatingSchedule.tokens
                repeatingSchedule.masterTask    = n_repeatingSchedule.masterTask
                task.repeatingSchedule          = repeatingSchedule
            }
            
            
            if let n_tempVisible = repeatingSchedule.masterTask?.tempVisible {
                task.tempVisible            = n_tempVisible
            }
            
            
            if let n_tempDueDate = repeatingSchedule.masterTask?.tempDueDate {
                task.tempDueDate            = n_tempDueDate
            }
            
            
            realm.add(task)
            do {
                try realm.commitWrite()
                NotificationCenter.default.post(name: NSNotification.Name.init("event_updated"), object: nil)
                return task
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
                return nil
            }
        }else{
            return task
        }
    }
    
    func checkForCellAnimation() {
        let selectedRowIndexPath = self.calendarView.indexPathsForSelectedItems?.first
        if ((selectedRowIndexPath) != nil) {
            if let coordinator = transitionCoordinator {
                let animationBlock: (UIViewControllerTransitionCoordinatorContext?) -> () = { [weak self] _ in
                    self?.animateCellWhenPresenting(at:selectedRowIndexPath! , animated: true)
                }
                let completionBlock: (UIViewControllerTransitionCoordinatorContext?) -> () = { [weak self] context in
                    if context!.isCancelled {
                        self?.animateCellWhenDismissing(at:selectedRowIndexPath! , animated: true)
                    }
                }
                coordinator.animate(alongsideTransition: animationBlock, completion: completionBlock)
            }
            else {
                animateCellWhenPresenting(at:selectedRowIndexPath! , animated: true)
            }
        }
    }
    
    
    // MARK:- Action Methods
    @IBAction func btnFilter_Action(_ sender: UIBarButtonItem) {
        let vc  = self.storyboard!.instantiateViewController(withIdentifier: "TaskTypeTableViewController") as! TaskTypeTableViewController
        vc.isFromCalendarVC     = true
        vc.calendarVC           = self
        vc.arraySelectedTypes   = self.arrayTypesForFilters
        self.splitViewController?.showDetailViewController(vc, sender: sender)
    }
    
    
    // MARK:- DELEGATES
    
    // MARK: Callendar View
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let date = Date()
        let result = formatter.string(from: date)
        
        var startDate: Date!
        var endDate: Date!
        
        if currentDate == nil  {
            startDate = formatter.date(from: result)! // You can use date generated from a formatter
            endDate = formatter.date(from: "2020 11 23")! // You can also use dates created from this function
        }else {
            startDate = Calendar.current.date(byAdding: .month, value: -12, to: (self.currentDate?.date)!)!
            endDate = Calendar.current.date(byAdding: .month, value: 12, to: (self.currentDate?.date)!)!
        }
        
        let calendar = Calendar.current                     // Make sure you set this up to your time zone. We'll just use default here
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: calendar,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .off,
                                                 firstDayOfWeek: .sunday)
        return parameters
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 60)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let headerCell = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "header", for: indexPath) as! PinkSectionHeaderView
        headerCell.backgroundColor = #colorLiteral(red: 0.1071848497, green: 0.1071884111, blue: 0.1071864888, alpha: 1)
        
        let fullName:String         = monthFormatter.string(from: range.start)
        let fullNameArr:[String]    = fullName.components(separatedBy: " ")
        
        // And then to access the individual words:
        let monthName:String        = fullNameArr[0]
        let year:String             = fullNameArr[1]
        
        let myAttribute             = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 27)]
        let myAttrString            = NSAttributedString(string: monthName, attributes: myAttribute)
        let myaStr                  = NSAttributedString(string: year, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 27)])
        let space                   = NSAttributedString(string: " ", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17)])
        
        let combination = NSMutableAttributedString()
        combination.append(myAttrString)
        combination.append(space)
        combination.append(myaStr)
        
        headerCell.title.attributedText = combination
        headerCell.title.textColor = UIColor.white
        
        return headerCell
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        //print(String.init(format: "%@ _ %@", cellState.date as CVarArg, cellState.text))
        
        let myCustomCell            = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "cell", for: indexPath) as! CellView1
        myCustomCell.setupCellForState(state: cellState, withDate: date, andEvents: self.getEventsForDate(cellDate: cellState))
        return myCustomCell
    }
    
    
    /*func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.currentDate = visibleDates.monthDates.first
        self.calendarView.reloadData(withanchor: self.currentDate?.date) {
        }
    }*/
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print("Item is tapped")
        //UIAlertController.showAlertView(title: "Edit Task", message: "What do you want to do", buttons: ["Edit This Task Only","Edit Repeating Task"]) { (buttonText, avc) in
            //if buttonText == "Edit This Task Only"{
                self.didSelectDate(cellState: cellState, cell: cell, andEditThisTaskOnly: true)
            //} else {
                //self.didSelectDate(cellState: cellState, cell: cell, andEditThisTaskOnly: false)
            //}
        //}
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if let myCustomCell = cell as? CellView1{
            myCustomCell.handleTextColorFor(cellState: cellState)
        }
    }
    
    func animateCellWhenDismissing(at indexPath: IndexPath, animated: Bool) {
        let cell = calendarView.cellForItem(at: indexPath) as? CellView1
        if (animated == true) {
            cell?.cellBgView.backgroundColor = UIColor.clear
        }
    }
    
    func animateCellWhenPresenting(at indexPath: IndexPath, animated: Bool) {
        let cell = calendarView.cellForItem(at: indexPath) as? CellView1
        if (animated == true) {
            cell?.cellBgView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    }
    
    // MARK: UIViewController
    
    var width: CGFloat = 0.0
    override func viewWillLayoutSubviews() {
        // Fixes glitch where user opens calendar and rotates device -> it ruins layout.
        if (self.view.frame.size.width != width) {
            width = self.view.frame.size.width
            
            if self.calendarView != nil {
                self.calendarView.collectionViewLayout.invalidateLayout() //fixes bug
            }
        }
        //
    }
    
    /*override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Hook in to the rotation animation completion handler
        coordinator.animate(alongsideTransition: nil) { (_) in
            // Updates to your UI...
            //self.setupView()
            if self.calendarView != nil {
                self.calendarView.collectionViewLayout.invalidateLayout() //fixes bug
            }
        }
    }*/
    
    func setHomeVC() {
        for tableView in TaskManagerTracker.taskManagers() {
            if (tableView?.parentViewController is HomeworkViewController) {
                self.homeVC = tableView!.parentViewController as! HomeworkViewController
            }
        }
    }
    
    
    // MARK: UITextField
    
    
    //MARK:- SplitViewController
    
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
                if (sender == nil || ((sender as? UIView)?.isDescendant(of: detailNavController.view) == true || (detailNavController.visibleViewController != nil && (sender! as? UIView)?.isDescendant(of: detailNavController.visibleViewController!.view) == true))) {
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
    
   
}
