//
//  DatesData.swift
//  CalendarLatestApp
//
//  Created by Amritpal Singh on 8/11/17.
//  Copyright © 2017 Vikrant Tanwar. All rights reserved.
//

import UIKit
import RealmSwift

class DatesData: Object {

    var date: Int?
    var cellType: Int?
    var colors: [ColorObject]?
}

class ColorObject {
    
    var color = UIColor()
    var order = 0
    
    init(color: UIColor, order: Int) {
        self.color = color
        self.order = order
    }
}
