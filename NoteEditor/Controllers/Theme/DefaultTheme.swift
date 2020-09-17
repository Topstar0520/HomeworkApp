//
//  DefaultTheme.swift
//  Note Editor
//
//  Created by Thang Pham on 8/18/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class DefaultTheme: Theme {
    
    var editorBackgroundColor: UIColor {
        get {
            return DefaultTheme.BackgroundColor
        }
    }
    
    var bodyParagraphStyle: NSParagraphStyle {
        get {
            return DefaultTheme.BodyParagraphStyle
        }
    }
    
    var headerParagraphStyle: NSParagraphStyle {
        get {
            return DefaultTheme.HeaderParagraphStyle
        }
    }
    
    var bulletAndListParagraphStyle: NSParagraphStyle {
        get {
            return DefaultTheme.BulletAndListParagraphStyle
        }
    }
    
    var splitLineParagraphStyle: NSParagraphStyle {
        get {
            return DefaultTheme.SplitLineParagraphStyle
        }
    }
    
    var fontSize: CGFloat {
        get {
            return DefaultTheme.NormalFontSize
        }
    }
    
    var bodyFont: UIFont {
        get {
            return DefaultTheme.NormalFont
        }
    }
    
    var bodyBoldFont: UIFont {
        get {
            return DefaultTheme.BoldNormalFont
        }
    }
    
    var bodyItalicFont: UIFont {
        get {
            return DefaultTheme.ItalicNormalFont
        }
    }
    
    func headerFont(type: TextHeaderType) -> UIFont {
        switch type {
        case .H1:
            return DefaultTheme.HeaderFont1
        case .H2:
            return DefaultTheme.HeaderFont2
        case .H3:
            return DefaultTheme.HeaderFont3
        case .Other:
            return DefaultTheme.HeaderFont3
        default:
            return DefaultTheme.HeaderFont3
        }
    }
    
    var subscriptFont: UIFont {
        get {
            return DefaultTheme.SubscriptFont
        }
    }
    
    var emptyFont: UIFont {
        get {
            return DefaultTheme.EmptyFont
        }
    }
    
    var syntaxReplacementFont: UIFont {
        get {
            return DefaultTheme.SyntaxReplacementFont
        }
    }
    
    var highlightColor: UIColor {
        get {
            return DefaultTheme.HighlightColor
        }
    }
    
    var highlightTextColor: UIColor {
        get {
            return DefaultTheme.HighlightTextColor
        }
    }
    
    var bodyColor: UIColor {
        get {
            return DefaultTheme.NormalTextColor
        }
    }
    
    var headerColor: UIColor {
        get {
            return DefaultTheme.HeaderTextColor
        }
    }
    
    var linkColor: UIColor {
        get {
            return DefaultTheme.LinkColor
        }
    }
    
    var hashTagForegroundColor: UIColor {
        get {
            return DefaultTheme.HashTagForegroundColor
        }
    }
    
    var hashTagBackgroundColor: UIColor {
        get {
            return DefaultTheme.HashTagBackgroundColor
        }
    }
    
    var syntaxColor: UIColor {
        get {
            return DefaultTheme.SyntaxColor
        }
    }
    
    var bulletAndListColor: UIColor {
        get {
            return DefaultTheme.BulletAndListColor
        }
    }
    
    var codeForegroundColor: UIColor {
        get {
            return DefaultTheme.CodeForegroundColor
        }
    }
    
    var codeBackgroundStrokeColor: UIColor {
        get {
            return DefaultTheme.CodeBackgroundStrokeColor
        }
    }
    
    var codeBackgroundFillColor: UIColor {
        get {
            return DefaultTheme.CodeBackgroundFillColor
        }
    }
    
    var codeBodyFont: UIFont {
        get {
            return DefaultTheme.CodeFont
        }
    }
    
    var splitLineColor: UIColor {
        get {
            return DefaultTheme.SplitLineColor
        }
    }
    
    // MARK: - Color Settings
    private static let BackgroundColor = UIColor.black
    private static let NormalTextColor = UIColor.white
    private static let HeaderTextColor = UIColor.lightText
    private static let HashTagForegroundColor = UIColor.white
    private static let HashTagBackgroundColor = UIColor.gray
    private static let HighlightColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    private static let HighlightTextColor = UIColor.black
    private static let SyntaxColor = UIColor.gray
    private static let LinkColor = UIColor.orange
    private static let BulletAndListColor = UIColor.white
    private static let CodeBackgroundStrokeColor = UIColor.lightText
    private static let CodeBackgroundFillColor = UIColor.lightText
    private static let CodeForegroundColor = UIColor.black
    private static let SplitLineColor = UIColor.lightGray
    
    // MARK: - Font Settings
    
    // font size settings
    private static let NormalFontSize = CGFloat(17)
    private static let HeaderFontSize = CGFloat(26)
    private static let SubscriptFontSize = CGFloat(8)
    
    // body fonts
    private static let NormalFontDescriptor = UIFontDescriptor(name: "HelveticaNeue", size: NormalFontSize)
    private static let NormalFont = UIFont(descriptor: NormalFontDescriptor, size: NormalFontSize)
    private static let BoldNormalFont = UIFont(descriptor: NormalFontDescriptor.withSymbolicTraits(.traitBold)!, size: NormalFontSize)
    private static let ItalicNormalFont = UIFont(descriptor: NormalFontDescriptor.withSymbolicTraits(.traitItalic)!, size: NormalFontSize)
    private static let CodeFontDescriptor = UIFontDescriptor(name: "System", size: NormalFontSize)
    private static let CodeFont = UIFont(descriptor: CodeFontDescriptor, size: NormalFontSize)
    
    // header fonts
    private static let HeaderFontDescriptor = UIFontDescriptor(name: "HelveticaNeue", size: HeaderFontSize)
    private static let HeaderFont1 = UIFont(descriptor: NormalFontDescriptor, size: HeaderFontSize)
    private static let HeaderFont2 = UIFont(descriptor: NormalFontDescriptor, size: HeaderFontSize - 4)
    private static let HeaderFont3 = UIFont(descriptor: NormalFontDescriptor, size: HeaderFontSize - 8)
    private static let SubscriptFont = UIFont(descriptor: NormalFontDescriptor, size: SubscriptFontSize)
    
    // customized fonts
    private static let EmptyfontDescriptor = UIFontDescriptor(name: "EmptyFont", size: NormalFontSize)
    private static let syntaxReplacementFontDescriptor = UIFontDescriptor(name: "SyntaxReplacementFont", size: NormalFontSize)
    private static let EmptyFont = UIFont(descriptor: EmptyfontDescriptor, size: NormalFontSize)
    private static let SyntaxReplacementFont = UIFont(descriptor: syntaxReplacementFontDescriptor, size: NormalFontSize)
    
    // MARK: - Paragraph Style Settings
    
    // paragraph settings
    private static let FirstLineHeadIndent = CGFloat(3)
    private static let HeadIndent = CGFloat(32)
    private static let TailIndent = CGFloat(-15)
    
    // header paragraph style
    private static var HeaderParagraphStyle: NSParagraphStyle {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 0.5*HeaderFontSize
            paragraphStyle.firstLineHeadIndent = FirstLineHeadIndent
            paragraphStyle.headIndent = HeadIndent
            paragraphStyle.tailIndent = TailIndent
            paragraphStyle.paragraphSpacingBefore = 0
            paragraphStyle.paragraphSpacing = 0
            let tab = NSTextTab(textAlignment: .natural, location: HeadIndent, options:[:])
            paragraphStyle.tabStops = [tab]
            return paragraphStyle
        }
    }
    
    // body paragraph style
    private static var BodyParagraphStyle: NSParagraphStyle {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 0.5*NormalFontSize
            paragraphStyle.firstLineHeadIndent = HeadIndent
            paragraphStyle.headIndent = HeadIndent
            paragraphStyle.tailIndent = TailIndent
            paragraphStyle.paragraphSpacingBefore = 0
            paragraphStyle.paragraphSpacing = 0
            let tab = NSTextTab(textAlignment: .natural, location: HeadIndent, options:[:])
            paragraphStyle.tabStops = [tab]
            return paragraphStyle
        }
    }
    
    private static var BulletAndListParagraphStyle: NSParagraphStyle {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 0.5*NormalFontSize
            paragraphStyle.firstLineHeadIndent = FirstLineHeadIndent
            paragraphStyle.headIndent = HeadIndent
            paragraphStyle.tailIndent = TailIndent
            paragraphStyle.paragraphSpacingBefore = 0
            paragraphStyle.paragraphSpacing = 0
            let tab = NSTextTab(textAlignment: .natural, location: HeadIndent, options:[:])
            paragraphStyle.tabStops = [tab]
            return paragraphStyle
        }
    }
    
    private static var SplitLineParagraphStyle: NSParagraphStyle {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 0.5*NormalFontSize
            paragraphStyle.firstLineHeadIndent = HeadIndent
            paragraphStyle.headIndent = HeadIndent
            paragraphStyle.tailIndent = TailIndent
            paragraphStyle.paragraphSpacingBefore = 0
            paragraphStyle.paragraphSpacing = 0
            let tab = NSTextTab(textAlignment: .right, location: HeadIndent, options:[:])
            paragraphStyle.tabStops = [tab]
            return paragraphStyle
        }
    }
}
