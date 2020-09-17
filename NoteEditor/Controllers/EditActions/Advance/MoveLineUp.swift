//
//  MoveLineUp.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class MoveLineUp: NSObject, EditAction {
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "movelineup-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "movelineup-selected-icon")
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        let lineRange = (attrs.string as NSString).lineRange(for: range)
        if lineRange.location > 1 {
            let prevLineRange = (attrs.string as NSString).lineRange(for: NSMakeRange(lineRange.location - 1, 0))
            let replacingRange = NSMakeRange(prevLineRange.location, prevLineRange.length + lineRange.length)
            let replacingString = NSMutableAttributedString()
            replacingString.append(attrs.attributedSubstring(from: lineRange))
            replacingString.append(attrs.attributedSubstring(from: prevLineRange))
            editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(range.location - prevLineRange.length, range.length))
        }
    }
}
