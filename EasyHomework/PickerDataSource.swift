//
//  PickerDataSource.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-27.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class PickerDataSource: NSObject, UIPickerViewDataSource {
    
    var dataArray = [String]()

    override init() {
        
    }
    
    init(source : PremadePickerSource) {
        if (source == .standardSemester) {
            self.dataArray = ["Fall", "Spring", "Summer"]
        }
        
        if (source == .upTo20Sections) {
            var integer = 1
            while (integer < 21) {
                self.dataArray.append(String(integer))
                integer += 1
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
}

enum PremadePickerSource: String {
    //Semester Types
    case standardSemester = "standardSemester"
    //Section
    case upTo20Sections = "upTo20Sections"
    
    init?(id : Int) {
        switch id {
        case 1:
            self = .standardSemester
        case 2:
            self = .upTo20Sections
        default:
            return nil
        }
    }
    
}

