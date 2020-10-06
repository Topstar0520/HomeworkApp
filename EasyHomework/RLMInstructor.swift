//
//  RLMInstructor.swift
//  B4Grad
//
//  Created by ScaRiLiX on 10/13/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import RealmSwift
import Foundation

class RLMInstructor: Object
{
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var createdDate = Date()
    @objc dynamic var name = ""
    @objc dynamic var role = ""
    @objc dynamic var location = ""
    @objc dynamic var hours = "" //
    //@objc dynamic var fromHours: Date?
    //@objc dynamic var toHours: Date?
    @objc dynamic var notes = ""
    
    var emails = List<String>()
    var phonenumbers = List<String>()
    var websites = List<String>()
    
    @objc dynamic var course: RLMCourse!
    @objc dynamic var type: String! //Can be "Lecture", "Lab", or "Tutorial".

    @objc dynamic var image: Data?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(name: String, course: RLMCourse, type: String)
    {
        self.init()
        self.name = name
        self.course = course
        self.type = type
    }
}

extension RLMInstructor
{
    func edit(with editedInstructor: RLMInstructor, completion: @escaping (RLMInstructor) -> Void)
    {
        try! realm?.write {
            name = editedInstructor.name
            role = editedInstructor.role
            location = editedInstructor.location
            hours = editedInstructor.hours
            //fromHours = editedInstructor.fromHours
            //toHours = editedInstructor.toHours
            notes = editedInstructor.notes
            emails.removeAll()
            emails.append(objectsIn: editedInstructor.emails)
            phonenumbers = editedInstructor.phonenumbers
            image = editedInstructor.image
            websites = editedInstructor.websites
            type = editedInstructor.type
            completion(editedInstructor)
        }
    }
    
    func delete()
    {
        try! realm?.write {
            realm?.delete(self)
        }
    }
    
    func add(notes: String)
    {
        try! realm?.write {
            self.notes = notes
        }
    }
}
