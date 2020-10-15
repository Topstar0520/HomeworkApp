//
//  HighlightTextAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class HighlightTextAction: NSObject, EditAction {
    
    var normalImage: UIImage = UIImage(named: "highlighttext-icon", in: bundle, compatibleWith: nil)!
    
    var selectedImage: UIImage = UIImage(named: "highlighttext-selected-icon", in: bundle, compatibleWith: nil)!
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString,textview:UITextView) {
        if editor.isMakeHighLightFlag {
            let checkAstrick = String("::::")
            if attrs.string.contains(checkAstrick)
            {
                let (repRange, _) = HighlightSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: nil)
                if(range.location < attrs.string.length - 1)
                {
                    if let (replacingRange, replacingString) = HighlightSyntaxBuilder.instance.truncateMarkupSyntax(in: NSRange(location: repRange.location - 2 , length: repRange.length + 4), with: attrs) {
                        editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
                    }
                }
                
            }
             
            editor.textView.selectedTextRange = editor.textView.textRange(from: editor.textView.endOfDocument, to: editor.textView.endOfDocument)
            
            
        } else {
            if let (replacingRange, replacingString) = HighlightSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: attrs) {
                editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
            }else {
                let (replacingRange, replacingString) = HighlightSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: nil)
                if replacingRange.length == 0 {
                    editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location + replacingString.length/2, 0))
                }else {
                    editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
                    
                }
            }
        }
        editor.isMakeHighLightFlag = !editor.isMakeHighLightFlag
    }
}
