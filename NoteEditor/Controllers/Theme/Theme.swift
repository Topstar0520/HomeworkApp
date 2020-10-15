//
//  Theme.swift
//  Note Editor
//
//  Created by Thang Pham on 8/18/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

protocol Theme {
    
    // general editor settings
    var editorBackgroundColor: UIColor {get}
    
    // default paragraph styles
    var bodyParagraphStyle: NSParagraphStyle {get}
    var headerParagraphStyle: NSParagraphStyle {get}
    var bulletAndListParagraphStyle: NSParagraphStyle {get}
    var splitLineParagraphStyle: NSParagraphStyle {get}
    
    // text body fonts
    var fontSize: CGFloat {get}
    var bodyFont: UIFont {get}
    var bodyBoldFont: UIFont {get}
    var bodyItalicFont: UIFont {get}

    // text header font
    func headerFont(type: TextHeaderType) -> UIFont
    var subscriptFont: UIFont {get}
    
    // syntax custom fonts
    var emptyFont: UIFont {get}
    var syntaxReplacementFont: UIFont {get}

    // text colors
    var bodyColor: UIColor {get}
    var headerColor: UIColor {get}
    var highlightColor: UIColor {get}
    var highlightTextColor: UIColor {get}
    var linkColor: UIColor {get}
    var bulletAndListColor: UIColor {get}
    
    // hash tag background color
    var hashTagForegroundColor: UIColor {get}
    var hashTagBackgroundColor: UIColor {get}
    
    // markup syntax color
    var syntaxColor: UIColor {get}
    
    // code block attributes
    var codeForegroundColor: UIColor {get}
    var codeBackgroundStrokeColor: UIColor {get}
    var codeBackgroundFillColor: UIColor {get}
    var codeBodyFont: UIFont {get}
    
    // split line color
    var splitLineColor: UIColor {get}
}
