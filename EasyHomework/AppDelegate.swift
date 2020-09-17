//
//  AppDelegate.swift
//  EasyHomework
//
//  Created by Anthony Giugno on 2016-02-14.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import CoreData
import Parse
import RealmSwift
import AVFoundation
import FBSDKCoreKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, KochavaTrackerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
     
        // Override point for customization after application launch.
    
        //** Realm **//
        //*** Migrations ***//
        let configuration = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 7,
            //already we have change existing schemaversion to 7
            
            //realmtass
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = configuration
        
        //*** End of Migrations ***//
        
        //** Parse **//
        
        //Parse.setApplicationId("p1eGg31YomJ7I6fP8hr2yehTHQhvtSHXw2FwOOCw",
            //clientKey: "KgZVJRNHsys0mkARKI537s4Z3v85bQX2Z00o2lzr")
        
        /*let parseConfig = ParseClientConfiguration {
            $0.applicationId = "p1eGg31YomJ7I6fP8hr2yehTHQhvtSHXw2FwOOCw"
            $0.clientKey = "KgZVJRNHsys0mkARKI537s4Z3v85bQX2Z00o2lzr"
            $0.server = "https://parse-server-nodejs.herokuapp.com/parse"
        }*/
        
        //Production Server
        
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "p1eGg31YomJ7I6fP8hr2yehTHQhvtSHXw2FwOOCw"
            $0.clientKey = "KgZVJRNHsys0mkARKI537s4Z3v85bQX2Z00o2lzr"
            $0.server = "https://b4grad.herokuapp.com/parse"
        }
        Parse.initialize(with: parseConfig)
        
        //Local Server
        /*
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "p1eGg31YomJ7I6fP8hr2yehTHQhvtSHXw2FwOOCw"
            $0.clientKey = "KgZVJRNHsys0mkARKI537s4Z3v85bQX2Z00o2lzr"
            $0.server = "http://localhost:8080/parse"
        }
        Parse.initializeWithConfiguration(parseConfig)
        */
        PFUser.enableAutomaticUser()
        //PFUser.currentUser()?.setObject(NSDate(), forKey: "updatedAt") //This causes crash on launch after user information updated.
        PFUser.current()?.saveInBackground()
        //if user is not anonymous, fetch latest profile data.
        if (PFUser.current() != nil) {
            if (PFAnonymousUtils.isLinked(with: PFUser.current()) == false) {
                PFUser.current()?.fetchInBackground(block: { (object, error) -> Void in
                    if (error == nil) {
                        let user = object as! PFUser
                        print(user.username!)
                    } else {
                        print("Could not fetch latest version of profile.")
                    }
                })
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch {
            print("AVAudioSession could not be updated.")
        }
        
        //Set tasks that are dateOfExtension != nil to dateOfExtension = nil //[commented] if dateOfExtension is older than today.
        let realm = try! Realm()
        let extendedTasks = realm.objects(RLMTask.self).filter("dateOfExtension != null")
        let tempVisibleTasks = realm.objects(RLMTask.self).filter("tempVisible == true")
        realm.beginWrite()
        do {
            for task in extendedTasks {
                if (Calendar.current.isDateInToday(task.dateOfExtension! as Date) == false) { task.dateOfExtension = nil }
                //task.dateOfExtension = nil
            }
            for task in tempVisibleTasks {
                task.tempVisible = false
                task.tempDueDate = nil
            }
            try realm.commitWrite()
        } catch _ {}
        
        self.manageTaskCreationForRepeatingTasks() //Involves the two methods below.
        
        /*let courses = realm.objects(RLMCourse.self)
        let course = courses.first
        var tasksToCreate = [RLMTask]()
        for index in 1...10000 {
            let task = RLMTask(name: "Herpin and a Derpin at the Mall Cooliostasis", type: "Lecture", dueDate: NSDate(), course: course)
            task.completed = true
            
            tasksToCreate.append(task)
        }
        realm.beginWrite()
        realm.add(tasksToCreate)
        do {
            try realm.commitWrite()
        } catch let error {
            print(error.localizedDescription)
        }*/
        
        let config = Realm.Configuration(shouldCompactOnLaunch: { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file
            
            // Compact if the file is over 100MB in size and less than 50% 'used'
            let oneHundredMB = 300 * 1024 * 1024
            return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        })
        do {
            // Realm is compacted on the first open if the configuration block conditions were met.
            let realm = try Realm(configuration: config)
        } catch {
            // handle error compacting or opening Realm
        }
        
        Flurry.startSession("7T444RBZM875Q9XZVZCY", with: FlurrySessionBuilder
            .init()
            .withCrashReporting(true)
            .withLogLevel(FlurryLogLevelAll))
        
        FirebaseApp.configure()
        
        // trackerParametersDictionary
        var trackerParametersDictionary: [AnyHashable: Any] = [:]
        trackerParametersDictionary[kKVAParamAppGUIDStringKey] = "kob4grad-iyh83"
        trackerParametersDictionary[kKVAParamLogLevelEnumKey] = kKVALogLevelEnumInfo
        
        // KochavaTracker.shared
        KochavaTracker.shared.configure(withParametersDictionary: trackerParametersDictionary, delegate: self)
        
        return true
    }
    
    func manageTaskCreationForRepeatingTasks() {
        let realm = try! Realm()
        //Time to create tasks for any recurringSchoolEvent. (this also occurs when the app is about to enter the foreground)
        let repeatingSchedules = realm.objects(RLMRepeatingSchedule.self)
        let calendar = Calendar(identifier: .gregorian)
        
        var tasksToCreate = [RLMTask]()
        var dateTokensToUpdate = [RLMDateToken]()
        var dueDates = [Date]()
        if (repeatingSchedules.count > 0) {
            var tasksForRepeatingSchedule = [RLMTask]()
            for repeatingSchedule in repeatingSchedules {
                for dateToken in repeatingSchedule.tokens {
                    if (dateToken.lastTaskCreatedDueDate != nil) {
                        //Since there are previous tasks for this dateToken, we check potential tasks to create immediately.
                        var tuple = ([RLMTask](), Date())
                        if (repeatingSchedule.schedule == "Daily") {
                            tuple = self.createTasksAfterInitialTaskForDailySchedule(repeatingSchedule: repeatingSchedule, dateToken: dateToken, calendar: calendar)
                        } else
                        if (repeatingSchedule.schedule == "Weekly") {
                            tuple = self.createTasksAfterInitialTaskForWeeklySchedule(repeatingSchedule: repeatingSchedule, dateToken: dateToken, calendar: calendar)
                        } else
                        if (repeatingSchedule.schedule == "Bi-Weekly") {
                            tuple = self.createTasksAfterInitialTaskForBiWeeklySchedule(repeatingSchedule: repeatingSchedule, dateToken: dateToken, calendar: calendar)
                        } else
                        if (repeatingSchedule.schedule == "Monthly") {
                            tuple = self.createTasksAfterInitialTaskForMonthlySchedule(repeatingSchedule: repeatingSchedule, dateToken: dateToken, calendar: calendar)
                        }
                        if (tuple.0.count > 0) {
                            tasksForRepeatingSchedule.append(contentsOf: tuple.0 as [RLMTask])
                            ///tasksToCreate.append(contentsOf: tuple.0 as [RLMTask])
                            dueDates.append(tuple.1)
                            dateTokensToUpdate.append(dateToken)
                        }
                    }
                }
                let masterTask = repeatingSchedule.masterTask; var type: String; var course: RLMCourse?
                if (masterTask != nil) { type = masterTask!.type; course = masterTask?.course }
                else { type = repeatingSchedule.type; course = repeatingSchedule.course! }
                var counter = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@ AND removed = false", type, course, NSDate()).sorted(byKeyPath: "createdDate", ascending: false).count //repeatingSchedule.createdDate
                for task in tasksForRepeatingSchedule.sorted(by: { $0.dueDate!.timeIntervalSince1970 < $1.dueDate!.timeIntervalSince1970 }) {
                    counter = counter + 1
                    task.name = type + " " + String(counter)
                    if (repeatingSchedule.masterTask != nil && task.hasPlaceholderName() == false) { task.name = masterTask!.name}
                    task.createdDate = task.createdDate.addingTimeInterval(Double(counter)) //So the placeholder names are correct.
                }
                tasksToCreate.append(contentsOf: tasksForRepeatingSchedule)
                tasksForRepeatingSchedule.removeAll()
            }
            //BATCH save all related objects (tasks & dateTokens) to ensure consistency and efficiency.
            realm.beginWrite()
            realm.add(tasksToCreate) //These are all new tasks being created.
            for (index, dateToken) in dateTokensToUpdate.enumerated() {
                dateToken.lastTaskCreatedDueDate = dueDates[index] as NSDate
            }
            do {
                try realm.commitWrite()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    //1) As Tasks are created, make sure that ones due before longer away than the schedule length for the same RLMRepeatingSchedule are removed from Agenda.
    // DECIDE based on type of SCOPE of task as well as the SCHEDULE.
    //2) Query past tasks (ones already created) and ensure that they are also removed from Agenda.
    //Above things were only really necessary for daily tasks. For other types, not needed as much except for when user has been away from app for a very long time.
    
    func createTasksAfterInitialTaskForDailySchedule(repeatingSchedule: RLMRepeatingSchedule, dateToken: RLMDateToken, calendar: Calendar) -> ([RLMTask], Date) {
        let currentDateAndTime = Date()
        let realm = try! Realm()
        var tasksToCreate = [RLMTask]()
        
        //Keep track of tasks made in the future (via calendar possibly), so that these tasks don't get recreated by this algorithm.
        let tasksAfterDateTokenLastTaskCreatedDueDate = realm.objects(RLMTask.self).filter("originalDueDate >= %@", dateToken.lastTaskCreatedDueDate!)
        
        //Now we keep generating targetDates (dates for which the task would be occur at) up until the current day. We should check to ensure the tasks don't have matching dueDates to any of the originalDueDates in the tasksAfterLastCheckedTask query.
        var followingTargetDay = dateToken.lastTaskCreatedDueDate! as Date
        var lastSavedTaskDueDate = dateToken.lastTaskCreatedDueDate! as Date //used at the end
        let gregorianCal = Calendar(identifier: .gregorian) //Always use a new calendar object instead of reusing an existing one.
        while (followingTargetDay <= currentDateAndTime || Calendar.current.isDateInToday(followingTargetDay)) {
            var lastTaskCreatedDueDateComponents = gregorianCal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: followingTargetDay as Date)
            lastTaskCreatedDueDateComponents.hour = (dateToken.startTime! as Date).time.hour
            lastTaskCreatedDueDateComponents.minute = (dateToken.startTime! as Date).time.minute
            followingTargetDay = calendar.date(from: lastTaskCreatedDueDateComponents)! as Date
            followingTargetDay = calendar.date(byAdding: .day, value: 1, to: followingTargetDay, wrappingComponents: false)!
            print("Following Target Day: " + followingTargetDay.description)
            
            var endDateAndTime : Date?
            if (dateToken.endTime != nil) {
                lastTaskCreatedDueDateComponents.hour = (dateToken.endTime! as Date).time.hour
                lastTaskCreatedDueDateComponents.minute = (dateToken.endTime! as Date).time.minute
                endDateAndTime = calendar.date(from: lastTaskCreatedDueDateComponents)!
                if ((dateToken.startTime as Date).time > (dateToken.endTime! as Date).time) {
                    //The recurring school event ends on the following day...(instead of the same day)
                    endDateAndTime = calendar.date(byAdding: .day, value: 1, to: endDateAndTime!, wrappingComponents: false)
                }
            }
            
            if (followingTargetDay <= currentDateAndTime || Calendar.current.isDateInToday(followingTargetDay)) {
                var saveTask = true
                for taskCreatedAheadOfTime in tasksAfterDateTokenLastTaskCreatedDueDate { //ensure the task wasn't already created ahead of time somehow (perhaps via the calendar feature shipping in the future)
                    if (taskCreatedAheadOfTime.originalDueDate! as Date == followingTargetDay) {
                        saveTask = false
                        break
                    }
                }
                if (saveTask == true) {
                    let masterTask = repeatingSchedule.masterTask; var type: String; var course: RLMCourse?
                    if (masterTask != nil) { type = masterTask!.type; course = masterTask?.course }
                    else { type = repeatingSchedule.type; course = repeatingSchedule.course! }
                    
                    var counter = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@", type, course as Any, repeatingSchedule.createdDate).sorted(byKeyPath: "createdDate", ascending: false).count //course can be nil.
                    counter = counter + 1
                    //create task & add to array.
                    let task = RLMTask(name: type + " " + String(counter), type: type, dueDate: followingTargetDay as NSDate, course: course) //set name in other method.
                    task.endDateAndTime = endDateAndTime as NSDate?
                    if (endDateAndTime != nil) {
                        task.timeSet = true
                    }
                    if (masterTask != nil) { task.timeSet = masterTask!.timeSet }
                    task.originalDueDate = followingTargetDay as NSDate
                    task.repeatingSchedule = repeatingSchedule
                    if (masterTask != nil) {
                        var subTaskCopies = [RLMSubTask]()
                        for subTask in masterTask!.subTasks {
                            let copyOfSubTask = RLMSubTask(value: subTask)
                            copyOfSubTask.id = NSUUID().uuidString
                            subTaskCopies.append(copyOfSubTask)
                        }
                        task.subTasks.append(objectsIn: subTaskCopies)
                    }
                    tasksToCreate.append(task)
                    lastSavedTaskDueDate = followingTargetDay //saved to dateToken outside of this method.
                }
            }
        }
        
        //The below two nests represent B4Grad's handling of repeating tasks that have not been completed for an extended period. In the case of daily tasks, this happens more often since they are created so often. In the case of monthly tasks, this is far less common, however still occurs to some extent. The goal is to have 1-2 tasks from a repeating schedule being in the agenda at a time.
        //As Tasks are created, make sure that ones due before longer away than the schedule length for the same RLMRepeatingSchedule are removed from Agenda. This behaviour is unique for each method.
        if (tasksToCreate.count > 1) { //Ensure that if agenda was left for awhile, only the newest task for this schedule will be seen in Agenda.
            for task in tasksToCreate {
                if (task != tasksToCreate.last && task.scope != "Event") { task.completed = true }
            }
        }
        //Query past tasks (ones already created) and ensure that they are also removed from Agenda.
        let previousTasksForSameSchedule = realm.objects(RLMTask.self).filter("repeatingSchedule == %@ AND completed == false AND dueDate <= %@ AND scope != %@", repeatingSchedule, Date().yesterday.convertToLatestPossibleTimeOfDay(), "Event")
        for task in previousTasksForSameSchedule {
            if (task.dueDate?.timeIntervalSinceReferenceDate == task.originalDueDate?.timeIntervalSinceReferenceDate && task.repeatingTaskWasUncompleted == false) {
                //But what about when a task is uncompleted manually from schedule? It gets marked completed the next day again basically. The solution to this is to introduce a new property.
                    realm.beginWrite()
                    task.completed = true
                    do {
                        try realm.commitWrite()
                    } catch let error {
                        print(error.localizedDescription)
                    }
            }
        }
        
        return (tasksToCreate, lastSavedTaskDueDate)
    }
    
    func createTasksAfterInitialTaskForWeeklySchedule(repeatingSchedule: RLMRepeatingSchedule, dateToken: RLMDateToken, calendar: Calendar) -> ([RLMTask], Date) {
        let currentDateAndTime = Date()
        let realm = try! Realm()
        var tasksToCreate = [RLMTask]()
        
        let masterTask = repeatingSchedule.masterTask; var type: String; var course: RLMCourse?; var scope: String
        if (masterTask != nil) { type = masterTask!.type; course = masterTask?.course; scope = masterTask!.scope }
        else { type = repeatingSchedule.type; course = repeatingSchedule.course!; scope = "Event" }
        //First, we should query all tasks attached to this RLMRecurringEvent AFTER the lastChecked = true one to ensure that we can prevent duplicate tasks with dueDates in the future that were already created.
        //let tasksAfterRLMRecurringEventLastTaskCreatedDueDate = realm.objects(RLMTask.self).filter("originalDueDate >= %@", recurringSchoolEvent.lastTaskCreatedDueDate!)
        
        //Keep track of tasks made in the future (via calendar possibly), so that these tasks don't get recreated by this algorithm.
        let tasksAfterDateTokenLastTaskCreatedDueDate = realm.objects(RLMTask.self).filter("originalDueDate >= %@", dateToken.lastTaskCreatedDueDate!)
        
        //Now we keep generating targetDates (dates for which the task would be occur at) up until the current day. We should check to ensure the tasks don't have matching dueDates to any of the originalDueDates in the tasksAfterLastCheckedTask query.
        var followingTargetDay = dateToken.lastTaskCreatedDueDate! as Date
        var lastSavedTaskDueDate = dateToken.lastTaskCreatedDueDate! as Date //used at the end
        
        ///var counter = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@", repeatingSchedule.type, repeatingSchedule.course!, repeatingSchedule.createdDate).sorted(byKeyPath: "createdDate", ascending: false).count
        
        let gregorianCal = Calendar(identifier: .gregorian) //Always use a new calendar object instead of reusing an existing one.
        //var lastTaskCreatedDueDateComponents = gregorianCal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateToken.lastTaskCreatedDueDate! as Date)
        //let weekday = gregorianCal.component(.weekday, from: dateToken.lastTaskCreatedDueDate! as Date)
        
        //calendar.dateComponents([.year, .month, .weekOfYear, .weekday, .hour, .minute], from: recurringSchoolEvent.lastTaskCreatedDueDate! as Date)
        
        //let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        //let previousAlreadyCompletedTaskForSameSchedule = realm.objects(RLMTask.self).filter("repeatingSchedule == %@ AND completed == true AND dueDate <= %@ AND scope != %@", repeatingSchedule, Date(), "Event").sorted(byKeyPath: "originalDueDate", ascending: true).last
        //The reason why this query occurs here is because this is a weekly schedule, and we want to make sure a new task is created for the user if they happened to complete their weekly task early (thus ensuring they know about next week's task sooner).
        //previousAlreadyCompletedTaskForSameSchedule?.dueDate?.overTwoWeeksAway() == false
        
        let targetDayOfWeek = self.getIntegerValueForWeekdayString(weekdayString: DayOfWeek(rawValue: dateToken.startDayOfWeek)!.rawValue)!
        while (followingTargetDay <= currentDateAndTime || taskShouldBeCreated(followingTargetDay: followingTargetDay, scope: scope, repeatingSchedule: repeatingSchedule)) {
            ///let newDate = calendar.date(byAdding: .day, value: 7, to: newDate, wrappingComponents: false)
            //if (weekday >= targetDayOfWeek) {
                //lastTaskCreatedDueDateComponents.weekOfYear! = lastTaskCreatedDueDateComponents.weekOfYear! + 1
            //}
            //lastTaskCreatedDueDateComponents.weekday = targetDayOfWeek
            var lastTaskCreatedDueDateComponents = gregorianCal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: followingTargetDay as Date)
            
            lastTaskCreatedDueDateComponents.hour = (dateToken.startTime! as Date).time.hour
            lastTaskCreatedDueDateComponents.minute = (dateToken.startTime! as Date).time.minute
            followingTargetDay = calendar.date(from: lastTaskCreatedDueDateComponents)! as Date
            followingTargetDay = calendar.date(byAdding: .day, value: 7, to: followingTargetDay, wrappingComponents: false)!
            print("Following Target Day: " + followingTargetDay.description)
            
            var endDateAndTime : Date?
            if (dateToken.endTime != nil) {
                lastTaskCreatedDueDateComponents.hour = (dateToken.endTime! as Date).time.hour
                lastTaskCreatedDueDateComponents.minute = (dateToken.endTime! as Date).time.minute
                endDateAndTime = calendar.date(from: lastTaskCreatedDueDateComponents)!
                if ((dateToken.startTime as Date).time > (dateToken.endTime! as Date).time) {
                    //The recurring school event ends on the following day...(instead of the same day)
                    endDateAndTime = calendar.date(byAdding: .day, value: 1, to: endDateAndTime!, wrappingComponents: false)
                }
            }
            
            //Known unwanted behaviour: cannot have two repeating schedules with same dates/times.
            if (followingTargetDay <= currentDateAndTime || taskShouldBeCreated(followingTargetDay: followingTargetDay, scope: scope, repeatingSchedule: repeatingSchedule)) {
                var saveTask = true
                for taskCreatedAheadOfTime in tasksAfterDateTokenLastTaskCreatedDueDate { //ensure the task wasn't already created ahead of time somehow (perhaps via the calendar feature shipping in the future)
                    if (taskCreatedAheadOfTime.originalDueDate! as Date == followingTargetDay) {
                        saveTask = false
                        break
                    }
                }
                if (saveTask == true) {
                    //let tasksOfSameTypeAndSameCourse = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@ AND recurringSchoolEvent = %@", recurringSchoolEvent.type, recurringSchoolEvent.course!, recurringSchoolEvent.createdDate, recurringSchoolEvent).sorted(byKeyPath: "createdDate", ascending: false)
                    var counter = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@", type, course as Any, repeatingSchedule.createdDate).sorted(byKeyPath: "createdDate", ascending: false).count //course can be nil.
                    counter = counter + 1
                    //create task & add to array.
                    let task = RLMTask(name: type + " " + String(counter), type: type, dueDate: followingTargetDay as NSDate, course: course) //set name in other method.
                    task.endDateAndTime = endDateAndTime as NSDate?
                    if (endDateAndTime != nil) {
                        task.timeSet = true
                    }
                    if (masterTask != nil) { task.timeSet = masterTask!.timeSet }
                    if (masterTask != nil) {
                        var subTaskCopies = [RLMSubTask]()
                        for subTask in masterTask!.subTasks {
                            let copyOfSubTask = RLMSubTask(value: subTask)
                            copyOfSubTask.id = NSUUID().uuidString
                            subTaskCopies.append(copyOfSubTask)
                        }
                        task.subTasks.append(objectsIn: subTaskCopies)
                    }
                    task.originalDueDate = followingTargetDay as NSDate
                    task.repeatingSchedule = repeatingSchedule
                    tasksToCreate.append(task)
                    lastSavedTaskDueDate = followingTargetDay //saved to dateToken outside of this method.
                    
                }
            }
        }
        
        //As Tasks are created, make sure that ones due before longer away than the schedule length for the same RLMRepeatingSchedule are removed from Agenda. This behaviour is unique for each method.
        if (tasksToCreate.count > 1) {
            for task in tasksToCreate {
                if (task != tasksToCreate.last && task.scope != "Event") { task.completed = true }
            }
        }
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        //Query past tasks (ones already created) and ensure that they are also removed from Agenda.
        //Below query made above.
        let previousTasksForSameSchedule = realm.objects(RLMTask.self).filter("repeatingSchedule == %@ AND completed == false AND dueDate <= %@ AND scope != %@", repeatingSchedule, pastDate.convertToLatestPossibleTimeOfDay(), "Event")
        for task in previousTasksForSameSchedule {
            if (task.dueDate?.timeIntervalSinceReferenceDate == task.originalDueDate?.timeIntervalSinceReferenceDate && task.completionDate == nil && task.repeatingTaskWasUncompleted == false) {
                realm.beginWrite()
                task.completed = true
                do {
                    try realm.commitWrite()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        
        //This is a weekly schedule, therefore we want to make sure a new task is created for the user if they happened to complete their weekly task early (thus ensuring they know about next week's task sooner) since the Agenda shows all tasks due in the next 2 weeks EXCEPT in the case of weekly/daily repeating tasks. A better solution would be to make HWVC just query the soonest upcoming repeating task (based on its dueDate) and not show any others happening in the future. This solution can be implemented by simply removing the following chunk of code and simply modifying the queries in HWVC instead. There may also be some changes needed in other portions of this algorithm to ensure that tasks are created ahead of time since right now they can only be created within 1 week of the dueDate without the following nest.
        let previousAlreadyCompletedTaskForSameSchedule = realm.objects(RLMTask.self).filter("repeatingSchedule == %@ AND completed == true AND completionDate <= %@ AND scope != %@", repeatingSchedule, Date(), "Event").sorted(byKeyPath: "originalDueDate", ascending: true).last
        let dueDate = previousAlreadyCompletedTaskForSameSchedule?.dueDate
        if (dueDate != nil) {
            //let futureDate = calendar.date(byAdding: .day, value: 14, to: dueDate as! Date)!
            //if (futureDate.overTwoWeeksAway() == false) {
            let tuple = self.oneMoreTask(repeatingSchedule: repeatingSchedule, dateToken: dateToken, calendar: calendar)
            let numberOfDaysBetweenDates = Date().numberOfDaysBetweenTwoDates(start: dueDate! as Date, end: tuple.1)
            if ((tuple.0?.dueDate?.overTwoWeeksAway())! == false && Date().numberOfDaysBetweenTwoDates(start: dueDate! as Date, end: tuple.1) <= 7) { //should compare # of days between dueDate & tuple's dueDate.
                if (tuple.0 != nil) { tasksToCreate.append(tuple.0!); lastSavedTaskDueDate = tuple.1 }
            }
        }
        
        return (tasksToCreate, lastSavedTaskDueDate)
    }
    
    func createTasksAfterInitialTaskForBiWeeklySchedule(repeatingSchedule: RLMRepeatingSchedule, dateToken: RLMDateToken, calendar: Calendar) -> ([RLMTask], Date) {
        let currentDateAndTime = Date()
        let realm = try! Realm()
        var tasksToCreate = [RLMTask]()
        
        let masterTask = repeatingSchedule.masterTask; var type: String; var course: RLMCourse?; var scope: String
        if (masterTask != nil) { type = masterTask!.type; course = masterTask?.course; scope = masterTask!.scope }
        else { type = repeatingSchedule.type; course = repeatingSchedule.course!; scope = "Event" }
        
        //Keep track of tasks made in the future (via calendar possibly), so that these tasks don't get recreated by this algorithm.
        let tasksAfterDateTokenLastTaskCreatedDueDate = realm.objects(RLMTask.self).filter("originalDueDate >= %@", dateToken.lastTaskCreatedDueDate!)
        
        //Now we keep generating targetDates (dates for which the task would be occur at) up until the current day. We should check to ensure the tasks don't have matching dueDates to any of the originalDueDates in the tasksAfterLastCheckedTask query.
        var followingTargetDay = dateToken.lastTaskCreatedDueDate! as Date
        var lastSavedTaskDueDate = dateToken.lastTaskCreatedDueDate! as Date //used at the end
        let gregorianCal = Calendar(identifier: .gregorian) //Always use a new calendar object instead of reusing an existing one.
        
        let targetDayOfWeek = self.getIntegerValueForWeekdayString(weekdayString: DayOfWeek(rawValue: dateToken.startDayOfWeek)!.rawValue)!
        while (followingTargetDay <= currentDateAndTime || taskShouldBeCreated(followingTargetDay: followingTargetDay, scope: scope, repeatingSchedule: repeatingSchedule)) {
            var lastTaskCreatedDueDateComponents = gregorianCal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: followingTargetDay as Date)
            
            lastTaskCreatedDueDateComponents.hour = (dateToken.startTime! as Date).time.hour
            lastTaskCreatedDueDateComponents.minute = (dateToken.startTime! as Date).time.minute
            followingTargetDay = calendar.date(from: lastTaskCreatedDueDateComponents)! as Date
            followingTargetDay = calendar.date(byAdding: .day, value: 14, to: followingTargetDay, wrappingComponents: false)!
            print("Following Target Day: " + followingTargetDay.description)
            
            var endDateAndTime : Date?
            if (dateToken.endTime != nil) {
                lastTaskCreatedDueDateComponents.hour = (dateToken.endTime! as Date).time.hour
                lastTaskCreatedDueDateComponents.minute = (dateToken.endTime! as Date).time.minute
                endDateAndTime = calendar.date(from: lastTaskCreatedDueDateComponents)!
                if ((dateToken.startTime as Date).time > (dateToken.endTime! as Date).time) {
                    //The recurring school event ends on the following day...(instead of the same day)
                    endDateAndTime = calendar.date(byAdding: .day, value: 1, to: endDateAndTime!, wrappingComponents: false)
                }
            }
            
            if (followingTargetDay <= currentDateAndTime || taskShouldBeCreated(followingTargetDay: followingTargetDay, scope: scope, repeatingSchedule: repeatingSchedule)) {
                var saveTask = true
                for taskCreatedAheadOfTime in tasksAfterDateTokenLastTaskCreatedDueDate { //ensure the task wasn't already created ahead of time somehow (perhaps via the calendar feature shipping in the future)
                    if (taskCreatedAheadOfTime.originalDueDate! as Date == followingTargetDay) {
                        saveTask = false
                        break
                    }
                }
                if (saveTask == true) {
                    var counter = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@", type, course as Any, repeatingSchedule.createdDate).sorted(byKeyPath: "createdDate", ascending: false).count //course can be nil.
                    counter = counter + 1
                    //create task & add to array.
                    let task = RLMTask(name: type + " " + String(counter), type: type, dueDate: followingTargetDay as NSDate, course: course) //set name in other method.
                    task.endDateAndTime = endDateAndTime as NSDate?
                    if (endDateAndTime != nil) {
                        task.timeSet = true
                    }
                    if (masterTask != nil) { task.timeSet = masterTask!.timeSet }
                    if (masterTask != nil) {
                        var subTaskCopies = [RLMSubTask]()
                        for subTask in masterTask!.subTasks {
                            let copyOfSubTask = RLMSubTask(value: subTask)
                            copyOfSubTask.id = NSUUID().uuidString
                            subTaskCopies.append(copyOfSubTask)
                        }
                        task.subTasks.append(objectsIn: subTaskCopies)
                    }
                    task.originalDueDate = followingTargetDay as NSDate
                    task.repeatingSchedule = repeatingSchedule
                    tasksToCreate.append(task)
                    lastSavedTaskDueDate = followingTargetDay //saved to dateToken outside of this method.
                }
            }
        }
        
        //As Tasks are created, make sure that ones due before longer away than the schedule length for the same RLMRepeatingSchedule are removed from Agenda. This behaviour is unique for each method.
        if (tasksToCreate.count > 1) {
            for task in tasksToCreate {
                if (task != tasksToCreate.last && task.scope != "Event") { task.completed = true }
            }
        }
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        //Query past tasks (ones already created) and ensure that they are also removed from Agenda.
        let previousTasksForSameSchedule = realm.objects(RLMTask.self).filter("repeatingSchedule == %@ AND completed == false AND dueDate <= %@ AND scope != %@", repeatingSchedule, pastDate.convertToLatestPossibleTimeOfDay(), "Event")
        for task in previousTasksForSameSchedule {
            if (task.dueDate?.timeIntervalSinceReferenceDate == task.originalDueDate?.timeIntervalSinceReferenceDate && task.repeatingTaskWasUncompleted == false) {
                realm.beginWrite()
                task.completed = true
                do {
                    try realm.commitWrite()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        
        return (tasksToCreate, lastSavedTaskDueDate)
    }
    
    func createTasksAfterInitialTaskForMonthlySchedule(repeatingSchedule: RLMRepeatingSchedule, dateToken: RLMDateToken, calendar: Calendar) -> ([RLMTask], Date) {
        let currentDateAndTime = Date()
        let realm = try! Realm()
        var tasksToCreate = [RLMTask]()
        
        let masterTask = repeatingSchedule.masterTask; var type: String; var course: RLMCourse?; var scope: String
        if (masterTask != nil) { type = masterTask!.type; course = masterTask?.course; scope = masterTask!.scope }
        else { type = repeatingSchedule.type; course = repeatingSchedule.course!; scope = "Event" }
        
        //Keep track of tasks made in the future (via calendar possibly), so that these tasks don't get recreated by this algorithm.
        let tasksAfterDateTokenLastTaskCreatedDueDate = realm.objects(RLMTask.self).filter("originalDueDate >= %@", dateToken.lastTaskCreatedDueDate!)
        
        //Now we keep generating targetDates (dates for which the task would be occur at) up until the current day. We should check to ensure the tasks don't have matching dueDates to any of the originalDueDates in the tasksAfterLastCheckedTask query.
        var followingTargetDay = dateToken.lastTaskCreatedDueDate! as Date
        var lastSavedTaskDueDate = dateToken.lastTaskCreatedDueDate! as Date //used at the end
        let gregorianCal = Calendar(identifier: .gregorian) //Always use a new calendar object instead of reusing an existing one.
        
        let targetDayOfWeek = self.getIntegerValueForWeekdayString(weekdayString: DayOfWeek(rawValue: dateToken.startDayOfWeek)!.rawValue)!
        while (followingTargetDay <= currentDateAndTime || taskShouldBeCreated(followingTargetDay: followingTargetDay, scope: scope, repeatingSchedule: repeatingSchedule)) {
            var lastTaskCreatedDueDateComponents = gregorianCal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: followingTargetDay as Date)
            
            lastTaskCreatedDueDateComponents.hour = (dateToken.startTime! as Date).time.hour
            lastTaskCreatedDueDateComponents.minute = (dateToken.startTime! as Date).time.minute
            followingTargetDay = calendar.date(from: lastTaskCreatedDueDateComponents)! as Date
            //followingTargetDay = calendar.date(byAdding: .day, value: 14, to: followingTargetDay, wrappingComponents: false)!
            followingTargetDay = calendar.date(byAdding: .month, value: 1, to: followingTargetDay, wrappingComponents: false)!
            print("Following Target Day: " + followingTargetDay.description)
            
            var endDateAndTime : Date?
            if (dateToken.endTime != nil) {
                lastTaskCreatedDueDateComponents.hour = (dateToken.endTime! as Date).time.hour
                lastTaskCreatedDueDateComponents.minute = (dateToken.endTime! as Date).time.minute
                endDateAndTime = calendar.date(from: lastTaskCreatedDueDateComponents)!
                if ((dateToken.startTime as Date).time > (dateToken.endTime! as Date).time) {
                    //The recurring school event ends on the following day...(instead of the same day)
                    endDateAndTime = calendar.date(byAdding: .day, value: 1, to: endDateAndTime!, wrappingComponents: false)
                }
            }
           
            if (followingTargetDay <= currentDateAndTime || taskShouldBeCreated(followingTargetDay: followingTargetDay, scope: scope, repeatingSchedule: repeatingSchedule)) {
                var saveTask = true
                for taskCreatedAheadOfTime in tasksAfterDateTokenLastTaskCreatedDueDate { //ensure the task wasn't already created ahead of time somehow (perhaps via the calendar feature shipping in the future)
                    if (taskCreatedAheadOfTime.originalDueDate! as Date == followingTargetDay) {
                        saveTask = false
                        break
                    }
                }
                if (saveTask == true) {
                   
                    var counter = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@", type, course as Any, repeatingSchedule.createdDate).sorted(byKeyPath: "createdDate", ascending: false).count //course can be nil.
                    counter = counter + 1
                    //create task & add to array.
                    let task = RLMTask(name: type + " " + String(counter), type: type, dueDate: followingTargetDay as NSDate, course: course) //set name in other method.
                    task.endDateAndTime = endDateAndTime as NSDate?
                    if (endDateAndTime != nil) {
                        task.timeSet = true
                    }
                    if (masterTask != nil) { task.timeSet = masterTask!.timeSet }
                    if (masterTask != nil) {
                        var subTaskCopies = [RLMSubTask]()
                        for subTask in masterTask!.subTasks {
                            let copyOfSubTask = RLMSubTask(value: subTask)
                            copyOfSubTask.id = NSUUID().uuidString
                            subTaskCopies.append(copyOfSubTask)
                        }
                        task.subTasks.append(objectsIn: subTaskCopies)
                    }
                    task.originalDueDate = followingTargetDay as NSDate
                    task.repeatingSchedule = repeatingSchedule
                    tasksToCreate.append(task)
                    lastSavedTaskDueDate = followingTargetDay //saved to dateToken outside of this method.
                }
            }
        }
        
        //As Tasks are created, make sure that ones due before longer away than the schedule length for the same RLMRepeatingSchedule are removed from Agenda. This behaviour is unique for each method.
        if (tasksToCreate.count > 1) {
            for task in tasksToCreate {
                if (task != tasksToCreate.last && task.scope != "Event") { task.completed = true }
            }
        }
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        //Query past tasks (ones already created) and ensure that they are also removed from Agenda.
        let previousTasksForSameSchedule = realm.objects(RLMTask.self).filter("repeatingSchedule == %@ AND completed == false AND dueDate <= %@ AND scope != %@", repeatingSchedule, pastDate.convertToLatestPossibleTimeOfDay(), "Event")
        for task in previousTasksForSameSchedule {
            if (task.dueDate?.timeIntervalSinceReferenceDate == task.originalDueDate?.timeIntervalSinceReferenceDate && task.repeatingTaskWasUncompleted == false) {
                //if ((task.dueDate?.numberOfDaysUntilDate())! >= 1) { //handled in query.
                realm.beginWrite()
                task.completed = true
                do {
                    try realm.commitWrite()
                } catch let error {
                    print(error.localizedDescription)
                }
                //}
            }
        }
        
        return (tasksToCreate, lastSavedTaskDueDate)
    }
    
    func taskShouldBeCreated(followingTargetDay: Date, scope: String, repeatingSchedule: RLMRepeatingSchedule) -> Bool {
        if (scope == "Event") {
            if (Calendar.current.isDateInToday(followingTargetDay)) {
                return true
            } else {
                return false
            }
        } else
        if (scope == "Regular") {
            if (repeatingSchedule.schedule == "Weekly") {
                if (followingTargetDay.numberOfDaysUntilDate() <= 6) {
                    return true
                } else {
                    return false
                }
            }
            if (repeatingSchedule.schedule == "Bi-Weekly") {
                if (followingTargetDay.numberOfDaysUntilDate() <= 13) {
                    return true
                } else {
                    return false
                }
            }
            if (repeatingSchedule.schedule == "Monthly") {
                if (followingTargetDay.numberOfDaysUntilDate() <= 30) { //Should technically be the following month's # of days - 1
                    return true
                } else {
                    return false
                }
            }
            if (followingTargetDay.overTwoWeeksAway() == false) {
                return true
            } else {
                return false
            }
        } else {
            //crash since it is not being handled whatever the scope is.
            fatalError()
        }
        return false
    }
    
    ////////////
    
    //For edge cases like the one in weekly schedule. Be sure to modify to support schedules other than weekly if needed.
    func oneMoreTask(repeatingSchedule: RLMRepeatingSchedule, dateToken: RLMDateToken, calendar: Calendar) -> (RLMTask?, Date) {
        let currentDateAndTime = Date()
        let realm = try! Realm()
        var taskToCreate: RLMTask?
        
        let masterTask = repeatingSchedule.masterTask; var type: String; var course: RLMCourse?; var scope: String
        if (masterTask != nil) { type = masterTask!.type; course = masterTask?.course; scope = masterTask!.scope }
        else { type = repeatingSchedule.type; course = repeatingSchedule.course!; scope = "Event" }
        
        //Keep track of tasks made in the future (via calendar possibly), so that these tasks don't get recreated by this algorithm.
        let tasksAfterDateTokenLastTaskCreatedDueDate = realm.objects(RLMTask.self).filter("originalDueDate >= %@", dateToken.lastTaskCreatedDueDate!)
        
        //Now we keep generating targetDates (dates for which the task would be occur at) up until the current day. We should check to ensure the tasks don't have matching dueDates to any of the originalDueDates in the tasksAfterLastCheckedTask query.
        var followingTargetDay = dateToken.lastTaskCreatedDueDate! as Date
        var lastSavedTaskDueDate = dateToken.lastTaskCreatedDueDate! as Date //used at the end
        
        let gregorianCal = Calendar(identifier: .gregorian) //Always use a new calendar object instead of reusing an existing one.

        var lastTaskCreatedDueDateComponents = gregorianCal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: followingTargetDay as Date)
            
        lastTaskCreatedDueDateComponents.hour = (dateToken.startTime! as Date).time.hour
        lastTaskCreatedDueDateComponents.minute = (dateToken.startTime! as Date).time.minute
        followingTargetDay = calendar.date(from: lastTaskCreatedDueDateComponents)! as Date
        if (repeatingSchedule.schedule == "Weekly") {
            followingTargetDay = calendar.date(byAdding: .day, value: 7, to: followingTargetDay, wrappingComponents: false)!
        }
        print("Following Target Day: " + followingTargetDay.description)
            
        var endDateAndTime : Date?
        if (dateToken.endTime != nil) {
            lastTaskCreatedDueDateComponents.hour = (dateToken.endTime! as Date).time.hour
            lastTaskCreatedDueDateComponents.minute = (dateToken.endTime! as Date).time.minute
            endDateAndTime = calendar.date(from: lastTaskCreatedDueDateComponents)!
            if ((dateToken.startTime as Date).time > (dateToken.endTime! as Date).time) {
                //The recurring school event ends on the following day...(instead of the same day)
                endDateAndTime = calendar.date(byAdding: .day, value: 1, to: endDateAndTime!, wrappingComponents: false)
            }
        }
        var saveTask = true
        for taskCreatedAheadOfTime in tasksAfterDateTokenLastTaskCreatedDueDate { //ensure the task wasn't already created ahead of time somehow (perhaps via the calendar feature shipping in the future)
            if (taskCreatedAheadOfTime.originalDueDate! as Date == followingTargetDay) {
                saveTask = false
                break
            }
        }
        if (saveTask == true) {
            //let tasksOfSameTypeAndSameCourse = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@ AND recurringSchoolEvent = %@", recurringSchoolEvent.type, recurringSchoolEvent.course!, recurringSchoolEvent.createdDate, recurringSchoolEvent).sorted(byKeyPath: "createdDate", ascending: false)
            var counter = realm.objects(RLMTask.self).filter("type = %@ AND course = %@ AND createdDate <= %@", type, course as Any, repeatingSchedule.createdDate).sorted(byKeyPath: "createdDate", ascending: false).count //course can be nil.
            counter = counter + 1
            //create task & add to array.
            let task = RLMTask(name: type + " " + String(counter), type: type, dueDate: followingTargetDay as NSDate, course: course) //set name in other method.
            task.endDateAndTime = endDateAndTime as NSDate?
            if (endDateAndTime != nil) {
                task.timeSet = true
            }
            if (masterTask != nil) { task.timeSet = masterTask!.timeSet }
            if (masterTask != nil) {
                var subTaskCopies = [RLMSubTask]()
                for subTask in masterTask!.subTasks {
                    let copyOfSubTask = RLMSubTask(value: subTask)
                    copyOfSubTask.id = NSUUID().uuidString
                    subTaskCopies.append(copyOfSubTask)
                }
                task.subTasks.append(objectsIn: subTaskCopies)
            }
            task.originalDueDate = followingTargetDay as NSDate
            task.repeatingSchedule = repeatingSchedule
            taskToCreate = task
            lastSavedTaskDueDate = followingTargetDay //saved to dateToken outside of this method.
            
        }
        
        return (taskToCreate, lastSavedTaskDueDate)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        AppEvents.activateApp()
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func addCourses() {
        let course = PFObject(className: "Course")
        course.setObject("CS2209", forKey: "courseCode")
        course.setObject("Applied Logic for Computer Science", forKey: "courseName")
        course.setObject(0, forKey: "enrollment")
        course.setObject("Western University", forKey: "university")
        course.setObject("Computer Science", forKey: "faculty")
        course.setObject("semesterSystem", forKey: "semesterType")
        //course.saveInBackgroundWithBlock({ (succeed, error) -> Void in
            
        //})
        PFObject.saveAll(inBackground: [course])
    }
    
    /*func getKey() -> Data {
        // Identifier for our keychain entry - should be unique for your application
        let keychainIdentifier = "io.Realm.B4Grad12345"
        let keychainIdentifierData = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        // First check in the keychain for an existing key
        var query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecReturnData: true as AnyObject
        ]
        
        // To avoid Swift optimization bug, should use withUnsafeMutablePointer() function to retrieve the keychain item
        // See also: http://stackoverflow.com/questions/24145838/querying-ios-keychain-using-swift/27721328#27721328
        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as! Data
        }
        
        // No pre-existing key from this application, so generate a new one
        var keyData = Data(count: 64)
        _ = keyData.withUnsafeMutableBytes { mutableBytes in
            SecRandomCopyBytes(kSecRandomDefault, keyData.count, mutableBytes)
        }
        //let keyData = NSMutableData(length: 64)!
        //SecRandomCopyBytes(kSecRandomDefault, 64, UnsafeMutablePointer<UInt8>(keyData.mutableBytes))
        
        // Store the key in the keychain
        query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecValueData: keyData as AnyObject
        ]
        
        status = SecItemAdd(query as CFDictionary, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain")
        
        return keyData as Data
    }*/
    
    /*func getDayOfWeekOfDate(date: Date) -> String {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: date)
        if (weekDay == 1) { return DayOfWeek.sunday.rawValue } else if (weekDay == 2) { return DayOfWeek.monday.rawValue } else if (weekDay == 3) { return DayOfWeek.tuesday.rawValue } else if (weekDay == 4) { return DayOfWeek.wednesday.rawValue } else if (weekDay == 5) { return DayOfWeek.thursday.rawValue } else if (weekDay == 6) { return DayOfWeek.friday.rawValue } else if (weekDay == 7) { return DayOfWeek.saturday.rawValue } else {
            print("getDayOfWeekOfDay(..) Failed.")
            return "Monday"
        }
    }*/
    
    func getIntegerValueForWeekdayString(weekdayString: String) -> Int? {
        switch weekdayString {
        case "Sunday":
            return 1
        case "Monday":
            return 2
        case "Tuesday":
            return 3
        case "Wednesday":
            return 4
        case "Thursday":
            return 5
        case "Friday":
            return 6
        case "Saturday":
            return 7
        default:
            return nil
        }
    }
    
    // MARK: - Facebook SDK
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        // Add any custom logic here.
        
        return handled
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "test.EasyHomework" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "EasyHomework", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

