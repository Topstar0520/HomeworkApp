//
//  InsertCodeAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class InsertCodeAction: NSObject, EditAction {
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "insertcode-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "insertcode-selected-icon")
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        if let (replacingRange, replacingString) =  InsertCodeSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: attrs) {
            editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
        }else {
            let (replacingRange, replacingString) = InsertCodeSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: nil)
            if replacingRange.length == 0 {
                editor.replaceCharacters(in: NSMakeRange(replacingRange.location, 0), with: replacingString, set: NSMakeRange(replacingRange.location + replacingString.length/2, 0))
            }else {
                editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingString.length))
            }
        }
    }
}
