//
//  MakeTextUnderlineAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class MakeTextUnderlineAction: NSObject, EditAction {
    
    var normalImage: UIImage = UIImage(named: "maketextunderline-icon", in: bundle, compatibleWith: nil)!
    
    var selectedImage: UIImage = UIImage(named: "maketextunderline-selected-icon", in: bundle, compatibleWith: nil)!
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString,textview:UITextView) {
        if let (replacingRange, replacingString) = UnderlineSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: attrs) {
            editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
        }else {
            let (replacingRange, replacingString) = UnderlineSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: nil)
            if replacingRange.length == 0 {
                editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location + replacingString.length/2, 0))
            }else {
                editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
            }
        }
    }
}
