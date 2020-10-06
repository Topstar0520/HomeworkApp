//
//  Taptic.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2019-07-15.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

//Wrapper class for handling the taptic engine.
class Taptic: NSObject {
    
    var impactFeedbackgenerator: NSObject?
    
    func prepare() {
        if #available(iOS 10.0, *) {
            self.impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
            (self.impactFeedbackgenerator as? UIImpactFeedbackGenerator)?.prepare()
        }
    }
    
    func feedback() {
        if #available(iOS 10.0, *) {
            (self.impactFeedbackgenerator as? UIImpactFeedbackGenerator)?.impactOccurred()
            (self.impactFeedbackgenerator as? UIImpactFeedbackGenerator)?.prepare()
        }
    }

}
