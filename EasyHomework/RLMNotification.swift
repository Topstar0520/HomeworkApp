//
//  RLMNotification.swift
//  B4Grad
//
//  Created by Chintan Patel on 25/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import Foundation
import RealmSwift

class RLMNotification: Object {
    @objc dynamic var title = ""
    @objc dynamic var name = ""
    @objc dynamic var date: NSDate!
    
    convenience init(title: String, name: String, date: NSDate) {
        self.init()
        self.title = title
        self.name = name
        self.date = date
    }
}
