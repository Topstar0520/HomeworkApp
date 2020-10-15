//
//  AddCheckboxAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class AddCheckboxAction: NSObject, EditAction {
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "addcheckbox-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "addcheckbox-selected-icon")
    }
    
    var editor: NoteEditor!
    
    var ticked: Bool {
        get {
            return false
        }
    }
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        editor.textView.undoManager?.beginUndoGrouping()
        if let (replacingRange, replacingString) = CheckBoxSyntaxBuilder.instance.truncateMarkupSyntax(in: range, with: attrs) {
            editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(range.location - 3, range.length))
        }else if let (replacingRange, replacingString) = MarkupSyntaxTruncater.instance.truncateHeaders(in: range, with: attrs) {
            editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(replacingRange.location, replacingRange.location + replacingString.length))
            let (replaceRange, replaceString) = CheckBoxSyntaxBuilder.instance.addMarkupSyntax(in: NSMakeRange(replacingRange.location, 0), with: attrs, optional: CheckBox(ticked: ticked))
            editor.replaceCharacters(in: replaceRange, with: replaceString, set: NSMakeRange(editor.textView.selectedRange.location + 3, range.length))
        }else {
            let (replacingRange, replacingString) = CheckBoxSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: CheckBox(ticked: ticked))
            editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(range.location + 3, range.length))
        }
        editor.textView.undoManager?.endUndoGrouping()
    }
}
