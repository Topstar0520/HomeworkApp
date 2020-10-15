//
//  TickCheckboxAction.swift
//  Note Editor
//
//  Created by Thang Pham on 9/11/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

class TickCheckboxAction: AddCheckboxAction {
    
    override func execute(in range: NSRange, with attrs: NSAttributedString) {
        let lineRange = (attrs.string as NSString).lineRange(for: range)
        let tag = (attrs.string as NSString).substring(with: NSMakeRange(lineRange.location, 1))
        let replacingString = tag == "-" ? "+" : "-"
        editor.replaceCharacters(in: NSMakeRange(lineRange.location, 1), with: NSAttributedString(string: replacingString) , set: NSMakeRange(lineRange.location + 3, 0))
    }
}
