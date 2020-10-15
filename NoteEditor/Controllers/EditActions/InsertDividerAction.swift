//
//  InsertDividerAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class InsertDividerAction: NSObject, EditAction {
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "insertdivider-icon") 
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "insertdivider-selected-icon")
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString,textview:UITextView) {
        let (replacingRange, replacingString) = DividerSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: nil)
        editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location + replacingString.length, 0))
    }
}
