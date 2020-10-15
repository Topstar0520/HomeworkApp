//
//  DividerSyntaxBuilder.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class DividerSyntaxBuilder: MarkupSyntaxBuilder {
    
    static let instance = DividerSyntaxBuilder()
    
    func regex() -> NSRegularExpression {
        let pattern = "(?:\\n|\\r|^|\\G)(---)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        return reg
    }

    func stylizeSyntaxElements(in range:NSRange, with string: NSMutableAttributedString) -> NSRange {
        regex().enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
            
            if let signRange = match?.range(at: 1) {
                string.addAttributes([NSAttributedString.Key.font: ThemeCenter.theme.emptyFont, NSAttributedString.Key.backgroundColor: ThemeCenter.theme.splitLineColor, NSAttributedString.Key.backgroundRenderingMode: BackgroundRenderingMode.SplitLine, NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.splitLineParagraphStyle], range: signRange)
            }
        })
        return range
    }
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        return nil
    }
    
    func addMarkupSyntax(in range: NSRange, with string: NSAttributedString, optional value: Any?) -> (NSRange, NSAttributedString) {
        let lineRange = (string.string as NSString).lineRange(for: range)
        let lineString = (string.string as NSString).substring(with: lineRange)
        var resStr = String()
        lineString.enumerateSubstrings(in: lineString.startIndex..<lineString.endIndex, options: .byLines) { (matchString, _, _, _) in
            if let str = matchString {
                resStr = str
            }
        }
        if resStr.isEmpty {
            let attrs = NSMutableAttributedString(string: "---\n\t")
            attrs.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.bodyParagraphStyle
                ], range: NSMakeRange(0, attrs.length))
            return (range, attrs)
        }else {
            let attrs = NSMutableAttributedString(string: "\n---\n\t")
            attrs.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.bodyParagraphStyle
                ], range: NSMakeRange(0, attrs.length))
            return (range, attrs)
        }
    }
}
