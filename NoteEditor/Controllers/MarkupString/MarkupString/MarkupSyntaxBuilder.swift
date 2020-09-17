//
//  MarkupSyntaxBuilder.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

protocol MarkupSyntaxBuilder {

    func regex() -> NSRegularExpression
    
    func stylizeSyntaxElements(in range:NSRange, with string: NSMutableAttributedString) -> NSRange
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) ->  (NSRange, NSAttributedString)?

    func addMarkupSyntax(in range: NSRange, with string: NSAttributedString, optional value:Any?) -> (NSRange, NSAttributedString)
}

struct InsertionMark {
    var attr: NSAttributedString
    var location: Int
}
