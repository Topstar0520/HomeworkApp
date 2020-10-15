//
//  EmojiDataModel.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2016-07-08.
//  Copyright © 2016 Anthony Giugno. All rights reserved.
//

import UIKit

class EmojiDataModel: NSObject {
    
    class func emojiForRating(_ rating: Int?, selectedEmojiNumber: Int?) -> String {
        if (selectedEmojiNumber == nil) {
            return ""
        }
        if (rating == nil || rating == 0) {
            return ""
        }
        var emojiDictionary: [Int:Array<String>] = [1 : ["💩", "😡", "👻", "🤖"], 2: ["😕", "😠", "😒", "😴"], 3: ["😐", "🤔", "😯", "😑"], 4: ["🙂", "😝", "😊", "😎"], 5: ["😀", "😄", "😇", "😍"] ]
        //if (emojiDictionary[rating!]![selectedEmojiNumber! - 1].containsEmoji == false) {
        //    return "❓"
        //}
        return emojiDictionary[rating!]![selectedEmojiNumber! - 1]
    }
}
