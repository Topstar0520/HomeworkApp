//
//  WriteReviewRowContent.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-06-27.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class WriteReviewRowContent: NSObject {
    
    var identifier: String!
    var rating = 0
    var selectedEmoji: Int? //nil is none, a number from 1-4 is a selected Emoji.
    var contentString: String!
    
    init(identifier : String) {
        self.identifier = identifier
    }

}
