//
//  ArrowSyntaxBuilder.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 8/27/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class ArrowSyntaxBuilder: MarkupSyntaxBuilder {

    static let instance = ArrowSyntaxBuilder()
    
    func regex() -> NSRegularExpression {
        let pattern = "\\s(->)(\\H{0,1})\\s"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        return reg
    }
    
    func stylizeSyntaxElements(in range:NSRange, with string: NSMutableAttributedString) -> NSRange {
        var insertMarks = [InsertionMark]()
        regex().enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
            
            if let matchRange = match?.range(at: 1), let linkTag = match?.range(at: 2){
                string.addAttributes([NSAttributedString.Key.font : ThemeCenter.theme.emptyFont], range: matchRange)
                if linkTag.length == 0 {
                    let textAttachment = NSTextAttachment()
                    textAttachment.image = #imageLiteral(resourceName: "arrow-icon")
                    textAttachment.bounds = CGRect(x: 0, y: 0, width: UIFont.systemFont(ofSize: 17).lineHeight/2.0, height: UIFont.systemFont(ofSize: 17).lineHeight/2.0)
                    let attrs = NSAttributedString(attachment: textAttachment)
                    let insertRange = NSMakeRange(matchRange.location + matchRange.length, 1)
                    insertMarks.append(InsertionMark(attr: attrs, location: insertRange.location))
                }
            }
        })
        var shiftLen = 0
        for insertMark in insertMarks {
            string.insert(insertMark.attr, at: insertMark.location + shiftLen)
            shiftLen += insertMark.attr.length
        }
        return NSMakeRange(range.location, range.length + shiftLen)
    }
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        return nil
    }
    
    func addMarkupSyntax(in range: NSRange, with string: NSAttributedString, optional value: Any?) -> (NSRange, NSAttributedString) {
        return (range, string)
    }
}
