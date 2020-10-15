//
//  TruncateHeaderAction.swift
//  Note Editor
//
//  Created by Thang Pham on 9/8/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class TruncateHeaderAction: NSObject, EditAction {
    
    var normalImage: UIImage {
        get {
            return UIImage()
        }
    }
    
    var selectedImage: UIImage {
        get {
            return UIImage()
        }
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        
        var lineRange = (attrs.string as NSString).lineRange(for: NSMakeRange(range.location - 1, 0))
        
        if lineRange.location > 0 {
            lineRange = NSMakeRange(lineRange.location - 1, lineRange.length + 1)
        }
        let cursorPos = NSMaxRange(range) + 1
        var (valid, tag) = BulletPointsSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
        if valid {
            editor.replaceCharacters(in: NSMakeRange( cursorPos - tag.length, tag.length), with: NSAttributedString(string: ""), set: NSMakeRange(cursorPos - tag.length, 0))
            return
        }
        
        (valid, tag) = BlockQuoteSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
        if valid {
            editor.replaceCharacters(in: NSMakeRange(cursorPos - tag.length, tag.length), with: NSAttributedString(string: ""), set: NSMakeRange(cursorPos - tag.length, 0))
            return
        }
        
        (valid, tag) = CheckBoxSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
        if valid {
            editor.replaceCharacters(in: NSMakeRange(cursorPos - tag.length, tag.length), with: NSAttributedString(string: ""), set: NSMakeRange(cursorPos - tag.length, 0))
            return
        }
        
        (valid, tag) = NumberlistSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
        if valid {
            editor.replaceCharacters(in: NSMakeRange(cursorPos - tag.length, tag.length), with: NSAttributedString(string: ""), set: NSMakeRange(cursorPos - tag.length, 0))
            return
        }
        
        (valid, tag) = HeaderSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
        if valid {
            editor.replaceCharacters(in: NSMakeRange(cursorPos - tag.length, tag.length), with: NSAttributedString(string: ""), set: NSMakeRange(cursorPos - tag.length, 0))
            return
        }
    
        editor.replaceCharacters(in: range, with: NSAttributedString(string: ""), set: NSMakeRange(range.location, 0))
    }
}

