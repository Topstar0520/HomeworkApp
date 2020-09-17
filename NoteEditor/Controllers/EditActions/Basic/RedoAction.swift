//
//  RedoAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class RedoAction: NSObject, EditAction {
    
    var normalImage: UIImage = UIImage(named: "redo-icon", in: bundle, compatibleWith: nil)!
    
    var selectedImage: UIImage = UIImage(named: "redo-selected-icon", in: bundle, compatibleWith: nil)!
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString,textview:UITextView) {
        editor.redo()
    }
}
