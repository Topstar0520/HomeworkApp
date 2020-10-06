//
//  ScheduleRowContent.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-26.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class ScheduleRowContent: NSObject { //Represents a cell.

    var identifier : String!
    var name : String? //for the UITextField inside the cell.
    var date : Date? //incase the cell needs to have an associated NSDate object.
    var pickerTitleForRow : String? //when a picker selects a row, store that row's information here.
    var toggle : Bool? //for cells containing checkmarks or switches.
    var task: RLMTask? //an associated task, for cells that represent assignments, quizzes, etc.
    
    var optionString1: String?
    var optionString2: String?
    var optionBool1 = false
    
    var color: UIColor? = ColorDataModel.defaultColorModel().color
    var colorStaticValue: Int = ColorDataModel.defaultColorModel().colorStaticValue
    
    //For PickerCells.
    var pickerDataSource : PickerDataSource?
    
    //For Weekly Schedules.
    var toggleArray : [Bool]? //for cells that contain a series of Boolean values.
    var timeArray : [Date]? //for cells that contain a series of NSDate values.
    
    //For instructor data.
    var instructor: RLMInstructor?
    
    init(identifier : String) {
        self.identifier = identifier
    }
    
    init(identifier : String, task: RLMTask) {
        self.identifier = identifier
        self.task = task
    }
    
    init(identifier: String, defaultPickerTitleForRow: String) {
        self.identifier = identifier
        self.pickerTitleForRow = defaultPickerTitleForRow
    }
    
    init(identifier: String, defaultToggle: Bool) {
        self.identifier = identifier
        self.toggle = defaultToggle
    }
    
    init(identifier: String, defaultToggleArray: [Bool]) {
        self.identifier = identifier
        self.toggleArray = defaultToggleArray
    }
    
    init(identifier: String, defaultToggleArray: [Bool], usesTimeArray: Bool) {
        self.identifier = identifier
        self.toggleArray = defaultToggleArray
        if (usesTimeArray == true) {
            self.timeArray = [Date(timeIntervalSince1970: 0), Date(timeIntervalSince1970: 0), Date(timeIntervalSince1970: 0), Date(timeIntervalSince1970: 0), Date(timeIntervalSince1970: 0)]
        }
    }
    
    init(identifier: String, defaultTimeArray: [Date]) {
        self.identifier = identifier
        self.timeArray = defaultTimeArray
    }
}
