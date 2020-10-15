//
//  MoveLineDown.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class MoveLineDown: NSObject, EditAction {
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "movelinedown-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "movelinedown-selected-icon")
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        let lineRange = (attrs.string as NSString).lineRange(for: range)
        if lineRange.location + lineRange.length + 1 < attrs.length {
            let nextLineRange = (attrs.string as NSString).lineRange(for: NSMakeRange(lineRange.location + lineRange.length + 1, 0))
            let replacingRange = NSMakeRange(lineRange.location, lineRange.length + nextLineRange.length)
            let replacingString = NSMutableAttributedString()
            replacingString.append(attrs.attributedSubstring(from: nextLineRange))
            replacingString.append(attrs.attributedSubstring(from: lineRange))
            editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(range.location + nextLineRange.length, range.length))
        }
    }
}
