//
//  MoveCursorDownAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class MoveCursorDownAction: NSObject, EditAction {
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "movecursordown-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "movecursordown-selected-icon")
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
        if curLineRange.location + curLineRange.length < lm.numberOfGlyphs - 3 {
            let nextLineIndex = curLineRange.location + curLineRange.length + 3
            var nextLineRange = NSMakeRange(0, 0)
            lm.lineFragmentRect(forGlyphAt: nextLineIndex, effectiveRange: &nextLineRange)
            let curCharLineRange = lm.characterRange(forGlyphRange: curLineRange, actualGlyphRange: nil)
            let nextCharLineRange = lm.characterRange(forGlyphRange: nextLineRange, actualGlyphRange: nil)
            if range.location > curCharLineRange.location { MoveCursorUpAction.prevOffset = range.location - curCharLineRange.location }
            let offset = min(nextCharLineRange.length - 1, MoveCursorUpAction.prevOffset)
            editor.setSelectedRange(NSMakeRange(nextCharLineRange.location + offset, 0))
        }
    }
}
