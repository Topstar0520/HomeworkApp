//
//  Date+Extensions.swift
//  Note Editor
//
//  Created by Thang Pham on 9/8/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

extension Date {
    
    func string() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self)
    }
}
