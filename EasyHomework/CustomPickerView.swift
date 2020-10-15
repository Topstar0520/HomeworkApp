//
//  CustomPickerView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-27.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class CustomPickerView: UIPickerView {

    var indexPath : IndexPath!
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if (subview.bounds.size.height <= 1.0) {
            subview.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 0.45)
        }
    }

}
