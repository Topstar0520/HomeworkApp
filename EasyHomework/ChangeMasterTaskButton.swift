//
//  ChangeMasterTaskButton.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2018-09-05.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class ChangeMasterTaskButton: UIButton {

    class func construct(_ owner : AnyObject) -> ChangeMasterTaskButton {
        var nibViews = Bundle.main.loadNibNamed("ChangeMasterTaskButton", owner: owner, options: nil)
        let changeMasterTaskButton = nibViews?[0] as! ChangeMasterTaskButton
        changeMasterTaskButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .selected)
        changeMasterTaskButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .highlighted)
        return changeMasterTaskButton
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
