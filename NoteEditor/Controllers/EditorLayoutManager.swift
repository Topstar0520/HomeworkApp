//
//  EditorLayoutManager.swift
//  Note Editor
//
//  Created by Thang Pham on 8/19/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class EditorLayoutManager: NSLayoutManager {
    
    override func fillBackgroundRectArray(_ rectArray: UnsafePointer<CGRect>, count rectCount: Int, forCharacterRange charRange: NSRange, color: UIColor) {

        var renderMode = BackgroundRenderingMode.Other
        let headIndent = CGFloat(30)
        let tailIndent = CGFloat(-15)
        let lineWidth  = textContainers[0].size.width
        if let storage = self.textStorage {
            let attrs = storage.attributes(at: charRange.location, effectiveRange: nil)
            if let mode = attrs[NSAttributedString.Key.backgroundRenderingMode] {
                renderMode = mode as! BackgroundRenderingMode
            }
        }
        
        if renderMode == .Other {
            super.fillBackgroundRectArray(rectArray, count: rectCount, forCharacterRange: charRange, color: color)
            return
        }
        
        let rect = self.lineFragmentRect(forGlyphAt: self.glyphIndexForCharacter(at: charRange.location), effectiveRange: nil)
        let frameLineHeight = rect.height
        let lineHeight = min(frameLineHeight, UIFont.systemFont(ofSize: 17).lineHeight)
        //ThemeCenter.theme.bodyFont
        if renderMode == .HighLight {
            if let ctx = UIGraphicsGetCurrentContext() {
                let path = CGMutablePath()
                let rect = CGRect(x: rectArray[0].minX, y: rectArray[0].minY, width: rectArray[0].maxX - rectArray[0].minX, height:lineHeight)
                path.addRect(rect)
                ctx.addPath(path)
                ctx.setFillColor(color.cgColor)
                ctx.drawPath(using: .fill)
            }
            return
        }
        
        if renderMode == .SplitLine {
            if let ctx = UIGraphicsGetCurrentContext() {
                let path = CGMutablePath()
                path.move(to: CGPoint(x: rectArray[0].minX, y: rectArray[0].midY))
                path.addLine(to: CGPoint(x: rectArray[0].minX - lineWidth + headIndent - tailIndent, y: rectArray[0].midY))
                ctx.addPath(path)
                ctx.setLineWidth(1.0)
                ctx.setStrokeColor(color.cgColor)
                ctx.drawPath(using: .stroke)
            }
            return
        }
        
        if renderMode == .BlockQuote {
            if let ctx = UIGraphicsGetCurrentContext() {
                let path = CGMutablePath()
                path.move(to: CGPoint(x: headIndent/2.0, y: rectArray[0].minY))
                path.addLine(to: CGPoint(x: headIndent/2.0, y: rectArray[rectCount - 1].maxY))
                ctx.addPath(path)
                ctx.setLineWidth(1.0)
                ctx.setStrokeColor(color.cgColor)
                ctx.drawPath(using: .stroke)
            }
            return
        }
        
        if renderMode == .HashTag || renderMode == .CodeBlock || renderMode == .SnippetCode {
            let frameHeight = renderMode == .HashTag ? lineHeight : frameLineHeight - 0.5
            var cornerRadius = renderMode == .HashTag ? CGFloat(5) : CGFloat(0)
            var rectXMin = headIndent
            if renderMode == .SnippetCode {
                for i in 0..<rectCount {
                    if rectXMin < rectArray[i].minX {
                        rectXMin = rectArray[i].minX
                    }
                }
            }
            if let ctx = UIGraphicsGetCurrentContext() {
                for i in 0..<rectCount {
                    var minX = max(rectXMin, rectArray[i].minX)
                    if i == 0 && renderMode == .CodeBlock {
                        minX = min(rectXMin, rectArray[i].minX)
                    }
                    let maxX = min(lineWidth + tailIndent, rectArray[i].maxX)
                    let lineCount = Int(0.5 + (rectArray[i].maxY - rectArray[i].minY)/frameLineHeight)
                    for j in 0..<lineCount {
                        let path = CGMutablePath()
                        let rect = CGRect(x: minX, y: rectArray[i].minY + CGFloat(j)*frameLineHeight, width: maxX - minX, height: frameHeight)
                        cornerRadius = min(cornerRadius, rect.width/2.0)
                        cornerRadius = min(cornerRadius, rect.height/2.0)
                        path.addRoundedRect(in: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
                        ctx.addPath(path)
                        ctx.setFillColor(color.cgColor)
                        ctx.drawPath(using: .fill)
                    }
                }
            }
            return
        }
        
        super.fillBackgroundRectArray(rectArray, count: rectCount, forCharacterRange: charRange, color: color)
    }
}
