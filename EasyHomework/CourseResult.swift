//
//  CourseResult.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-07-07.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit
import Parse

class CourseResult: NSObject {
    
    var coursePFObject: PFObject!
    var courseCode: String!
    var courseName: String!
    var university: String!
    var faculty: String!
    var tags = [String]()
    
    init(coursePFObject: PFObject, courseCode: String, courseName: String, university: String, faculty: String) {
        self.coursePFObject = coursePFObject
        self.courseCode = courseCode
        self.courseName = courseName
        self.faculty = faculty
        self.university = university
    }


}
