//
//  MoveCursorUpAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class MoveCursorUpAction: NSObject, EditAction {
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "movecursorup-icon") 
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "movecursorup-selected-icon")
    }
    
    var editor: NoteEditor!
    static var prevOffset = Int(0)
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        let lm = editor.textView.layoutManager
        let index = lm.glyphIndexForCharacter(at: range.location)
        var curLineRange = NSMakeRange(0, 0)
        lm.lineFragmentRect(forGlyphAt: index, effectiveRange: &curLineRange)
        if curLineRange.location > 3 {
            let prevLineIndex = curLineRange.location - 3
            var prevLineRange = NSMakeRange(0, 0)
            lm.lineFragmentRect(forGlyphAt: prevLineIndex, effectiveRange: &prevLineRange)
            let curCharLineRange = lm.characterRange(forGlyphRange: curLineRange, actualGlyphRange: nil)
            let prevCharLineRange = lm.characterRange(forGlyphRange: prevLineRange, actualGlyphRange: nil)
            if range.location > curCharLineRange.location { MoveCursorUpAction.prevOffset = range.location - curCharLineRange.location }
            let offset = min(prevCharLineRange.length - 1, MoveCursorUpAction.prevOffset)
            editor.setSelectedRange(NSMakeRange(prevCharLineRange.location + offset, 0))
        }
    }
}
