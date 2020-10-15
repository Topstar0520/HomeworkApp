//
//  DateToken.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-11-25.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import RealmSwift

class RLMDateToken: Object {

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var createdDate = NSDate()
    
    @objc dynamic var startTime: NSDate! //store the time of day here, i.e.) 12:45 PM
    @objc dynamic var startDayOfWeek = "" //day of week during startTime. Formatted as seen in the DayOfWeek enum. i.e.) "Monday"
    @objc dynamic var endTime: NSDate! // Possible that no endTime is provided, i.e.) 1:45 PM. NOTE: If endTime < startTime, assume the RLMRecurringSchoolEvent ends on the following day.
    
    @objc dynamic var lastTaskCreatedDueDate: NSDate? //nil if there have been no tasks created for this RLMRecurringSchoolEvent yet.
    
    //@objc dynamic var masterTask: RLMTask?
    
    convenience init(startTime: NSDate, startDayOfWeek: String, endTime: NSDate?) {
        self.init()
        self.startTime = startTime
        self.startDayOfWeek = startDayOfWeek
        self.endTime = endTime
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
