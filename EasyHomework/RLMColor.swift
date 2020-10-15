//
//  Color.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-04-16.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import RealmSwift

class RLMColor: Object {

    //convert these values to CGFloat when initiating UIColor object.
    @objc dynamic var red = Double()
    @objc dynamic var green = Double()
    @objc dynamic var blue = Double()
    @objc dynamic var alpha = Double()

    convenience init(color: UIColor) {
        self.init()
        //Set some default values incase the wrapping of the color's components fail.
        self.red = 0
        self.green = 0
        self.blue = 0
        self.alpha = 1
        //Now we try to set the values.
        if (color.components != nil) {
            self.red = Double(color.components.red)
            self.green = Double(color.components.green)
            self.blue = Double(color.components.blue)
            self.alpha = Double(color.components.alpha)
        }
    }

    func getUIColorObject() -> UIColor {
        return UIColor(red: CGFloat(self.red), green: CGFloat(self.green), blue: CGFloat(self.blue), alpha: CGFloat(self.alpha))
    }

    func getUIColorObjectWith(alpha:CGFloat) -> UIColor {
        return UIColor(red: CGFloat(self.red), green: CGFloat(self.green), blue: CGFloat(self.blue), alpha: CGFloat(alpha))
    }

    func setColor(color: UIColor) {
        if (color.components != nil) {
            self.red = Double(color.components.red)
            self.green = Double(color.components.green)
            self.blue = Double(color.components.blue)
            self.alpha = Double(color.components.alpha)
        }
    }
}
