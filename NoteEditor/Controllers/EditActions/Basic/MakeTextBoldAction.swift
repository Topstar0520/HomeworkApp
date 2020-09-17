//
//  MakeTextBoldAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class MakeTextBoldAction: NSObject, EditAction {
    
    var normalImage: UIImage = UIImage(named: "maketextbold-icon", in: bundle, compatibleWith: nil)!
    
    var selectedImage: UIImage = UIImage(named: "maketextbold-selected-icon", in: bundle, compatibleWith: nil)!
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString,textview:UITextView) {
        
        var checkAstrick = String()
        
        
        
        if attrs.string.contains("*"){
        if let cursorPosition = textview.selectedTextRange?.start {
            let (replacingRange, _) = BoldSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: nil)
        
            // cursorPosition is a UITextPosition object describing position in the text (text-wise description)
            let str = textview.textStorage.attributedSubstring(from: replacingRange)
            print(str)
            // text.selectedRange.
            var lower =  replacingRange.lowerBound
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
        if let (replacingRange, replacingString) = BoldSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: attrs) {
            editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
        }else if checkAstrick.contains("*"){
            
            let (repRange, _) = BoldSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: nil)
            
            if let (replacingRange, replacingString) = BoldSyntaxBuilder.instance.truncateMarkupSyntax(in: NSRange(location: repRange.location - 1 , length: repRange.length + 2), with: attrs) {
                editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
            }
            
        }
        else {
            let (replacingRange, replacingString) = BoldSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: nil)
            if replacingRange.length == 0 {
                editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location + replacingString.length/2, 0))
            }else {
                editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
            }
        }
    }
    
}
