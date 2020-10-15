//
//  RLMReminderSetting.swift
//  B4Grad
//
//  Created by Pratik Patel on 15/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import Foundation
import RealmSwift

class RLMReminderSetting: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    var reminders = List<RLMReminder>()
    
    convenience init(id: Int, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
}




