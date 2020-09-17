//
//  TruncateAttachmentAction.swift
//  Note Editor
//
//  Created by Thang Pham on 9/28/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class TruncateAttachmentAction: NSObject, EditAction {
    
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
        
        var lineRange = (attrs.string as NSString).lineRange(for: range)
        lineRange = NSMakeRange(lineRange.location, NSMaxRange(range) - lineRange.location)
        
        let cursorPos = NSMaxRange(range)
        var (valid, tag) = PhotoLinkSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
        if valid {
            editor.replaceCharacters(in: NSMakeRange( cursorPos - tag.count, tag.count), with: NSAttributedString(string: ""), set: NSMakeRange(cursorPos - tag.count, 0))
            return
        }
        
        (valid, tag) = FileAttachmentSyntaxBuilder.instance.isContainingSyntax(in: lineRange, with: attrs)
        if valid {
            editor.replaceCharacters(in: NSMakeRange(cursorPos - tag.count, tag.count), with: NSAttributedString(string: ""), set: NSMakeRange(cursorPos - tag.count, 0))
            return
        }
        
        editor.replaceCharacters(in: range, with: NSAttributedString(string: ""), set: NSMakeRange(range.location, 0))
    }
        
}
