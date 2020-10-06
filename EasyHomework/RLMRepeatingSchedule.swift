//
//  RLMRepeatingSchedule.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-11-25.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import RealmSwift

class RLMRepeatingSchedule: Object {

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var createdDate = NSDate()
    @objc dynamic var builtIn = false
    
    @objc dynamic var schedule = "" //i.e.) "Weekly", "Monthly", "Custom", etc.
    var tokens = List<RLMDateToken>() //if the list is empty, do nothing.
    
    @objc dynamic var type = "" //i.e. Lecture, Lab, Tutorial, etc.
    @objc dynamic var course: RLMCourse?
    @objc dynamic var location: String? //i.e.) NS-7
    
    @objc dynamic var masterTask: RLMTask?
    
    convenience init(schedule: String, type: String, course: RLMCourse?, location: String?) {
        self.init()
        self.schedule = schedule
        self.type = type
        self.course = course
        self.location = location
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
