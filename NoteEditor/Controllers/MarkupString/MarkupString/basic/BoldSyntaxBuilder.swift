//
//  BoldSyntaxBuilder.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class BoldSyntaxBuilder: MarkupSyntaxBuilder {

    static let instance = BoldSyntaxBuilder()
    
    func regex() -> NSRegularExpression {
        let pattern = "(\\*)(|\\S|\\S.*?\\S)(\\*)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        return reg
    }
    
    func stylizeSyntaxElements(in range: NSRange, with string: NSMutableAttributedString) -> NSRange {
            regex().enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
            
        if let startTagRange = match?.range(at: 1), let _ = match?.range(at: 2), let endTagRange = match?.range(at: 3) {
                string.addAttributes([NSAttributedStringKey.foregroundColor: ThemeCenter.theme.syntaxColor], range: startTagRange)
                string.addAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)], range: NSMakeRange(startTagRange.location, NSMaxRange(endTagRange) - startTagRange.location))
                //if textRange.length > 0 {
                //ThemeCenter.theme.syntaxColor
            //string.addAttributes([NSAttributedString.Key.font : ThemeCenter.theme.bodyBoldFont, NSAttributedString.Key.foregroundColor: UIColor.white], range: NSMakeRange(startTagRange.location, NSMaxRange(endTagRange) - startTagRange.location))
                //}
                //string.addAttributes([NSAttributedStringKey.foregroundColor: ThemeCenter.theme.syntaxColor], range: endTagRange)
            }
        })
        
        return range
    }
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        let str = NSMutableAttributedString()
        var isCharactersDeleted = false
        print(string)
        print(range)
        (string.string as NSString).enumerateSubstrings(in: range, options: .byLines) {
            (_, _,enclosingRange, _) in
            let lineString = NSMutableAttributedString(attributedString: string.attributedSubstring(from: enclosingRange))
            var removeRanges = [NSRange]()
            print(lineString.string)
            print(lineString.length)
            print(self.regex())
            self.regex().enumerateMatches(in: lineString.string, options: [], range: NSMakeRange(0, lineString.length), using: { (match, flags, stop) in
                if let startTagRange = match?.range(at: 1), let endTagRange = match?.range(at: 3) {
                    removeRanges.append(startTagRange)
                    removeRanges.append(endTagRange)
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
        return isCharactersDeleted ? (range, str as NSAttributedString) : nil
    }
    
    func addMarkupSyntax(in range: NSRange, with string: NSAttributedString, optional value: Any?) -> (NSRange, NSAttributedString) {
        if range.length == 0 {
            var wordRange: NSRange?
            let lineRange = (string.string as NSString).lineRange(for: range)
            (string.string as NSString).enumerateSubstrings(in: lineRange, options: .byWords , using: { (str, matchRange, enclosingRange, stop) in
                if let _ = matchRange.intersection(range) {
                    wordRange = matchRange
                }
            })
            if let word = wordRange {
                let str = NSMutableAttributedString(string: "*")
                str.append(string.attributedSubstring(from: word))
                str.append(NSAttributedString(string: "*"))
                str.insert(NSAttributedString(string: " "), at: 0)
                str.append(NSAttributedString(string: " "))
                return (word, str)
            }else {
                let attrs = NSAttributedString(string: " ** ")
                return (NSMakeRange(range.location, 0), attrs)
            }
        }else {
            let str = NSMutableAttributedString(attributedString: string.attributedSubstring(from: range))
            let asterisk = NSAttributedString(string: "*")
            var matchRanges = [NSRange]()
            (string.string as NSString).enumerateSubstrings(in: range, options: .byLines) { (_, matchRange, enclosingRange, _) in
                matchRanges.append(matchRange)
            }
            var shiftLen = 0
            for matchRange in matchRanges {
                if matchRange.length > 0 {
                    str.insert(asterisk, at: matchRange.location - range.location + shiftLen)
                    str.insert(asterisk, at: matchRange.location - range.location + matchRange.length + shiftLen + asterisk.length)
                    shiftLen += 2*asterisk.length
                }
            }
            
            return (range, str)
        }
    }
    
}
