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
}

var BackgroundList = ["DefaultBackground","Desert", "Earth", "Foliage", "Mountain", "Shore", "Sunflower", "Tiger"]
