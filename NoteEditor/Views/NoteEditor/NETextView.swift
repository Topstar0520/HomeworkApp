//
//  NETextView.swift
//  Note Editor
//
//  Created by Thang Pham on 9/1/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class NETextView: UITextView {
    
    private static let customUndoManager = UndoManager()
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var superRect = super.caretRect(for: position)
       
        guard let font = self.font else { return superRect }
        
        // "descender" is expressed as a negative value,
        // so to add its height you must subtract its value
        superRect.size.height = font.pointSize - font.descender
        return superRect
    }
    
    override var undoManager: UndoManager? {
        get {
            return NETextView.customUndoManager
        }
    }
    
    override func canPerformAction(_ action: Selector,  withSender sender: Any?) -> Bool {
        if self.isEditable {
            if action == #selector(paste(_:)) {
                return true
            }
        }else {
            if action == #selector(cut(_:)) || action == #selector(paste(_:)) {
                return true
            }
        }
         
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func cut(_ sender: Any?) {
        super.cut(sender)
        if !self.isEditable {
            self.selectedTextRange = nil
        }
    }
    
    override func copy(_ sender: Any?) {
        super.copy(sender)
        if !self.isEditable {
            self.selectedTextRange = nil
        }
    }
    
    override func paste(_ sender: Any?) {
        super.paste(sender)
        if !self.isEditable {
            self.selectedTextRange = nil
        }
    } 

}

