//
//  Notification.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-06-10.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class B4GradNotification: NSObject {
    var type: String!
    var task: RLMTask!
    var title: String!
    
    init(type: String, task: RLMTask) {
        super.init()
        self.type = type
        self.task = task
        if (self.type == "DueDateFarAway") {
            var taskName = self.task.name
            if (taskName.characters.count > 12) {
                let index = taskName.index(taskName.startIndex, offsetBy: 12)
                taskName = self.task.name.substring(to: index) + "..." //shorten task name if needed
            }
            if (self.task.type == "Midterm" || self.task.type == "Exam" || self.task.type == "Quiz") {
                self.title = "\"" + taskName + "\" is over two weeks away so it won't appear in your Agenda yet."
            }
            if (self.task.type == "Assignment") {
                self.title = "\"" + taskName + "\" is due in over two weeks so it won't appear in your Agenda yet."
            }
            if (self.task.type == "Lecture" || self.task.type == "Lab" || self.task.type == "Tutorial") {
                if ((self.task.dueDate! as Date).isPast()) {
                    self.title = "\"" + taskName + "\" is a class that already happened so it won't appear in your Agenda."
                } else {
                    self.title = "\"" + taskName + "\" is a class not happening today so it won't appear in your Agenda yet."
                }
            }
        }
    }
}
