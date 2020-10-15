//
//  InsertTextAction.swift
//  Note Editor
//
//  Created by Pham Thang on 12/14/18.
//  Copyright © 2018 Marko Rankovic. All rights reserved.
//

import UIKit

class InsertTextAction: NSObject, EditAction {
    
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
    
    func execute(in range: NSRange, with attrs: NSAttributedString,textview:UITextView) {
        editor.replaceCharacters(in: range, with: attrs , set: NSMakeRange(range.location + attrs.length, 0))
    }
}
