//
//  CircleView.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-01-04.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit

@IBDesignable
class CircleView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBInspectable public var color: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override public func draw(_ rect: CGRect) {
        guard color != nil else {
            return
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.addEllipse(in: self.bounds)
        context.setFillColor(self.color!.cgColor)
        context.fillPath()
    }

}
