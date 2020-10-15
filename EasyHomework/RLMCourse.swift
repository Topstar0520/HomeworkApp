//
//  RLMCourse.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-04-29.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import RealmSwift

class RLMCourse: Object {
    
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var createdDate = NSDate()
    @objc dynamic var courseCode: String? //If courseCode is nil..
    @objc dynamic var courseName = "" //..then display the courseName instead.
    @objc dynamic var facultyName: String?
    @objc dynamic var universityName: String?
    
    @objc dynamic var color: RLMColor? //RLMColor object containing RGB values as doubles.
    @objc dynamic var colorStaticValue = 0 //For associated images with predefined colors.
    
    convenience init(courseCode : String?, courseName : String, facultyName : String?, universityName : String?) {
        self.init()
        self.courseCode = courseCode
        self.courseName = courseName
        self.facultyName = facultyName
        self.universityName = universityName
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    //Returns the preferred course title.
    func courseTitle() -> String {
        if (self.courseCode != nil) {
            return self.courseCode! + " - " + self.courseName
        } else {
            return self.courseName
        }
    }
    
}
