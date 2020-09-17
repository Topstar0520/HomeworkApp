//
//  HashTagSyntaxBuilder.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class HashTagSyntaxBuilder: MarkupSyntaxBuilder {

    static let instance = HashTagSyntaxBuilder()
    
    func regex() -> NSRegularExpression {
        let pattern = "(?:\\n|\\r|\\b|\\h|^|\\G)(#\\w+)\\b"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        return reg
    }
    
    func stylizeSyntaxElements(in range:NSRange, with string: NSMutableAttributedString) -> NSRange {
        
        regex().enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
            
            if let matchRange = match?.range(at: 1) {
                string.addAttributes([NSAttributedString.Key.backgroundColor: ThemeCenter.theme.hashTagBackgroundColor,NSAttributedString.Key.foregroundColor: ThemeCenter.theme.hashTagForegroundColor,
                                      NSAttributedString.Key.backgroundRenderingMode: BackgroundRenderingMode.HashTag, NSAttributedString.Key.link: URL(string: "NoteEditor://x-callback-url/hashtag")!], range: matchRange)
            }
            
        })
        
        return range
    }
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        return nil
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
                let returnStr = NSMutableAttributedString(attributedString: string.attributedSubstring(from: word))
                returnStr.insert(NSAttributedString(string: "#"), at: 0)
                return (word, returnStr)
            }else {
                return (NSMakeRange(range.location, 0), NSAttributedString(string: "#"))
            }
        }else {
            let returnStr = NSMutableAttributedString(attributedString: string.attributedSubstring(from: range))
            returnStr.insert(NSAttributedString(string: "#"), at: 0)
            return (range, returnStr)
        }
    }
}
