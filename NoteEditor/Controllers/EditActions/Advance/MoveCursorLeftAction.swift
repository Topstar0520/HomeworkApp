//
//  MoveCursorLeftAction.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class MoveCursorLeftAction: NSObject, EditAction {
    
    var normalImage: UIImage {
        return #imageLiteral(resourceName: "movecursorleft-icon")
    }
    
    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "movecursorleft-selected-icon")
    }
    
    var editor: NoteEditor!
    
    required init(editor: NoteEditor) {
        self.editor = editor
    }
    
    func execute(in range: NSRange, with attrs: NSAttributedString) {
        let location = range.location > 0 ? range.location - 1: range.location
        editor.setSelectedRange(NSMakeRange(location, 0))
    }
}
