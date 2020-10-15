//
//  RLMNote.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-04-29.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import RealmSwift

class RLMNote: Object {
    
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var title: String?
    @objc dynamic var contentSet: String?
    
    @objc dynamic var color: RLMColor? //RLMColor object containing RGB values as doubles.
    @objc dynamic var colorStaticValue = 0 //For associated images with predefined colors.
    
    convenience init(name: String,id: String,contentSet:String) {
        self.init()
        self.title = name
        self.id    = id
        self.contentSet = contentSet
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }

}
