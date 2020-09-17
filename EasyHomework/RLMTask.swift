//
//  RLMTask.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-12-19.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import RealmSwift

class RLMTask: Object {

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var createdDate = NSDate()
    @objc dynamic var name = ""
    @objc dynamic var type = "" //Can be: Assignment, Quiz, Midterm, Final, Lecture, Lab, or Tutorial.
    @objc dynamic var scope = "" //Can be: Regular, Event (short-term), or Project (long-term). Scope defines when/how it should be shown in agenda.
    @objc dynamic var dueDate: NSDate?
    @objc dynamic var course: RLMCourse?
    @objc dynamic var note: RLMNote?
    @objc dynamic var completed = false
    @objc dynamic var completionDate: NSDate? //Do not set unless the task is completed from the HomeworkVC.
    //dynamic var hiddenFromAgendaWhenCompleted = false //Tasks that are completed from a view separate from the Agenda should = true.
    @objc dynamic var removed = false //Tasks are 'removed' instead of deleted, until the associated course is deleted.
    @objc dynamic var dateOfExtension: NSDate? //Tasks that WERE due within 2 weeks, but now modified to be due in over 2 weeks, from the Agenda (HomeworkVC), and that change occurred TODAY, while cellEditing was in .Edit mode have this property != nil. Logic in AppDelegate ensures that extended tasks are marked to false the following day on app launch. Note: This is not the new due date, this is simply the date that the user extended the task on.
    
    //For Tasks that are events of some kind, these properties are particularly relevent.
    @objc dynamic var timeSet = false //If there is a specific time set for the task, set this property to true and use dueDate to access the specific time.
    @objc dynamic var endDateAndTime: NSDate? // It is possible that no endDateAndTime is provided, while a startDateAndTime is. i.e.) September 13, 2017 at 9:30 PM. If only a date is provided, set dueDate instead.
    
    @objc dynamic var originalDueDate: NSDate? //For the purpose of the algorithm in AppDelegate. Use it when dueDate == nil for the purpose of the algorithm. This means there should always be atleast one of the following two tasks != nil when associated with a task, dueDate or originalDueDate. Note: ALL tasks associated with an RLMRecurringSchoolEvent should have an originalDueDate != nil, and that originalDueDate should be never be modified after the task is created.
    @objc dynamic var repeatingSchedule: RLMRepeatingSchedule? //nil when there is no repeating schedule. (always DELETE RLMRepeatingSchedule objects when they are cancelled for a particular task by the user, don't ever set this property manually to nil.)
    
    @objc dynamic var tempVisible = false //For Events that have their date set to sometime in the past from the Agenda.
    @objc dynamic var tempDueDate: NSDate? //When tempVisible = true, this property represents the original date that the Event had (to make it appear via the Agenda in the first place).
    //dynamic var tempEndDateAndTime: NSDate? ///When tempVisible = true, this property represents the original endDateAndTime (if it had one) that the Event had (to make it appear via the Agenda in the first place).
    
    let subTasks = List<RLMSubTask>()
    let note2    = List<RLMNote>()
    
    
    @objc dynamic var repeatingTaskWasUncompleted = false //Indicates whether a repeated task was manually uncompleted by the user. This is to detect the following case: A repeated task was marked completed by appDelegate since its dueDate passed but if the user manually uncompleted it, they likely don't want the algorithm to mark is completed again the following day.

    static func deleteSubTask(in realm: Realm = try! Realm(), task: RLMTask, subTask: RLMSubTask, completion: @escaping(_ success: Bool) -> Void) {
        try! realm.write {

            if let index = task.subTasks.index(of: subTask) {
                task.subTasks.remove(at: index)
                let object = realm.object(ofType: RLMSubTask.self, forPrimaryKey: subTask.id)

                if object != nil {
                    realm.delete(subTask)
                }

                completion(true)
            }
        }
    }
    
    
    static func deleteNote(in realm: Realm = try! Realm(), task: RLMTask, note: RLMNote, completion: @escaping(_ success: Bool) -> Void) {
        try! realm.write {
            
            if let index = task.note2.index(of: note) {
                task.note2.remove(at: index)
                let object = realm.object(ofType: RLMNote.self, forPrimaryKey: note.id)
                
                if object != nil {
                    realm.delete(note)
                }
                
                completion(true)
            }
        }
    }

    convenience init(name: String, type: String, dueDate: NSDate?, course: RLMCourse?) {
        self.init()
        self.name = name
        self.type = type
        self.dueDate = dueDate
        self.course = course
        self.scope = "Regular"
        if (self.type == "Lecture" || self.type == "Lab" || self.type == "Tutorial") {
            self.scope = "Event"
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return []
    }
    
    override static func indexedProperties() -> [String] {
        return ["completionDate", "completed", "removed", "dueDate"]
    }
    
    func updateScope() {
        if (self.type == "Lecture" || self.type == "Lab" || self.type == "Tutorial") {
            self.scope = "Event"
        } else {
            self.scope = "Regular"
        }
    }
    
    func hasPlaceholderName() -> Bool {
        let regexPattern = "((Assignment)|(Quiz)|(Midterm)|(Final)|(Lecture)|(Lab)|(Tutorial))"
        let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
        let matches = regex.matches(in: self.name, options: [], range: NSRange(location: 0, length: self.name.characters.count))
        if (matches.count == 1) {
            return true
        }
        return false
    }
}
