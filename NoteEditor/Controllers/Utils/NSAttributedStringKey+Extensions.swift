//
//  NSAttributedStringKey+Extensions.swift
//  Note Editor
//
//  Created by Thang Pham on 9/6/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

enum BackgroundRenderingMode: Int {
    case HashTag
    case HighLight
    case BlockQuote
    case CodeBlock
    case SnippetCode
    case SplitLine
    case Other
}
extension NSAttributedString.Key {
    
    public static let backgroundRenderingMode = NSAttributedString.Key(rawValue: "BackgroundRenderingMode")
    
}
