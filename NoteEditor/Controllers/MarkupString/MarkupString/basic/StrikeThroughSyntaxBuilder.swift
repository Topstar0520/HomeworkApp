//
//  StrikeThroughSyntaxBuilder.instance.swift
//  Note Editor
//
//  Created by Thang Pham on 8/17/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class StrikeThroughSyntaxBuilder: MarkupSyntaxBuilder {

    static let instance = StrikeThroughSyntaxBuilder()
    
    func regex() -> NSRegularExpression {
        let pattern = "(\\-)(|\\S|\\S.*?\\S)(\\-)"
        let reg = try! NSRegularExpression(pattern: pattern, options: [])
        return reg
    }
    
    func stylizeSyntaxElementsNew(in range:NSRange, with string: NSMutableAttributedString) -> NSRange{
        
        var counter = 0
        var startLocation = -1
        
            print(string.string.count)
            while(counter < string.string.count){
                
                let char = string.attributedSubstring(from: NSRange(location: counter, length: 1)).string
                print(char)
                
                if(char == "-"){
                    
                    if(startLocation == -1){
                        startLocation = counter
                    }
                    else{
                        
                        if(counter+1 != string.length){
                            
                            let c = string.attributedSubstring(from: NSRange(location: counter+1, length:1)).string
                            let previousC = string.attributedSubstring(from: NSRange(location: counter-1, length: 1)).string
                            var startC = " "
                            
                            if(startLocation > 0){
                                startC = string.attributedSubstring(from: NSRange(location: startLocation-1, length: 1)).string
                            }
                            
                            
                            if((c == " " || c == "\n") && (startC == " " || startC == "\n") && previousC != " "){
                                
                                let startRange = NSRange(location: startLocation, length: counter-startLocation)
                                
                                var endRange = NSRange()
                                
                                endRange = NSRange(location: startLocation, length: counter + 1 - startLocation)
                                
                                // line
                                string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor], range: startRange)
                                string.addAttributes([NSAttributedString.Key.strikethroughColor : ThemeCenter.theme.syntaxColor, NSAttributedString.Key.strikethroughStyle: 1], range: startRange)
                                string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor], range: endRange)
                                startLocation = -1
                            }
                            else if previousC == " "{
                                
                                startLocation = counter
                                print("inside1")
                            }
                        }
                        else{
                            
                            let c =   string.attributedSubstring(from: NSRange(location: counter-1, length: 1)).string
                            
                            var previousC = " "
                            if(startLocation > 0){
                                previousC = string.attributedSubstring(from: NSRange(location: startLocation-1, length: 1)).string
                            }
                            
                            if(c != " " && c != "-" && (previousC == " " || previousC == "\n")){
                                // line
                                let startRange = NSRange(location: startLocation, length: counter-startLocation)
                                let endRange = NSRange(location: startLocation, length: counter + 1 - startLocation)
                                // line
                                string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor], range: startRange)
                                string.addAttributes([NSAttributedString.Key.strikethroughColor: ThemeCenter.theme.syntaxColor, NSAttributedString.Key.strikethroughStyle: 1], range: startRange)
                                string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor], range: endRange)
                                startLocation = -1
                            }
                            else if(previousC != " "){
                                if(c != " "){
                                    startLocation = -1
                                    print("inside")
                                }
                                else{
                                    
                                }
                            }
                            else{
                                
                                
                            }
                        }
                    }
                }
                counter += 1
            }
            
            
             
        
        
      
        return range
    }

    func stylizeSyntaxElements(in range:NSRange, with string: NSMutableAttributedString) -> NSRange {
        regex().enumerateMatches(in: string.string , options: [], range: range, using: { (match, flags, stop) in
                print(match?.range)
                print(flags)
                print(stop)
                if let startTagRange = match?.range(at: 1), let _ = match?.range(at: 2), let endTagRange = match?.range(at: 3) {
                        string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor], range: startTagRange)
                        string.addAttributes([NSAttributedString.Key.strikethroughColor : ThemeCenter.theme.syntaxColor, NSAttributedString.Key.strikethroughStyle: 1], range: NSMakeRange(startTagRange.location, NSMaxRange(endTagRange) - startTagRange.location))
                        string.addAttributes([NSAttributedString.Key.foregroundColor: ThemeCenter.theme.syntaxColor], range: endTagRange)
                }
                
            })
        return range
    }
    
    func truncateMarkupSyntax(in range: NSRange, with string: NSAttributedString) -> (NSRange, NSAttributedString)? {
        let str = NSMutableAttributedString()
        var isCharactersDeleted = false
        print(string)
        print(range)
        (string.string as NSString).enumerateSubstrings(in: range, options: .byLines) {(_, _,enclosingRange, _) in
            let lineString = NSMutableAttributedString(attributedString: string.attributedSubstring(from: enclosingRange))
            var removeRanges = [NSRange]()
            print(lineString.string)
            print(lineString.length)
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
                let str = NSMutableAttributedString(string: "-")
                str.append(string.attributedSubstring(from: word))
                str.append(NSAttributedString(string: "-"))
                str.insert(NSAttributedString(string: " "), at: 0)
                str.append(NSAttributedString(string: " "))
                return (word, str)
            }else {
                let str = NSMutableAttributedString(string: " -- ")
                return (NSMakeRange(range.location, 0), str)
            }
        }else {
            let str = NSMutableAttributedString(attributedString: string.attributedSubstring(from: range))
            let hyphen = NSAttributedString(string: "-")
            var matchRanges = [NSRange]()
            (string.string as NSString).enumerateSubstrings(in: range, options: .byLines) { (_, matchRange, enclosingRange, _) in
                matchRanges.append(matchRange)
            }
            var shiftLen = 0
            for matchRange in matchRanges {
                if matchRange.length > 0 {
                    str.insert(hyphen, at: matchRange.location - range.location + shiftLen)
                    str.insert(hyphen, at: matchRange.location - range.location + matchRange.length + shiftLen + hyphen.length)
                    shiftLen += 2*hyphen.length
                }
            }
            
            return (range, str)
        }
    }
}
