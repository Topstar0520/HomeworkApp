//
//  CellDataObject.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-07-13.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class CellDataObject: NSObject {
    var identifier: String!
    var dictionary = [String: AnyObject]()
    
    required init(identifier: String) {
        self.identifier = identifier
    }

}
