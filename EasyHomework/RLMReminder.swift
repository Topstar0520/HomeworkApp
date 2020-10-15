//
//  RLMReminder.swift
//  B4Grad
//
//  Created by Pratik Patel on 12/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class RLMReminder: Object {
    
    @objc dynamic var selectedID = 0
    @objc dynamic var notificationId = ""
    @objc dynamic var reminderDate: NSDate?
    
    
    convenience init(selectedID: Int, notificationId: String, date: NSDate?) {
        self.init()
        self.selectedID = selectedID
        self.notificationId = notificationId
        self.reminderDate = date
    }
    
}
