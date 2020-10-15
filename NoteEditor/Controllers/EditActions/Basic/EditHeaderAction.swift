//
//  EditHeaderAction.swift
//  Note Editor
//
//  Created by Thang Pham on 9/12/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

class EditHeaderAction: MakeHeaderAction {
    
    override func execute(in range: NSRange, with attrs: NSAttributedString) {
        editor.requestHeaderType { (headerType) in
            let headerLen = headerType.rawValue + 2
            let editRange = NSMakeRange(range.location + headerLen, range.length)
            self.editor.textView.undoManager?.beginUndoGrouping()
            if let (replacingRange, replacingString) = MarkupSyntaxTruncater.instance.truncateHeaders(in: editRange, with: attrs) {
                self.editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(editRange.location - headerLen, editRange.length))
                let (replaceRange, replaceString) = HeaderSyntaxBuilder.instance.addMarkupSyntax(in: range, with: attrs, optional: headerType)
                self.editor.replaceCharacters(in: replaceRange, with: replaceString, set: NSMakeRange(self.editor.textView.selectedRange.location + headerLen, editRange.length))
            }else {
                let (replacingRange, replacingString) = HeaderSyntaxBuilder.instance.addMarkupSyntax(in: editRange, with: attrs, optional: headerType)
                self.editor.replaceCharacters(in: replacingRange, with: replacingString, set: NSMakeRange(editRange.location + headerLen, editRange.length))
            }
            self.editor.textView.undoManager?.endUndoGrouping()
        }
    }
}
