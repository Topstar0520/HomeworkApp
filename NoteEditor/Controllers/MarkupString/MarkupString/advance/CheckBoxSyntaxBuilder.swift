//
//  CheckBoxSyntaxBuilder.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 8/19/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

struct CheckBox {
    var ticked: Bool
}

class CheckBoxSyntaxBuilder: MarkupSyntaxBuilder {
    
    static let instance = CheckBoxSyntaxBuilder()
    
    func regex() -> NSRegularExpression {
        let pattern = "(?:\\n|\\r|^|\\G)([-|+])(?:\\h+?)(\\t*)(.*)(?:\\r|\\n|$)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        return reg
    }
    
    func stylizeSyntaxElements(in range:NSRange, with string: NSMutableAttributedString) -> NSRange {
        var insertMarks = [InsertionMark]()
        regex().enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
            if let tagRange = match?.range(at: 1), let tabRange = match?.range(at: 2), let textRange = match?.range(at: 3) {
                
                string.addAttributes([NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.bulletAndListParagraphStyle,
                    NSAttributedString.Key.font: ThemeCenter.theme.syntaxReplacementFont, NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bulletAndListColor], range: tagRange)
                if AttachmentLinkBuilder.instance.noteDescriptor != nil {
                    let url = URL(string: "NoteEditor://x-callback-url/checkbox")!
                    string.addAttributes([NSAttributedString.Key.link: url], range: tagRange)
                }
                let tag = (string.string as NSString).substring(with: tagRange)
                if tag == "+" {
                    string.addAttributes([NSAttributedString.Key.strikethroughColor : ThemeCenter.theme.syntaxColor, NSAttributedString.Key.strikethroughStyle: 1], range: textRange)
                }else {
                    string.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: textRange)
                }
                
                if tabRange.length == 0 {
                    let attrs = NSMutableAttributedString(string: "\t")
                    attrs.addAttributes([NSAttributedString.Key.font: ThemeCenter.theme.bodyFont, NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.bodyParagraphStyle], range: NSMakeRange(0, attrs.length))
                    insertMarks.append(InsertionMark(attr: attrs, location: tabRange.location))
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
    
    func isContainingSyntax(in range: NSRange, with string: NSAttributedString) -> (Bool, NSAttributedString) {
        let pattern = "(?:\\n|\\r|^|\\G)([-|+]\\h+?\\t*)(.*)(?:\\r|\\n|$)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        if let firstMatch = reg.firstMatch(in: string.string, options: [], range: range) {
            let tag = string.attributedSubstring(from: firstMatch.range(at: 1))
            return (true, tag)
        }
        return (false,NSAttributedString(string: ""))
    }
    
    func isCheckBoxSyntax(in range: NSRange, with string: NSAttributedString) -> Bool {
        let pattern = "([-|+]\\h+?\\t*)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        if reg.rangeOfFirstMatch(in: string.string, options: [], range: range) == range {
            return true
        }
        return false
    }
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        let pattern = "(?:\\n|\\r|^|\\G)([-|+]\\h+?\\t*)(.*)(?:\\r|\\n|$)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        let paragraphRange = (string.string as NSString).paragraphRange(for: range)
        let str = NSMutableAttributedString()
        var isCharactersDeleted = false
        (string.string as NSString).enumerateSubstrings(in: paragraphRange, options: .byLines) { (_, _,enclosingRange, _) in
            let lineString = NSMutableAttributedString(attributedString: string.attributedSubstring(from: enclosingRange))
            var removeRanges = [NSRange]()
            reg.enumerateMatches(in: lineString.string, options: [], range: NSMakeRange(0, lineString.length), using: { (match, flags, stop) in
                if let startTagRange = match?.range(at: 1) {
                    removeRanges.append(startTagRange)
                }
            })
            var shiftLen = Int(0)
            for removeRange in removeRanges {
                lineString.deleteCharacters(in: NSMakeRange(removeRange.location - shiftLen, removeRange.length))
                shiftLen += removeRange.length
                isCharactersDeleted = true
            }
            str.append(lineString)
        }
        return isCharactersDeleted ? (paragraphRange, str as NSAttributedString) : nil
    }
    
    func addMarkupSyntax(in range: NSRange, with string: NSAttributedString, optional value: Any?) -> (NSRange, NSAttributedString) {
        let paragraphRange = (string.string as NSString).paragraphRange(for: range)
        let str = NSMutableAttributedString(attributedString: string.attributedSubstring(from: paragraphRange))
        var insertPoints = [Int]()
        (str.string as NSString).enumerateSubstrings(in: NSMakeRange(0, str.length), options: .byLines) { (_, matchRange,_, _) in
            if matchRange.length > 0 {
                insertPoints.append(matchRange.location)
            }
        }
        var prefix = String()
        if let v = value as? CheckBox {
            prefix = v.ticked ? "+ \t" : "- \t"
        }
        if insertPoints.isEmpty {
            str.insert(NSAttributedString(string:prefix), at: 0)
        }else {
            var shiftLen = Int(0)
            for point in insertPoints {
                str.insert(NSAttributedString(string:prefix), at: point + shiftLen)
                shiftLen += prefix.count
            }
        }
        
        return (paragraphRange, str)
    }
}
