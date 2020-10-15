//
//  HWItem.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-15.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class HWItem: NSObject {
    
    // A text description of this item.
    var text: String
    
    // A Boolean value that determines the completed state of this item.
    var completed: Bool
    
    // Returns a ToDoItem initialized with the given text and default completed value.
    init(text: String) {
        self.text = text
        self.completed = false
    }

}
