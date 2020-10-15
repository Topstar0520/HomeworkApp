//
//  B4GradTextField.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-05-25.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class B4GradTextField: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [ NSAttributedStringKey.foregroundColor : UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.2) ])
        self.textColor = UIColor.white
        self.tintColor = rgbaToUIColor(red: 122/255, green: 122/255, blue: 122/255, alpha: 1.0)
        let clearButton = self.value(forKey: "clearButton") as? UIButton
        clearButton?.setImage(#imageLiteral(resourceName: "Clear Icon Grey"), for: UIControlState.normal)
    }

}
