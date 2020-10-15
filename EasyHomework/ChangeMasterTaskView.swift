//
//  ChangeMasterTaskView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2018-09-12.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit

class ChangeMasterTaskView: UIView {

    @IBOutlet weak var changeMasterTaskButton: ChangeMasterTaskButton!
    @IBOutlet weak var closeButton: UIButton!
    
    class func construct(_ owner : AnyObject) -> ChangeMasterTaskView {
        var nibViews = Bundle.main.loadNibNamed("ChangeMasterTaskView", owner: owner, options: nil)
        let changeMasterTaskView = nibViews?[0] as! ChangeMasterTaskView //as! ChangeMasterTaskButton
        
        changeMasterTaskView.changeMasterTaskButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .selected)
        changeMasterTaskView.changeMasterTaskButton.setBackgroundColor(color: UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0), forState: .highlighted)
        
        return changeMasterTaskView
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
