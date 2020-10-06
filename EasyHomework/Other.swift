//
//  Other.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-07-13.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

enum loadProgress: String {
    case loading = "loading"
    case successful = "successful"
    case error = "error"
    
    init?(id : Int) {
        switch id {
        case 1:
            self = .loading
        case 2:
            self = .successful
        case 3:
            self = .error
        default:
            return nil
        }
    }
    
}

enum DayOfWeek: String {
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    
    init?(id : Int) {
        switch id {
        case 1:
            self = .sunday
        case 2:
            self = .monday
        case 3:
            self = .tuesday
        case 4:
            self = .wednesday
        case 5:
            self = .thursday
        case 6:
            self = .friday
        case 7:
            self = .saturday
        case 8: //for algorithms that rely on using +1 the original id.
            self = .sunday
        default:
            return nil
        }
    }
    
    init?(day : String) {
        if day.caseInsensitiveCompare("sunday") == ComparisonResult.orderedSame{
            self.init(id: 1)
        }else if day.caseInsensitiveCompare("monday") == ComparisonResult.orderedSame{
            self.init(id: 2)
        }else if day.caseInsensitiveCompare("tuesday") == ComparisonResult.orderedSame{
            self.init(id: 3)
        }else if day.caseInsensitiveCompare("wednesday") == ComparisonResult.orderedSame{
            self.init(id: 4)
        }else if day.caseInsensitiveCompare("thursday") == ComparisonResult.orderedSame{
            self.init(id: 5)
        }else if day.caseInsensitiveCompare("friday") == ComparisonResult.orderedSame{
            self.init(id: 6)
        }else if day.caseInsensitiveCompare("saturday") == ComparisonResult.orderedSame{
            self.init(id: 7)
        }else{
            return nil
        }
    }
    
    func stringValue() -> String {
        switch self {
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        case .sunday:
            return "Sunday"
        default:
            return ""
        }
    }
    
    func weekNumber() -> Int {
        switch self {
        case .monday:
            return 2
        case .tuesday:
            return 3
        case .wednesday:
            return 4
        case .thursday:
            return 5
        case .friday:
            return 6
        case .saturday:
            return 7
        case .sunday:
            return 1
        default:
            return 0
        }
    }
}

var BackgroundList = ["Desert", "Earth", "Foliage", "Mountain", "Shore", "Sunflower", "Tiger"]
