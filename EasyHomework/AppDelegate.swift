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
import UserNotifications
import SwiftyStoreKit

typealias userHandler = ((_ success: Bool) -> (Void))
typealias linkHandler = ((_ url: URL?) -> (Void))

let service = "myService"
let account = "myAccount"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, KochavaTrackerDelegate {

    struct Notification1 {

        struct Category {
            static let tutorial = "tutorial"
        }

        struct Action {
            static let Completed = "Completed"
            static let RemindMeHour = "RemindMeHour"
            static let RemindTomorrow = "RemindTomorrow"
        }

    }

    var window: UIWindow?

    var taskManagers = [UITableView?]() //UITableViews that contain tasks that the user can swipe, etc.
    //Use the above variable to track and reload taskManagers from any screen. Add them via viewDidLoad().
    //If there any performance issues with completing/uncompleting tasks or with setting dates, check any code
    //using the above array.

    var taskId = ""

    var remindertext1 = ""
    var remindertext2 = ""
    var remindertext3 = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        /*UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
        }*/

        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                break
            case .authorized:
               // self.configureUserNotificationsCenter()
                // Schedule Local Notification
                self.setRemindersNotifications()
            case .denied:
                print("Application Not Allowed to Display Notifications")
            case .provisional: break

            @unknown default: break

            }
        }

        //configureUserNotificationsCenter()
        //** Realm **//
        //*** Migrations ***//
        let configuration = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 7,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
                if (oldSchemaVersion < 7) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = configuration

        //*** End of Migrations ***//
        
        //SwiftyStoreKit method below must be called at launch.
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }

        //** Parse **//

        //Parse.setApplicationId("p1eGg31YomJ7I6fP8hr2yehTHQhvtSHXw2FwOOCw",
            //clientKe6y: "KgZVJRNHsys0mkARKI537s4Z3v85bQX2Z00o2lzr")

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
        print(realm.configuration.fileURL ?? "NO URL")
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
        self.setRemindersNotifications()
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
        setupDefaultRemindeSettings()
        
        let appLaunchedBefore = UserDefaults.standard.bool(forKey: "AppLaunchedBefore") //User has launched app for very first time if this is false.
        
        
        let expiryDateOfLastPurchase = UserDefaults.standard.double(forKey: "ExpiryDateOfLastPurchase") //timeIntervalSinceReferenceDate (which is a double). If this is not = 0 (default value set by UserDefaults), then forceRefresh the receipt on app launch, since they have purchased in the past USING THIS DEVICE
        
        let isPreReminderSet = UserDefaults.standard.bool(forKey: "IsPreReminderSet")
        
        let isRestore = UserDefaults.standard.bool(forKey: "IsRestoreDefaults")

        let dateSinceFirstLaunched = UserDefaults.standard.object(forKey: "DateSinceFirstLaunched") //stores date of when the app was first launched by the user
        if (appLaunchedBefore == false || dateSinceFirstLaunched == nil) {
            UserDefaults.standard.set(Date(), forKey: "DateSinceFirstLaunched")
        }
        
        let hasDiscount = UserDefaults.standard.bool(forKey: "HasDiscount") //Default is false.
        
        let subscriptionTimerExpired = UserDefaults.standard.bool(forKey: "TimerExpired")
        
        let lifetimePurchaser = UserDefaults.standard.bool(forKey: "LifetimePurchaser")

        if let notif = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
            let userInfoObject = notif.userInfo as! [String : String]
            self.taskId = userInfoObject["id"]!
        }
        return true
    }
    
    func requestForPushNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
        }

        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                break
            case .authorized:
               // self.configureUserNotificationsCenter()
                // Schedule Local Notification
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                appdelegate.setRemindersNotifications()
            case .denied:
                print("Application Not Allowed to Display Notifications")
            case .provisional: break

            @unknown default: break

            }
        }
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

    //IMPORTANT: When modifying one of the below methods, be sure to modify the other types as well (Weekly, Bi-Weekly, etc.) AND also modify oneMoreTask(..) method further down this file.

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
                            copyOfSubTask.completed = false
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
                            copyOfSubTask.completed = false
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
                            copyOfSubTask.completed = false
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
                            copyOfSubTask.completed = false
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
                    copyOfSubTask.completed = false
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

    func setupDefaultRemindeSettings(){
        var taskTypes : [Int : Array<String>] = [0 : [], 1 : ["Assignments", "Quizzes", "Midterms", "Finals"], 2: ["Lectures", "Tutorials", "Labs"], 3: ["Restore Defaults"]]

        let realm = try! Realm()
        let reminderSettings = realm.objects(RLMReminderSetting.self)
        print(reminderSettings.count)
        if reminderSettings.count == 0 {
            var i = 1
            for key in 1..<4 {
                //let str = (self.taskTypes as NSDictionary).allKeys(for: key) as! [String]
                let arrSettings = taskTypes[key]
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
        }
    }

    func setRandomMonthlyNotification(){
        let displayName = PFUser.current()?.object(forKey: "displayName") as? String
        if displayName != nil {
            self.remindertext1 = "Hey \(displayName!), you have not opened B4Grad in awhile! Why not check on your tasks, we don't want you to miss anything."
            self.remindertext2 = "Oh Hai \(displayName!), you haven't created new tasks in awhile. Why not set a new goal for yourself?"
            self.remindertext3 = "Hi \(displayName!), it has been awhile since you last used B4Grad. There is no better time to organize your classes or prepare for next semester."
        } else {
            self.remindertext1 = "Hey, you have not opened B4Grad in awhile! Why not check on your tasks, we don't want you to miss anything."
            self.remindertext2 = "Oh Hai, you haven't created new tasks in awhile. Why not set a new goal for yourself?"
            self.remindertext3 = "Hi, it has been awhile since you last used B4Grad. There is no better time to organize your classes or prepare for next semester."
        }
        let arrTexts = [self.remindertext1, self.remindertext2, self.remindertext3]
        let randomText = arrTexts.randomItem()

        let notification = UILocalNotification()
        notification.fireDate = NSDate().addingTimeInterval(TimeInterval(60*60*24*30)) as Date
        notification.alertBody = randomText!
        notification.repeatInterval = NSCalendar.Unit.month
        notification.alertAction = "Reminder!"
        notification.alertTitle = "Reminder!"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
    }

    func setAlreadySavedNotification() -> Int {
        var notificationCount = 0
        let userDefaults = UserDefaults.standard
        if (userDefaults.value(forKey: "notifications") != nil) {

            let arrNotifications = (userDefaults.value(forKey: "notifications") as! NSArray).mutableCopy() as! NSMutableArray

            var i = 0
            for dict in arrNotifications{
                let notifdict = dict as! [String : Any]
                let notifDate = notifdict["notificationdate"] as! Date
                if notifDate <= Date() {
                    arrNotifications.removeObject(at: i)
                }
                i += 1
            }


            userDefaults.set(arrNotifications, forKey: "notifications")
            userDefaults.synchronize()

            for dict in arrNotifications{
                let notifdict = dict as! [String : Any]
                let strid = notifdict["task"] as! String
                let realm = try! Realm()
                let tasks = realm.objects(RLMTask.self).filter("id == %@", strid)
                let unarchivedTask = tasks.first!
                //let unarchivedTask = NSKeyedUnarchiver.unarchiveObject(with: notifdict["task"] as! Data) as! RLMTask
                let notificationid = notifdict["id"] as! String
                let notificationDate = notifdict["notificationdate"] as! Date
                let priority = notifdict["priority"] as! String
                print(notifdict["priority"])
                print(notifdict["priority"] as! String)
                let reminder = RLMReminder(selectedID: Int(notifdict["priority"] as! String)!, notificationId: "1", date: NSDate())
                let strNotificationText = self.getNotificationString(task: unarchivedTask, reminder: reminder)
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = "Reminder!"
                notificationContent.body = strNotificationText
                notificationContent.userInfo = ["id" : unarchivedTask.id, "priority" : priority]
                notificationContent.sound = UNNotificationSound.default()
                // Set Category Identifier
                notificationContent.categoryIdentifier = Notification1.Category.tutorial

                let timeInterval = notificationDate.timeIntervalSince(Date())
                let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)


                    notificationCount = notificationCount + 1
                    // Create Notification Request
                    let notificationRequest = UNNotificationRequest(identifier:"\(Date().millisecondsSince1970)\(self.randomString(length: 25))" , content: notificationContent, trigger: notificationTrigger)

                    UNUserNotificationCenter.current().add(notificationRequest) { (error) in
                        if let error = error {
                            print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                        }
                    }

            }

        }
        return notificationCount
    }

    func setRemindersNotifications(){
        var isNotificationAvailable = false
        //UIApplication.shared.cancelAllLocalNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        self.configureUserNotificationsCenter()
        let notificationCount = self.setAlreadySavedNotification()
        var arrNotifications = [Any]()
        let realm = try! Realm()
        
       
        let currentDateAndTime = NSDate()
        let tasks = realm.objects(RLMTask.self).filter("dueDate >= %@ AND repeatingSchedule == null AND completed = false",currentDateAndTime)
        var totalCount = 0
        for task in tasks {
            if task.removed == false {

                for reminder in task.reminders{
                    var dictUserInfo = ["id" : task.id]
                    var dict = ["priority" : 0] as [String : Any]
                    let strNotificationText = self.getNotificationString(task: task, reminder: reminder)
                    var components : DateComponents? = nil
                    if reminder.reminderDate != nil {
                        components = (Calendar.current as NSCalendar).components([.hour, .minute, .second], from: reminder.reminderDate! as Date)
                    }
                    let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
                    var notificationDate : NSDate? = nil
                    if reminder.selectedID == 1 {
                        notificationDate = task.dueDate
                        dict["priority"] = 5
                    } else if reminder.selectedID == 2 {
                        notificationDate = task.dueDate?.addingTimeInterval(-60*5)
                        dict["priority"] = 6
                    } else if reminder.selectedID == 3 {
                        notificationDate = task.dueDate?.addingTimeInterval(-60*15)
                        dict["priority"] = 7
                    } else if reminder.selectedID == 4 {
                        notificationDate = task.dueDate?.addingTimeInterval(-60*30)
                        dict["priority"] = 8
                    } else if reminder.selectedID == 5 {
                        notificationDate = task.dueDate?.addingTimeInterval(-60*60)
                        dict["priority"] = 9
                    } else if reminder.selectedID == 6 {
                        notificationDate = task.dueDate?.addingTimeInterval(-60*(60*2))
                        dict["priority"] = 10
                    } else if reminder.selectedID == 7 {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd HH:mm"
                        notificationDate = task.dueDate?.addingTimeInterval(-60*(60*24))
                        notificationDate = calendar.date(bySettingHour: components!.hour!, minute: components!.minute!, second: 0, of: notificationDate! as Date, options: NSCalendar.Options.matchFirst)! as NSDate
                        dict["priority"] = 11

                    } else if reminder.selectedID == 8 {
                        notificationDate = task.dueDate?.addingTimeInterval(-60*(60*24*3))
                        notificationDate = calendar.date(bySettingHour: components!.hour!, minute: components!.minute!, second: 0, of: notificationDate! as Date, options: NSCalendar.Options.matchFirst)! as NSDate
                        dict["priority"] = 12
                    } else if reminder.selectedID == 9 {
                        notificationDate = task.dueDate?.addingTimeInterval(-60*(60*24*7))
                        notificationDate = calendar.date(bySettingHour: components!.hour!, minute: components!.minute!, second: 0, of: notificationDate! as Date, options: NSCalendar.Options.matchFirst)! as NSDate
                        dict["priority"] = 13
                    } else if reminder.selectedID == 10 {
                        notificationDate = task.dueDate?.addingTimeInterval(-60*(60*24*14))
                        notificationDate = calendar.date(bySettingHour: components!.hour!, minute: components!.minute!, second: 0, of: notificationDate! as Date, options: NSCalendar.Options.matchFirst)! as NSDate
                        dict["priority"] = 14
                    } else if reminder.selectedID == 11 {
                        notificationDate = task.dueDate?.addingTimeInterval(-60*(60*24*30))
                        notificationDate = calendar.date(bySettingHour: components!.hour!, minute: components!.minute!, second: 0, of: notificationDate! as Date, options: NSCalendar.Options.matchFirst)! as NSDate
                        dict["priority"] = 15
                    }
                    dictUserInfo["priority"] = "\(dict["priority"]!)"
                    let currentDate = Date()
                    if notificationDate! as Date > currentDate {
                        totalCount = totalCount + 1
//                        let notification = UILocalNotification()
//                        notification.fireDate = (notificationDate! as Date)
//                        notification.alertBody = strNotificationText
//                        notification.alertAction = "Reminder!"
//                        notification.alertTitle = "Reminder!"
//                        notification.userInfo = dictUserInfo
//                        notification.soundName = UILocalNotificationDefaultSoundName
//                        dict["notification"] = notification
//                        arrNotifications.append(dict)

                        let notificationContent = UNMutableNotificationContent()
                        notificationContent.title = "Reminder!"
                        notificationContent.body = strNotificationText
                        notificationContent.userInfo = dictUserInfo
                        notificationContent.sound = UNNotificationSound.default()
                        // Set Category Identifier
                        notificationContent.categoryIdentifier = Notification1.Category.tutorial

                        let timeInterval = (notificationDate! as Date).timeIntervalSince(Date())
                        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

                        // Create Notification Request
                        let notificationRequest = UNNotificationRequest(identifier:"\(Date().millisecondsSince1970)\(self.randomString(length: 25))" , content: notificationContent, trigger: notificationTrigger)

                        dict["notification"] = notificationRequest
                        arrNotifications.append(dict)

                    }

                }
            }

        }

        let repeatingScheduleTasks = realm.objects(RLMTask.self).filter("repeatingSchedule != null AND completed = false",currentDateAndTime)
        for task in repeatingScheduleTasks {

            if task.removed == false {
                var strNotificationText = ""
                //print(task.dueDate)
                //print(task.removed)
                if task.name == "" {
                    strNotificationText = task.type
                } else {
                    strNotificationText = task.name
                }

                //let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
                //let defaultDate = calendar.date(bySettingHour: 14, minute: 59, second: 0, of: Date(), options: NSCalendar.Options.matchFirst)! as NSDate

                if (task.repeatingSchedule?.schedule == "Daily") {
                    // for i in 1..<8 {

                    //  if (task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24))))! as Date > currentDateAndTime as Date {
                    totalCount = totalCount + 1

                    //let notification = UILocalNotification()
                    //notification.fireDate = task.dueDate as Date?
                    //notification.repeatInterval = NSCalendar.Unit.day
                    //notification.alertBody = "\(strNotificationText) due now"
                    //notification.alertAction = "Reminder!"
                    //notification.alertTitle = "Reminder!"
                    //let dictUserInfo = ["id" : task.id]
                    //notification.userInfo = dictUserInfo
                    //notification.soundName = UILocalNotificationDefaultSoundName
                    //let dict = ["notification" : notification, "priority" : 4] as [String : Any]
                    //arrNotifications.append(dict)

                    let dictUserInfo = ["id" : task.id , "priority" : "4"]
                    let notificationContent = UNMutableNotificationContent()
                    notificationContent.title = "Reminder!"
                    notificationContent.body = strNotificationText
                    notificationContent.userInfo = dictUserInfo
                    notificationContent.sound = UNNotificationSound.default()
                    // Set Category Identifier
                    notificationContent.categoryIdentifier = Notification1.Category.tutorial

                    let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second], from: task.dueDate! as Date)
                    let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)

                    // Create Notification Request
                    let notificationRequest = UNNotificationRequest(identifier:"\(Date().millisecondsSince1970)\(self.randomString(length: 25))" , content: notificationContent, trigger: notificationTrigger)

                    let dict = ["notification" : notificationRequest, "priority" : 4] as [String : Any]
                    arrNotifications.append(dict)


                    //  }
                    // }
                } else if (task.repeatingSchedule?.schedule == "Weekly") {
                    // for i in 1..<5 {
                    //  if (task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24*7))))! as Date > currentDateAndTime as Date {
                    totalCount = totalCount + 1

//                    let notification = UILocalNotification()
//                    notification.fireDate = task.dueDate as Date?
//                    // notification.fireDate = task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24*7))) as! Date
//                    notification.alertBody = strNotificationText
//                    notification.repeatInterval = NSCalendar.Unit.weekday
//                    notification.alertAction = "Reminder!"
//                    notification.alertTitle = "Reminder!"
//                    let dictUserInfo = ["id" : task.id]
//                    notification.userInfo = dictUserInfo
//                    notification.soundName = UILocalNotificationDefaultSoundName
//                    let dict = ["notification" : notification, "priority" : 3] as [String : Any]
//                    arrNotifications.append(dict)

                    let dictUserInfo = ["id" : task.id , "priority" : "3"]
                    let notificationContent = UNMutableNotificationContent()
                    notificationContent.title = "Reminder!"
                    notificationContent.body = strNotificationText
                    notificationContent.userInfo = dictUserInfo
                    notificationContent.sound = UNNotificationSound.default()
                    // Set Category Identifier
                    notificationContent.categoryIdentifier = Notification1.Category.tutorial

                    let triggerDaily = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: task.dueDate! as Date)
                    let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)

                    // Create Notification Request
                    let notificationRequest = UNNotificationRequest(identifier:"\(Date().millisecondsSince1970)\(self.randomString(length: 25))" , content: notificationContent, trigger: notificationTrigger)

                    let dict = ["notification" : notificationRequest, "priority" : 3] as [String : Any]
                    arrNotifications.append(dict)

                    //     }
                    //  }
                }else
                    if (task.repeatingSchedule?.schedule == "Bi-Weekly") {
                        // for i in 1..<5 {
                        //    if (task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24*14))))! as Date > currentDateAndTime as Date {
                        totalCount = totalCount + 1

//                        let notification = UILocalNotification()
//                        notification.fireDate = task.dueDate as Date?
//                        //notification.fireDate = task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24*14))) as! Date
//                        notification.alertBody = strNotificationText
//                        notification.repeatInterval = NSCalendar.Unit.weekdayOrdinal
//                        notification.alertAction = "Reminder!"
//                        notification.alertTitle = "Reminder!"
//                        let dictUserInfo = ["id" : task.id]
//                        notification.userInfo = dictUserInfo
//                        notification.soundName = UILocalNotificationDefaultSoundName
//                        let dict = ["notification" : notification, "priority" : 2] as [String : Any]
//                        arrNotifications.append(dict)



                        //  }
                        //  }
                    }else
                        if (task.repeatingSchedule?.schedule == "Monthly") {
                            //  for i in 1..<5 {
                            //      if (task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24*30))))! as Date > currentDateAndTime as Date {
                            totalCount = totalCount + 1
//                            let notification = UILocalNotification()
//                            notification.fireDate = task.dueDate as Date?
//                            //notification.fireDate = task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24*30))) as! Date
//                            notification.alertBody = strNotificationText
//                            notification.repeatInterval = NSCalendar.Unit.month
//                            notification.alertAction = "Reminder!"
//                            notification.alertTitle = "Reminder!"
//                            let dictUserInfo = ["id" : task.id]
//                            notification.userInfo = dictUserInfo
//                            notification.soundName = UILocalNotificationDefaultSoundName
//                            let dict = ["notification" : notification, "priority" : 1] as [String : Any]
//                            arrNotifications.append(dict)

                            let dictUserInfo = ["id" : task.id , "priority" : "1"]
                            let notificationContent = UNMutableNotificationContent()
                            notificationContent.title = "Reminder!"
                            notificationContent.body = strNotificationText
                            notificationContent.userInfo = dictUserInfo
                            notificationContent.sound = UNNotificationSound.default()
                            // Set Category Identifier
                            notificationContent.categoryIdentifier = Notification1.Category.tutorial

                            let triggerDaily = Calendar.current.dateComponents([.month, .hour, .minute, .second], from: task.dueDate! as Date)
                            let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)

                            // Create Notification Request
                            let notificationRequest = UNNotificationRequest(identifier:"\(Date().millisecondsSince1970)\(self.randomString(length: 25))" , content: notificationContent, trigger: notificationTrigger)

                            let dict = ["notification" : notificationRequest, "priority" : 1] as [String : Any]
                            arrNotifications.append(dict)
                            //     }
                            // }
                }
            }


        }

        if totalCount > 63 - notificationCount {
            //monthly = 6
            //weekly = 4
            //bi-weekly = 4
            //daily = 8
            //other 42
            var arrremainingNotifications = [Any]()
            var arrpriority1 = [Any]()
            var arrpriority2 = [Any]()
            var arrpriority3 = [Any]()
            var arrpriority4 = [Any]()
            var arrpriority5 = [Any]()
            var arrpriority6 = [Any]()
            var arrpriority7 = [Any]()
            var arrpriority8 = [Any]()
            var arrpriority9 = [Any]()
            var arrpriority10 = [Any]()
            var arrpriority11 = [Any]()
            var arrpriority12 = [Any]()
            var arrpriority13 = [Any]()
            var arrpriority14 = [Any]()
            var arrpriority15 = [Any]()
            for object in arrNotifications{
                let priority = (object as! [String : Any])["priority"] as! Int
                if priority == 1 {
                    arrpriority1.append(object)
                } else if priority == 2 {
                    arrpriority2.append(object)
                } else if priority == 3 {
                    arrpriority3.append(object)
                } else if priority == 4 {
                    arrpriority4.append(object)
                } else if priority == 5 {
                    arrpriority5.append(object)
                } else if priority == 6 {
                    arrpriority6.append(object)
                } else if priority == 7 {
                    arrpriority7.append(object)
                } else if priority == 8 {
                    arrpriority8.append(object)
                } else if priority == 9 {
                    arrpriority9.append(object)
                } else if priority == 10 {
                    arrpriority10.append(object)
                } else if priority == 11 {
                    arrpriority11.append(object)
                } else if priority == 12 {
                    arrpriority12.append(object)
                } else if priority == 13 {
                    arrpriority13.append(object)
                } else if priority == 14 {
                    arrpriority14.append(object)
                } else if priority == 15 {
                    arrpriority15.append(object)
                }
            }
            var remainingCount = 63 - notificationCount
            //var totalCount = 0

            if arrpriority1.count > 0 || arrpriority2.count > 0 ||  arrpriority3.count > 0 ||  arrpriority4.count > 0 {
//                let notification = UILocalNotification()
//                notification.fireDate = NSDate().addingTimeInterval(TimeInterval(60*60*24*30)) as Date
//                notification.alertBody = "Why not check on your calendar? Maybe there is something you should be reminded of!"
//                notification.repeatInterval = NSCalendar.Unit.month
//                notification.alertAction = "Reminder!"
//                notification.alertTitle = "Reminder!"
//                notification.soundName = UILocalNotificationDefaultSoundName
//                UIApplication.shared.scheduleLocalNotification(notification)
//                isNotificationAvailable = true
//                remainingCount = remainingCount - 1
            }
            if remainingCount > 0 {
                if arrpriority1.count >= remainingCount {
                    for i in 0..<remainingCount{
                        //let notifObject = (arrpriority1[i] as! [String : Any])["notification"] as! UILocalNotification
                       // UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority1[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        //totalCount = totalCount + 1
                        remainingCount = remainingCount - 1
                    }
                    //for i in 7..<arrpriority1.count{
                    //    arrremainingNotifications.append(arrpriority1[i])
                    //}
                } else {
                    //remainingCount = remainingCount + 6 - arrpriority1.count
                    for object in arrpriority1 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        //totalCount = totalCount + 1
                        remainingCount = remainingCount - 1
                    }

                }
            }
            if remainingCount > 0 {
                if arrpriority2.count > remainingCount {
                    for i in 0..<remainingCount{
//                        let notifObject = (arrpriority2[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority2[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        //totalCount = totalCount + 1
                        remainingCount = remainingCount - 1
                    }
                    //for i in 5..<arrpriority2.count{
                    //    arrremainingNotifications.append(arrpriority2[i])
                    //}
                } else {
                    //remainingCount = remainingCount + 4 - arrpriority2.count
                    for object in arrpriority2 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        //totalCount = totalCount + 1
                        remainingCount = remainingCount - 1
                    }
                }
            }
            if remainingCount > 0 {
                if arrpriority3.count >= remainingCount {
                    for i in 0..<remainingCount{
//                        let notifObject = (arrpriority3[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority3[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        //totalCount = totalCount + 1
                        remainingCount = remainingCount - 1
                    }
                    //for i in 5..<arrpriority3.count{
                    //    arrremainingNotifications.append(arrpriority3[i])
                    //}
                } else {
                    //remainingCount = remainingCount + 4 - arrpriority3.count
                    for object in arrpriority3 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        //totalCount = totalCount + 1
                        remainingCount = remainingCount - 1
                    }

                }
            }
            if remainingCount > 0 {
                if arrpriority4.count >= remainingCount {
                    for i in 0..<remainingCount{
//                        let notifObject = (arrpriority4[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority4[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        //totalCount = totalCount + 1
                        remainingCount = remainingCount - 1
                    }
                    //for i in 8..<arrpriority4.count{
                    //    arrremainingNotifications.append(arrpriority4[i])
                    //}
                } else {
                    //remainingCount = remainingCount + 8 - arrpriority4.count
                    for object in arrpriority4 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        //totalCount = totalCount + 1
                        remainingCount = remainingCount - 1
                    }
                }
            }

            //remainingCount = remainingCount + 42
            if remainingCount > 0 {
                if arrpriority5.count >= remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority5[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority5[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority5.count{
                        arrremainingNotifications.append(arrpriority5[i])
                    }
                } else {
                    for object in arrpriority5 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            }

            if remainingCount > 0 {
                if arrpriority6.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority6[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority6[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority6.count{
                        arrremainingNotifications.append(arrpriority6[i])
                    }
                } else {
                    for object in arrpriority6 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            } else {
                for object in arrpriority6 {
                    arrremainingNotifications.append(object)
                }
            }

            if remainingCount > 0 {
                if arrpriority7.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority7[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority7[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority7.count{
                        arrremainingNotifications.append(arrpriority7[i])
                    }
                } else {
                    for object in arrpriority7 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            } else {
                for object in arrpriority7 {
                    arrremainingNotifications.append(object)
                }
            }

            if remainingCount > 0 {
                if arrpriority8.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority8[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority8[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority8.count{
                        arrremainingNotifications.append(arrpriority8[i])
                    }
                } else {
                    for object in arrpriority8 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            } else {
                for object in arrpriority8 {
                    arrremainingNotifications.append(object)
                }
            }

            if remainingCount > 0 {
                if arrpriority9.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority9[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority9[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority9.count{
                        arrremainingNotifications.append(arrpriority9[i])
                    }
                } else {
                    for object in arrpriority9 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            } else {
                for object in arrpriority9 {
                    arrremainingNotifications.append(object)
                }
            }

            if remainingCount > 0 {
                if arrpriority10.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority10[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority10[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority10.count{
                        arrremainingNotifications.append(arrpriority10[i])
                    }
                } else {
                    for object in arrpriority10 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            } else {
                for object in arrpriority10 {
                    arrremainingNotifications.append(object)
                }
            }

            if remainingCount > 0 {
                if arrpriority11.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority11[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority11[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority11.count{
                        arrremainingNotifications.append(arrpriority11[i])
                    }
                } else {
                    for object in arrpriority11 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            } else {
                for object in arrpriority11 {
                    arrremainingNotifications.append(object)
                }
            }

            if remainingCount > 0 {
                if arrpriority12.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority12[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority12[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority12.count{
                        arrremainingNotifications.append(arrpriority12[i])
                    }
                } else {
                    for object in arrpriority12 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            } else {
                for object in arrpriority12 {
                    arrremainingNotifications.append(object)
                }
            }

            if remainingCount > 0 {
                if arrpriority13.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority13[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority13[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority13.count{
                        arrremainingNotifications.append(arrpriority13[i])
                    }
                } else {
                    for object in arrpriority13 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            } else {
                for object in arrpriority13 {
                    arrremainingNotifications.append(object)
                }
            }

            if remainingCount > 0 {
                if arrpriority14.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority14[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority14[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority14.count{
                        arrremainingNotifications.append(arrpriority14[i])
                    }
                } else {
                    for object in arrpriority14 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            } else {
                for object in arrpriority14 {
                    arrremainingNotifications.append(object)
                }
            }

            if remainingCount > 0 {
                if arrpriority15.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority15[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority15[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                    for i in remainingCount..<arrpriority15.count{
                        arrremainingNotifications.append(arrpriority15[i])
                    }
                } else {
                    for object in arrpriority15 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        isNotificationAvailable = true
                        remainingCount = remainingCount - 1
                    }
                }
            } else {
                for object in arrpriority15 {
                    arrremainingNotifications.append(object)
                }
            }


            if remainingCount > 0 {
                setRemainingNotifications(notifications: arrremainingNotifications, notificationcount: remainingCount)
            }


        } else {
            for object in arrNotifications{
//                let notif = (object as! [String : Any])["notification"] as! UILocalNotification
//                UIApplication.shared.scheduleLocalNotification(notif)
                let notif = (object as! [String : Any])["notification"] as! UNNotificationRequest
                UNUserNotificationCenter.current().add(notif) { (error) in
                    if let error = error {
                        print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                    }
                }
                isNotificationAvailable = true

            }
        }

        let maxdate = currentDateAndTime.addingTimeInterval(60*60*24*15)

        let fIfteenDaystasks = realm.objects(RLMTask.self).filter("dueDate >= %@ AND dueDate <= %@ AND completed = false AND removed = false",currentDateAndTime,maxdate)

        if isNotificationAvailable == true && fIfteenDaystasks.count > 0 {
            setRandomMonthlyNotification()
        }
    }

    func setRemainingNotifications(notifications : [Any] , notificationcount : Int){
        var arrpriority1 = [Any]()
        var arrpriority2 = [Any]()
        var arrpriority3 = [Any]()
        var arrpriority4 = [Any]()
        var arrpriority5 = [Any]()
        var arrpriority6 = [Any]()
        var arrpriority7 = [Any]()
        var arrpriority8 = [Any]()
        var arrpriority9 = [Any]()
        var arrpriority10 = [Any]()
        var arrpriority11 = [Any]()
        var arrpriority12 = [Any]()
        var arrpriority13 = [Any]()
        var arrpriority14 = [Any]()
        var arrpriority15 = [Any]()
        for object in notifications{
            let priority = (object as! [String : Any])["priority"] as! Int
            if priority == 1 {
                arrpriority1.append(object)
            } else if priority == 2 {
                arrpriority2.append(object)
            } else if priority == 3 {
                arrpriority3.append(object)
            } else if priority == 4 {
                arrpriority4.append(object)
            } else if priority == 5 {
                arrpriority5.append(object)
            } else if priority == 6 {
                arrpriority6.append(object)
            } else if priority == 7 {
                arrpriority7.append(object)
            } else if priority == 8 {
                arrpriority8.append(object)
            } else if priority == 9 {
                arrpriority9.append(object)
            } else if priority == 10 {
                arrpriority10.append(object)
            } else if priority == 11 {
                arrpriority11.append(object)
            } else if priority == 12 {
                arrpriority12.append(object)
            } else if priority == 13 {
                arrpriority13.append(object)
            } else if priority == 14 {
                arrpriority14.append(object)
            } else if priority == 15 {
                arrpriority15.append(object)
            }
        }
        var remainingCount = notificationcount

        if arrpriority1.count > 0 {
            if arrpriority1.count > remainingCount {
                for i in 0..<remainingCount {
//                    let notifObject = (arrpriority1[i] as! [String : Any])["notification"] as! UILocalNotification
//                    UIApplication.shared.scheduleLocalNotification(notifObject)
                    let notifObject = (arrpriority1[i] as! [String : Any])["notification"] as! UNNotificationRequest
                    UNUserNotificationCenter.current().add(notifObject) { (error) in
                        if let error = error {
                            print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                        }
                    }
                    remainingCount = remainingCount - 1
                }
            } else {
                for object in arrpriority1 {
//                    let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                    UIApplication.shared.scheduleLocalNotification(notifObject)
                    let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                    UNUserNotificationCenter.current().add(notifObject) { (error) in
                        if let error = error {
                            print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                        }
                    }
                    remainingCount = remainingCount - 1
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority2.count > 0 {
                if arrpriority2.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority2[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority2[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority2 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority3.count > 0 {
                if arrpriority3.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority3[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority3[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority3 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority4.count > 0 {
                if arrpriority4.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority4[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority4[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority4 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority5.count > 0 {
                if arrpriority5.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority5[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority5[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority5 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority6.count > 0 {
                if arrpriority6.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority6[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority6[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority6 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority7.count > 0 {
                if arrpriority7.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority7[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority7[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority7 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority8.count > 0 {
                if arrpriority8.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority8[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority8[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority8 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority9.count > 0 {
                if arrpriority9.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority9[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority9[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority9 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority10.count > 0 {
                if arrpriority10.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority10[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority10[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority10 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority11.count > 0 {
                if arrpriority11.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority11[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority11[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority11 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority12.count > 0 {
                if arrpriority12.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority12[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority12[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority12 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority13.count > 0 {
                if arrpriority13.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority13[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority13[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority13 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority14.count > 0 {
                if arrpriority14.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority14[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority14[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority14 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }

        if remainingCount > 0 {
            if arrpriority15.count > 0 {
                if arrpriority15.count > remainingCount {
                    for i in 0..<remainingCount {
//                        let notifObject = (arrpriority15[i] as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (arrpriority15[i] as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                } else {
                    for object in arrpriority15 {
//                        let notifObject = (object as! [String : Any])["notification"] as! UILocalNotification
//                        UIApplication.shared.scheduleLocalNotification(notifObject)
                        let notifObject = (object as! [String : Any])["notification"] as! UNNotificationRequest
                        UNUserNotificationCenter.current().add(notifObject) { (error) in
                            if let error = error {
                                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                            }
                        }
                        remainingCount = remainingCount - 1
                    }
                }
            }
        }
    }

    /*func setRemindersNotifications(){

     //setUp Reminers Notifications
     let realm = try! Realm()
     UIApplication.shared.cancelAllLocalNotifications()
     self.deleteAllNotificationsFromDatabase()
     let currentDateAndTime = NSDate()
     let tasks = realm.objects(RLMTask.self).filter("dueDate >= %@ AND repeatingSchedule == null AND completed = false",currentDateAndTime)

     for task in tasks {
     for reminder in task.reminders{
     setReminderForDate(task: task, reminder: reminder)
     }
     }

     //setup schedules
     let repeatingScheduleTasks = realm.objects(RLMTask.self).filter("repeatingSchedule != null AND originalDueDate < %@ AND completed = false",currentDateAndTime)

     for task in repeatingScheduleTasks {

     var strNotificationText = ""
     if task.name == "" {
     strNotificationText = task.type
     } else {
     strNotificationText = task.name
     }

     if (task.repeatingSchedule?.schedule == "Daily") {
     for i in 1..<61 {
     let notification = UILocalNotification()
     notification.fireDate = task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24))) as! Date
     notification.alertBody = strNotificationText
     notification.alertAction = "Reminder!"
     notification.alertTitle = "Reminder!"
     let dictUserInfo = ["id" : task.id]
     notification.userInfo = dictUserInfo
     notification.soundName = UILocalNotificationDefaultSoundName
     if notification.fireDate! > currentDateAndTime as Date {
     UIApplication.shared.scheduleLocalNotification(notification)
     saveReminderNotification(notification: RLMNotification(title: "Reminder", name: strNotificationText, date: notification.fireDate as! NSDate))
     }
     }
     } else
     if (task.repeatingSchedule?.schedule == "Weekly") {
     for i in 1..<8 {
     let notification = UILocalNotification()
     notification.fireDate = task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24*7))) as! Date
     notification.alertBody = strNotificationText
     notification.alertAction = "Reminder!"
     notification.alertTitle = "Reminder!"
     let dictUserInfo = ["id" : task.id]
     notification.userInfo = dictUserInfo
     notification.soundName = UILocalNotificationDefaultSoundName
     if notification.fireDate! > currentDateAndTime as Date {
     UIApplication.shared.scheduleLocalNotification(notification)
     saveReminderNotification(notification: RLMNotification(title: "Reminder", name: strNotificationText, date: notification.fireDate as! NSDate))
     }
     }
     } else
     if (task.repeatingSchedule?.schedule == "Bi-Weekly") {
     for i in 1..<8 {
     let notification = UILocalNotification()
     notification.fireDate = task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24*14))) as! Date
     notification.alertBody = strNotificationText
     notification.alertAction = "Reminder!"
     notification.alertTitle = "Reminder!"
     let dictUserInfo = ["id" : task.id]
     notification.userInfo = dictUserInfo
     notification.soundName = UILocalNotificationDefaultSoundName
     //UIApplication.shared.scheduleLocalNotification(notification)
     if notification.fireDate! > currentDateAndTime as Date {
     UIApplication.shared.scheduleLocalNotification(notification)
     saveReminderNotification(notification: RLMNotification(title: "Reminder", name: strNotificationText, date: notification.fireDate as! NSDate))
     }
     }
     } else
     if (task.repeatingSchedule?.schedule == "Monthly") {
     for i in 1..<6 {
     let notification = UILocalNotification()
     notification.fireDate = task.originalDueDate?.addingTimeInterval(TimeInterval(i*(60*60*24*30))) as! Date
     notification.alertBody = strNotificationText
     notification.alertAction = "Reminder!"
     notification.alertTitle = "Reminder!"
     let dictUserInfo = ["id" : task.id]
     notification.userInfo = dictUserInfo
     notification.soundName = UILocalNotificationDefaultSoundName
     if notification.fireDate! > currentDateAndTime as Date {
     UIApplication.shared.scheduleLocalNotification(notification)
     saveReminderNotification(notification: RLMNotification(title: "Reminder", name: strNotificationText, date: notification.fireDate as! NSDate))
     }
     }
     }
     }

     print(repeatingScheduleTasks)
     print(repeatingScheduleTasks.count)


     }*/

    func setReminderForDate(task : RLMTask, reminder : RLMReminder){
        var components : DateComponents? = nil
        if reminder.reminderDate != nil {
            components = (Calendar.current as NSCalendar).components([.hour, .minute, .second], from: reminder.reminderDate! as Date)
        }

        let dictUserInfo = ["id" : task.id]

        let strNotificationText = self.getNotificationString(task: task, reminder: reminder)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var notificationDate : NSDate? = nil
        if reminder.selectedID == 1 {
            notificationDate = task.dueDate
        } else if reminder.selectedID == 2 {
            notificationDate = task.dueDate?.addingTimeInterval(-60*5)
        } else if reminder.selectedID == 3 {
            notificationDate = task.dueDate?.addingTimeInterval(-60*15)
        } else if reminder.selectedID == 4 {
            notificationDate = task.dueDate?.addingTimeInterval(-60*30)
        } else if reminder.selectedID == 5 {
            notificationDate = task.dueDate?.addingTimeInterval(-60*60)
        } else if reminder.selectedID == 6 {
            notificationDate = task.dueDate?.addingTimeInterval(-60*(60*2))
        } else if reminder.selectedID == 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            notificationDate = task.dueDate?.addingTimeInterval(-60*(60*24))
            notificationDate = calendar.date(bySettingHour: components!.hour!, minute: components!.minute!, second: 0, of: notificationDate! as Date, options: NSCalendar.Options.matchFirst)! as NSDate

        } else if reminder.selectedID == 8 {
            notificationDate = task.dueDate?.addingTimeInterval(-60*(60*24*3))
            notificationDate = calendar.date(bySettingHour: components!.hour!, minute: components!.minute!, second: 0, of: notificationDate! as Date, options: NSCalendar.Options.matchFirst)! as NSDate
        } else if reminder.selectedID == 9 {
            notificationDate = task.dueDate?.addingTimeInterval(-60*(60*24*7))
            notificationDate = calendar.date(bySettingHour: components!.hour!, minute: components!.minute!, second: 0, of: notificationDate! as Date, options: NSCalendar.Options.matchFirst)! as NSDate
        } else if reminder.selectedID == 10 {
            notificationDate = task.dueDate?.addingTimeInterval(-60*(60*24*14))
            notificationDate = calendar.date(bySettingHour: components!.hour!, minute: components!.minute!, second: 0, of: notificationDate! as Date, options: NSCalendar.Options.matchFirst)! as NSDate
        } else if reminder.selectedID == 11 {
            notificationDate = task.dueDate?.addingTimeInterval(-60*(60*24*30))
            notificationDate = calendar.date(bySettingHour: components!.hour!, minute: components!.minute!, second: 0, of: notificationDate! as Date, options: NSCalendar.Options.matchFirst)! as NSDate
        }
        let currentDate = Date()
        print(notificationDate! as Date)
        let notification = UILocalNotification()
        notification.fireDate = (notificationDate! as Date)
        notification.alertBody = strNotificationText
        notification.alertAction = "Reminder!"
        notification.alertTitle = "Reminder!"
        notification.userInfo = dictUserInfo
        notification.soundName = UILocalNotificationDefaultSoundName
        if notification.fireDate! > currentDate {
            UIApplication.shared.scheduleLocalNotification(notification)
            saveReminderNotification(notification: RLMNotification(title: "Reminder", name: strNotificationText, date: notificationDate!))
        }
    }

    func getNotificationString(task: RLMTask, reminder: RLMReminder) -> String {
        var strNotificationText = ""
        if task.name == "" {
            strNotificationText = task.type
        } else {
            strNotificationText = task.name
        }
        if reminder.selectedID == 1 {
            strNotificationText = strNotificationText.appending(" begins now")
        } else if reminder.selectedID == 2 {
            strNotificationText = strNotificationText.appending(" is Due in 5 minutes")
        } else if reminder.selectedID == 3 {
            strNotificationText = strNotificationText.appending(" is Due in 15 minutes")
        } else if reminder.selectedID == 4 {
            strNotificationText = strNotificationText.appending(" is Due in 30 minutes")
        } else if reminder.selectedID == 5 {
            strNotificationText = strNotificationText.appending(" is Due in 1 hour")
        } else if reminder.selectedID == 6 {
            strNotificationText = strNotificationText.appending(" is Due in 2 hours")
        } else if reminder.selectedID == 7 {
            strNotificationText = strNotificationText.appending(" is Due in 1 day")
        } else if reminder.selectedID == 8 {
            strNotificationText = strNotificationText.appending(" is Due in 3 days")
        } else if reminder.selectedID == 9 {
            strNotificationText = strNotificationText.appending(" is Due in 1 week")
        } else if reminder.selectedID == 10 {
            strNotificationText = strNotificationText.appending(" is Due in 2 weeks")
        } else if reminder.selectedID == 11 {
            strNotificationText = strNotificationText.appending(" is Due in 1 month")
        }
        return strNotificationText
    }

    func deleteAllNotificationsFromDatabase() {
        let realm = try! Realm()
        let notifications = realm.objects(RLMNotification.self)
        if notifications.count > 0 {
            realm.beginWrite()
            realm.delete(notifications)
            do {
                try realm.commitWrite()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    func saveReminderNotification(notification : RLMNotification) {
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(notification)
        do {
            try realm.commitWrite()
        } catch let error {
            print(error.localizedDescription)
        }
        print(notification)
    }

    //MARK: -- Dynamic Link --

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL, completion: { (dynamiclink, error) in
                if let dynamiclink = dynamiclink, let _ =  dynamiclink.url {
                    print("***** Link --- \(dynamiclink.url)")
                    // https://www.b4grad.com/?userId=aRyUzsFhcu
                    //                    let strURL = String(describing: dynamiclink.url)
                    //                    let arrStr = strURL.components(separatedBy: "=")
                    //                    if arrStr.count > 2 {
                    //                        let strId = arrStr[1]
                    //                        print("User Id === \(strId)")
                    //                    }
                }
            })
            return linkHandled
        }
        return false
    }

    // MARK: - Facebook SDK

//    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
//
//        // Add any custom logic here.
//
//        return handled
//    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            if let _ =  dynamicLink.url {
                print("***** Open URL -- \(dynamicLink.url)")
                let strURL = "\(dynamicLink.url!)"
                let arrStr = strURL.components(separatedBy: "=")
                if arrStr.count > 1 {
                    let strId = arrStr[1]
                    print("User Id === \(strId)")
                    UserDefaults.standard.set(strId, forKey: "ReferralUserID")
                    UserDefaults.standard.synchronize()
                    NotificationCenter.default.post(name: NSNotification.Name("RefferalIdFound"), object: nil)
                }
            }
            return true
        }
        else {
            let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
            // Add any custom logic here.
            return handled
        }
    }

    func addTaskManager(tableView: UITableView) {
        self.taskManagers.append(tableView)
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
        /*StoreKitManager.shared.verifyReceiptAndCheckExpiry(response: { (isSuccess) in StoreKitManager.shared.fetchUserSubscriptionInfo()}) //This is temporary. Better way is to subscribe to Apple's subscription server. The postback url is already created on the parse-server. The downside of doing this instead of subscribing to Apple's subscription server, is that the receipt stored locally is relied on -> what if the user tries a new device? They need to Restore Purchase first, otherwise they are seen as free user.
        StoreKitManager.shared.fetchUserSubscriptionInfo() //This line should always be here.*/
        
        //ALERT: Local verification (code below) also occurs in processPurchaseCompletionCallbackData(..) & processRestorePurchaseCompetionCallbackData(..) in SubscriptionPlansViewController! So be sure to update those methods as well as this one applicationWillEnterForeground(..) & applicationDidBecomeActive(..).
        
        if (alreadyCheckedDuringCurrentSession == false) {
            let receiptHandler = ReceiptHandler()
            receiptHandler.handleAppReceipt()
        }
        alreadyCheckedDuringCurrentSession = true
        
        /*SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
        switch result {
        case .success(let receiptData):
            //let encryptedReceipt = receiptData.base64EncodedString(options: [])
            //print("Fetch receipt success:\n\(encryptedReceipt)")
            if (receiptData == nil) {
                UserDefaults.standard.set(false, forKey: "isSubscribed")
            } else {
                let receiptString = receiptData.base64EncodedString(options: [])
                let expiresDate: Date?
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                
                if let expiresString = receiptString["expires_date"] as? String {
                    expiresDate = formatter.date(from: expiresString)
                    if (expiresDate != nil && expiresDate! < Date()) { //if expiry has not occurred yet.
                        UserDefaults.standard.set(true, forKey: "isSubscribed")
                    } else {
                        UserDefaults.standard.set(false, forKey: "isSubscribed")
                    }
                }
                
            }
        case .error(let error):
            print("Fetch receipt failed: \(error)")
            let receiptData = SwiftyStoreKit.localReceiptData
            if (receiptData == nil) {
                UserDefaults.standard.set(false, forKey: "isSubscribed")
            } else {
                let receiptString = receiptData!.base64EncodedString(options: [])
                let expiresDate: Date?
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
                
                if let expiresString = receiptString["expires_date"] as? String {
                    expiresDate = formatter.date(from: expiresString)
                    if (expiresDate != nil && expiresDate! < Date()) { //if expiry has not occurred yet.
                        UserDefaults.standard.set(true, forKey: "isSubscribed")
                    } else {
                        UserDefaults.standard.set(false, forKey: "isSubscribed")
                    }
                }
                
            }
        }*/
        
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    var alreadyCheckedDuringCurrentSession = false
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.setPredefinedRemindersForFirstTime()
        /*StoreKitManager.shared.verifyReceiptAndCheckExpiry(response: { (isSuccess) in StoreKitManager.shared.fetchUserSubscriptionInfo()}) //This is temporary. Better way is to subscribe to Apple's subscription server. The postback url is already created on the parse-server. The downside of doing this instead of subscribing to Apple's subscription server, is that the receipt stored locally is relied on -> what if the user tries a new device? They need to Restore Purchase first, otherwise they are seen as free user.
        StoreKitManager.shared.fetchUserSubscriptionInfo() //This line should always be here.
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.*/
        
        /*if (UserDefaults.standard.bool(forKey: "AppLaunchedBefore") == false) {
            let realm = try! Realm()
            let filteredSettings = realm.objects(RLMReminderSetting.self).filter("name = %@ OR name = %@ OR name = %@ OR name = %@","Assignments", "Quizzes", "Midterms", "Finals")
            print(filteredSettings.count)
            for reminderSetting in filteredSettings {
            //let reminderSetting = filteredSettings[0]
            realm.beginWrite()
            reminderSetting.reminders.removeAll()
            let reminder1 = RLMReminder(selectedID: 7, notificationId: "1 Day Before  (4:00 PM)", date: nil)
            let reminder2 = RLMReminder(selectedID: 8, notificationId: "3 Days Before  (4:00 PM)", date: nil)
            reminderSetting.reminders.append(reminder1)
            reminderSetting.reminders.append(reminder2)
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            }
            }
        }*/
        
        //ALERT: Local verification (code below) also occurs in processPurchaseCompletionCallbackData(..) & processRestorePurchaseCompetionCallbackData(..) in SubscriptionPlansViewController! So be sure to update those methods as well as this one applicationWillEnterForeground(..) & applicationDidBecomeActive(..).
        ///let expiryDateOfLastPurchase = UserDefaults.standard.double(forKey: "ExpiryDateOfLastPurchase")
        ///let expiryDate = Date(timeIntervalSinceReferenceDate: expiryDateOfLastPurchase)
//        if (alreadyCheckedDuringCurrentSession == false) {
//            ///if (Date() > expiryDate) {
//                let receiptHandler = ReceiptHandler()
//                receiptHandler.handleAppReceipt()
//            ///}
//        }
//        alreadyCheckedDuringCurrentSession = true
        
        
        //FOR TESTING PREMIUM, SIMPLY UNCOMMENT THE BELOW LINE.
        //BE SURE TO COMMENT IT AGAIN BEFORE PUSHING TO GIT !!!!!
        UserDefaults.standard.set(true, forKey: "isSubscribed")
        
//        if (UserDefaults.standard.bool(forKey: "LifetimePurchaser") == true) { //So receipt verification doesn't matter for lifetime purchasers, it sets this bool to true when they purchase/restore and it stays that way.
//            UserDefaults.standard.set(true, forKey: "isSubscribed")
//        }
    }
    
    func setPredefinedRemindersForFirstTime(){
        let isFirstTime = UserDefaults.standard.bool(forKey: "IsPreReminderSet")
        let isRestore = UserDefaults.standard.bool(forKey: "IsRestoreDefaults")
        if isFirstTime == false || isRestore == true {
            UserDefaults.standard.set(true, forKey: "IsPreReminderSet")
            
            let realm = try! Realm()
            let tasks = realm.objects(RLMTask.self)
            
            realm.beginWrite()
            if tasks.toArray().count == 0 || isRestore == true {
                UserDefaults.standard.set(false, forKey: "IsRestoreDefaults")
                let reminderSettings = realm.objects(RLMReminderSetting.self)
                
                for setting in reminderSettings{
                    setting.reminders.removeAll()
                    //setting.reminders = List<RLMReminder>()
                    let gregorian = Calendar(identifier: .gregorian)
                    let date = Date()
                    var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date as Date)
                    components.hour = 16
                    components.minute = 0
                    components.second = 0
                    let fourpmDate = gregorian.date(from: components)!
                    let reminder1 = RLMReminder(selectedID: 7, notificationId: "1 Day Before  (4:00 PM)", date: fourpmDate as NSDate)
                    let reminder2 = RLMReminder(selectedID: 8, notificationId: "3 Days Before  (4:00 PM)", date: fourpmDate as NSDate)
                    setting.reminders.append(reminder1)
                    setting.reminders.append(reminder2)
                }
            }
            do {
                try realm.commitWrite()
            } catch let error {
                print(error)
                //let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription, preferredStyle: .alert)
                //errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            }
            //updateTasksForRestoreReminders()
        }
    }
    
    func updateTasksForRestoreReminders(){
        let realm = try! Realm()
        let tasks = realm.objects(RLMTask.self)
        realm.beginWrite()
        for taskObject in tasks{
            let settingReminders = getReminderSettingFromtype(name: taskObject.type)
            
            taskObject.reminders.removeAll()
            for reminder in settingReminders {
                taskObject.reminders.append(reminder)
            }
            do {
                try realm.commitWrite()
            } catch let error {
                print(error)
            }
        }
        setRemindersNotifications()
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

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if notification.userInfo == nil {
            return
        }
        let userInfoObject = notification.userInfo! as! [String : String]
        print(userInfoObject)
        //        var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        //        topWindow!.rootViewController = UIViewController()
        //        topWindow!.windowLevel = UIWindowLevelAlert + 1
        if UIApplication.shared.applicationState == UIApplicationState.active {
            let alertVC = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.window?.rootViewController?.present(alertVC, animated: true, completion: nil)
        } else {
            let strid = userInfoObject["id"]
            let realm = try! Realm()
            let tasks = realm.objects(RLMTask.self).filter("id == %@", strid!)
            let task = tasks.first!
            print(task)
            let controller = getVisibleViewController(nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
            let cellEditingVC = storyboard.instantiateViewController(withIdentifier: "CellEditingVC") as! CellEditingTableViewController
            cellEditingVC.helperObject = HomeworkCellEditingHelperObject(cellEditingTVC: cellEditingVC, task: task, taskManagerVC: nil, homeVC: nil)
            cellEditingVC.helperObject.dictionary[0]![0].name = task.name
            cellEditingVC.title = task.name
            cellEditingVC.helperObject.task = task
            cellEditingVC.isfromNotifiction = true
            //cellEditingVC.helperObject.taskManagerVC = controller
            //cellEditingVC.helperObject.taskManagerVC = self
            navigationController.viewControllers = [cellEditingVC]
            navigationController.modalPresentationStyle = .formSheet
            controller!.present(navigationController, animated: true, completion: nil)
        }

    }

    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {

        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }

        if rootVC?.presentedViewController == nil {
            return rootVC
        }

        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }

            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }

            return getVisibleViewController(presented)
        }
        return nil
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //if expiryDate is set && user is not subscribed, cancel all reminders here, so it cannot be abused.
        if ((UserDefaults.standard.double(forKey: "ExpiryDateOfLastPurchase") > 0) && (UserDefaults.standard.bool(forKey: "isSubscribed") == false)) { //7 //free trial over
            UIApplication.shared.cancelAllLocalNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
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

    // MARK: - Firebase Dynamic Links (Referral Point System)

    static func createDynamicLink(completion: @escaping linkHandler) {
        let user = PFUser.current()!
        guard let link = URL(string: "https://www.b4grad.com/?userId=\(user.objectId ?? "1")") else {
            return
        }
        let domainURIPRefix = "https://b4grad.page.link"
        let linkBuilder = DynamicLinkComponents.init(link: link, domainURIPrefix: domainURIPRefix)
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "test.EasyHomework")
        linkBuilder?.iOSParameters?.appStoreID = "1352751059"
        linkBuilder?.iOSParameters?.minimumAppVersion = "1.0.3"
        guard let longDynamicLink = linkBuilder?.url else { return }
        DynamicLinkComponents.shortenURL(longDynamicLink, options: nil) { url, warnings, error in
            if url != nil  {
                completion(url!)
            } else {
                completion(nil)
            }
        }
    }

    static func setDynamicLink(_ link: URL, forUser: PFUser) {
        let follow = PFObject(className: "Referral")
        follow["ReferralPoint"] = 0
        follow["ReferralLink"] = "\(link)"
        follow["Id"] = forUser.objectId ?? "1"
        follow.saveInBackground { (success, error) -> Void in
            if error != nil {
                print(error?.localizedDescription)
            }
        }
    }

    static func getUserFromUuid(completion: @escaping userHandler) {
        // let userQuery: PFQuery = PFQuery(className: "User")
        let userQuery: PFQuery = PFUser.query()!
        //  objectId
        userQuery.whereKey("UniqueID", equalTo: UIDevice.current.identifierForVendor?.uuidString as Any)
        userQuery.findObjectsInBackground(block: {
            (user, error) -> Void in
            if user != nil {
                if (user?.count)! > 0 {
                    let objectN = user![0] as! PFUser
                    let refferId = UserDefaults.standard.value(forKey: "ReferralUserID") as! String
                    if objectN.objectId == refferId {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        })
    }

    static func setValueToKeychain() {
        KeychainService.savePassword(service: service, account: account, data: "AlreadyInstalled")
    }

    static func getValueFromKeychain() -> String {
        if let str = KeychainService.loadPassword(service: service, account: account) {
            return str
        } else {
            return "NotInstalled"
        }
    }

    //Increase User Point .. (Not used anywhere)
    static func incrementUserPoint () {
        let userO = PFUser.current()!
        let userQuery: PFQuery = PFQuery(className: "Referral")
        userQuery.whereKey("Id", equalTo: userO.objectId!)
        userQuery.findObjectsInBackground(block: {
            (user, error) -> Void in
            if user != nil {
                let objectN = user![0]
                if let point = objectN.object(forKey: "ReferralPoint") {
                    objectN["ReferralPoint"] = (point as! Int)+1
                    objectN.saveInBackground { (success, error) -> Void in
                        if error != nil {
                            print(error?.localizedDescription)
                        }
                    }
                }
            }
        })
    }

    private func configureUserNotificationsCenter() {
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self

        // Define Actions
        let actionReadLater = UNNotificationAction(identifier: Notification1.Action.Completed, title: "Mark as Completed", options: [])
        let actionShowDetails = UNNotificationAction(identifier: Notification1.Action.RemindMeHour, title: "Remind me in 1 Hour", options: [])
        let actionUnsubscribe = UNNotificationAction(identifier: Notification1.Action.RemindTomorrow, title: "Remind me Tomorrow", options: [])

        // Define Category
        let tutorialCategory = UNNotificationCategory(identifier: Notification1.Category.tutorial, actions: [actionReadLater, actionShowDetails, actionUnsubscribe], intentIdentifiers: [], options: [])

        // Register Category
        UNUserNotificationCenter.current().setNotificationCategories([tutorialCategory])
    }

    func randomString(length: Int) -> String {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case Notification1.Action.Completed:
            let userInfo = response.notification.request.content.userInfo as? NSDictionary
            let strid = userInfo!["id"] as! String
            let realm = try! Realm()
            let tasks = realm.objects(RLMTask.self).filter("id == %@", strid)
            let task = tasks.first!

            if UIApplication.shared.applicationState == UIApplicationState.active || UIApplication.shared.applicationState == UIApplicationState.background {
                NotificationCenter.default.post(name: Notification.Name("CompletedNotification"), object: nil, userInfo: ["task" : task])
            } else {
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
                    // self.present(errorVC, animated: true, completion: nil)
                    // return
                }
                self.setRemindersNotifications()
            }
           // self.upDateNotifications()
            print("completed")
        case Notification1.Action.RemindMeHour:
            let userInfo = response.notification.request.content.userInfo as? NSDictionary
            let strid = userInfo!["id"] as! String
            let priority = userInfo!["priority"] as! String
            let realm = try! Realm()
            let tasks = realm.objects(RLMTask.self).filter("id == %@", strid)
            let task = tasks.first!
            let userDefaults = UserDefaults.standard
            //let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: task)
            let notifDate = Date().addingTimeInterval(3600)
            let notificationId = response.notification.request.identifier

            if (userDefaults.value(forKey: "notifications") != nil) {
                let arrayNotications = (userDefaults.value(forKey: "notifications") as! NSArray).mutableCopy() as! NSMutableArray
                arrayNotications.add(["task" : task.id, "notificationdate" : notifDate, "id" : notificationId, "priority" : priority])
                userDefaults.set(arrayNotications, forKey: "notifications")
            } else {
                let arrayNotications = NSMutableArray()
                arrayNotications.add(["task" : task.id, "notificationdate" : notifDate, "id" : notificationId, "priority" : priority])
                userDefaults.set(arrayNotications, forKey: "notifications")

            }
            self.setRemindersNotifications()
            print("remind me one Hour")
        case Notification1.Action.RemindTomorrow:
            let userInfo = response.notification.request.content.userInfo as? NSDictionary
            let strid = userInfo!["id"] as! String
            let priority = userInfo!["priority"] as! String
            let realm = try! Realm()
            let tasks = realm.objects(RLMTask.self).filter("id == %@", strid)
            let task = tasks.first!
            let userDefaults = UserDefaults.standard
            //let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: task)
            let notifDate = Date().addingTimeInterval(86400)
            let notificationId = response.notification.request.identifier

            if (userDefaults.value(forKey: "notifications") != nil) {
                let arrayNotications = (userDefaults.value(forKey: "notifications") as! NSArray).mutableCopy() as! NSMutableArray
                arrayNotications.add(["task" : task.id, "notificationdate" : notifDate, "id" : notificationId, "priority" : priority])
                userDefaults.set(arrayNotications, forKey: "notifications")
            } else {
                let arrayNotications = NSMutableArray()
                arrayNotications.add(["task" : task.id, "notificationdate" : notifDate, "id" : notificationId, "priority" : priority])
                userDefaults.set(arrayNotications, forKey: "notifications")

            }
            self.setRemindersNotifications()
            print("Remind me tomorrow")
        default:
            if UIApplication.shared.applicationState == UIApplicationState.active {
                let alertVC = UIAlertController(title: response.notification.request.content.title, message: response.notification.request.content.body, preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.window?.rootViewController?.present(alertVC, animated: true, completion: nil)
            } else {
                if UIApplication.shared.applicationState == UIApplicationState.inactive {
                    let userInfo = response.notification.request.content.userInfo as? NSDictionary
                    let strid = userInfo!["id"] as! String
                    let realm = try! Realm()
                    let tasks = realm.objects(RLMTask.self).filter("id == %@", strid)
                    let task = tasks.first!
                    print(task)
                    let controller = getVisibleViewController(nil)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let navigationController = storyboard.instantiateViewController(withIdentifier: "BlankNavigationController") as! UINavigationController
                    let cellEditingVC = storyboard.instantiateViewController(withIdentifier: "CellEditingVC") as! CellEditingTableViewController
                    cellEditingVC.helperObject = HomeworkCellEditingHelperObject(cellEditingTVC: cellEditingVC, task: task, taskManagerVC: nil, homeVC: nil)
                    cellEditingVC.helperObject.dictionary[0]![0].name = task.name
                    cellEditingVC.title = task.name
                    cellEditingVC.helperObject.task = task
                    cellEditingVC.isfromNotifiction = true
                    //cellEditingVC.helperObject.taskManagerVC = controller
                    //cellEditingVC.helperObject.taskManagerVC = self
                    navigationController.viewControllers = [cellEditingVC]
                    navigationController.modalPresentationStyle = .formSheet
                    controller!.present(navigationController, animated: true, completion: nil)
                }
            }
            print("Other Action")
        }

        completionHandler()
    }
}


extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }

        return array
    }
}
