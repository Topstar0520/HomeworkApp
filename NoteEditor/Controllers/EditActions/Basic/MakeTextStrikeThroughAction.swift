//
//  MakeTextStrikeThroughAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class MakeTextStrikeThroughAction: NSObject, EditAction {
    
    var normalImage: UIImage = UIImage(named: "maketextstrikethrough-icon", in: bundle, compatibleWith: nil)!
    
    var selectedImage: UIImage = UIImage(named: "maketextstrikethrough-selected-icon", in: bundle, compatibleWith: nil)!
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString,textview:UITextView) {
        print(attrs.string)
        var checkAstrick = String()
        if attrs.string.contains("-"){
            if let cursorPosition = textview.selectedTextRange?.start {
                // cursorPosition is a UITextPosition object describing position in the text (text-wise description)
                let str = textview.textStorage.attributedSubstring(from: textview.selectedRange)
                print(str)
                // text.selectedRange.
                var lower =  textview.selectedRange.lowerBound
                print(lower)
                
                if lower != 0{
                    lower = lower - 1
                }else{
                    lower = 0
                }
                
                let star = NSRange(location: lower, length: 1)
                
                let str1 = textview.textStorage.attributedSubstring(from: star)
                checkAstrick = str1.string
                print(checkAstrick)
            }
        }
        
        if let (replacingRange, replacingString) = StrikeThroughSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: attrs) {
            editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
        }else if checkAstrick.contains("-"){
            if let (replacingRange, replacingString) = StrikeThroughSyntaxBuilder.instance.truncateMarkupSyntax(in: NSRange(location: range.location - 1 , length: range.length + 2), with: attrs) {
                editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
            }
        }else {
            let (replacingRange, replacingString) = StrikeThroughSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: nil)
            if replacingRange.length == 0 {
                editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location + replacingString.length/2, 0))
            }else {
                editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
            }
        }
    }
}
