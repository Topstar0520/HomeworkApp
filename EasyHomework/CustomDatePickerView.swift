//
//  CustomDatePickerView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-31.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class CustomDatePickerView: UIDatePicker {

    var indexPath : IndexPath!
    let upperSelectorView = UIView()
    let lowerSelectorView = UIView()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        upperSelectorView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 0.45)
        self.addSubview(upperSelectorView)
        
        lowerSelectorView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 0.45)
        self.addSubview(lowerSelectorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.frame.size.height == 216) {
            upperSelectorView.frame = CGRect(x: 0, y: 91, width: self.frame.size.width, height: 0.5)
            lowerSelectorView.frame = CGRect(x: 0, y: 125, width: self.frame.size.width, height: 0.5)
        }
        
        if (self.frame.size.height == 162) {
            upperSelectorView.frame = CGRect(x: 0, y: 63, width: self.frame.size.width, height: 0.5)
            lowerSelectorView.frame = CGRect(x: 0, y: 98, width: self.frame.size.width, height: 0.5)
        }
        
        self.setValue(UIColor.white, forKey: "textColor")
        self.sendAction(Selector("setHighlightsToday:"), to: nil, for: nil) //suppress this warning
    }
    
}
