//
//  MakeBlockCodeSyntaxBuilder.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 8/19/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class MakeBlockCodeSyntaxBuilder: MarkupSyntaxBuilder {

    static let instance = MakeBlockCodeSyntaxBuilder()
    
    func regex() -> NSRegularExpression {
        let pattern = "(?:\\n|\\r|^)(```.*?```.*?(?:\\r|\\n|$))"
        let reg = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        return reg
    }
    
    func stylizeSyntaxElements(in range:NSRange, with string: NSMutableAttributedString) -> NSRange {
        var matchRanges = [NSRange]()
        regex().enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
            
            if let matchRange = match?.range(at: 1) {
                string.addAttributes([NSAttributedString.Key.font : ThemeCenter.theme.codeBodyFont, NSAttributedString.Key.foregroundColor: ThemeCenter.theme.codeForegroundColor, NSAttributedString.Key.backgroundColor: ThemeCenter.theme.codeBackgroundFillColor, NSAttributedString.Key.backgroundRenderingMode: BackgroundRenderingMode.CodeBlock], range: matchRange)
                matchRanges.append(matchRange)
            }
        })
        if !matchRanges.isEmpty {
            return removeAttachments(in: range, scanningRanges: matchRanges, with: string)
        }
        return range
    }
    
     func removeAttachments(in range: NSRange, scanningRanges: [NSRange], with string: NSMutableAttributedString) -> NSRange {
        var editedRanges = [NSRange]()
        for scanningRange in scanningRanges {
            if string.containsAttachments(in: scanningRange ) {
                string.enumerateAttribute(NSAttributedString.Key.attachment, in: scanningRange, options: .longestEffectiveRangeNotRequired) { (value, matchRange, stop) in
                    if let _ = value as? NSTextAttachment {
                        editedRanges.append(matchRange)
                    }
                }
            }
        }
        var shiftLen = 0
        for i in 0..<editedRanges.count {
            string.deleteCharacters(in: NSMakeRange(editedRanges[i].location - shiftLen, editedRanges[i].length))
            shiftLen += editedRanges[i].length
        }
        return NSMakeRange(range.location, range.length - shiftLen)
    }
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        let pattern = "([\\n|\\r|^]```[\\n|\\r])(.*?)([\\n|\\r|^]```.*?[\\r|\\n|$])"
        let reg = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        var paragraphRange = (string.string as NSString).paragraphRange(for: range)
        if paragraphRange.location > 0 {
            let prevLineRange = (string.string as NSString).lineRange(for: NSMakeRange(paragraphRange.location - 1, 0))
            paragraphRange = paragraphRange.union(prevLineRange)
            if prevLineRange.location > 0 {
               paragraphRange = paragraphRange.union((string.string as NSString).lineRange(for: NSMakeRange(prevLineRange.location - 1, 0)))
            }
        }
        if paragraphRange.location + paragraphRange.length < string.length - 1 {
            paragraphRange = paragraphRange.union((string.string as NSString).lineRange(for: NSMakeRange(paragraphRange.location + paragraphRange.length + 1, 0)))
        }
        let str = NSMutableAttributedString(attributedString: string.attributedSubstring(from: paragraphRange))
        var isCharactersDeleted = false
        var removeRanges = [NSRange]()
        reg.enumerateMatches(in: str.string, options: [], range: NSMakeRange(0, str.length), using: { (match, flags, stop) in
            if let startTagRange = match?.range(at: 1), let endTagRange = match?.range(at: 3 ) {
                removeRanges.append(startTagRange)
                removeRanges.append(endTagRange)
            }
        })
        var shiftLen = Int(0)
        for removeRange in removeRanges {
            str.deleteCharacters(in: NSMakeRange(removeRange.location - shiftLen, removeRange.length))
            shiftLen += removeRange.length
            isCharactersDeleted = true
        }
        return isCharactersDeleted ? (paragraphRange, str as NSAttributedString) : nil
    }
    
    func addMarkupSyntax(in range: NSRange, with string: NSAttributedString, optional value: Any?) -> (NSRange, NSAttributedString) {
        let paragraphRange = (string.string as NSString).paragraphRange(for: range)
        let str = NSMutableAttributedString(string: "\n```\n")
        str.append(string.attributedSubstring(from: paragraphRange))
        str.append(NSAttributedString(string: "\n```\n"))
        return (paragraphRange, str)
    }
}
