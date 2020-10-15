//
//  UIColor+Extensions.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 12/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func image(size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        if #available(iOS 10.0, *) {
            return UIGraphicsImageRenderer(size: size).image { rendererContext in
                self.setFill()
                rendererContext.fill(CGRect(origin: .zero, size: size))
            }
        } else {
            let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
            UIGraphicsBeginImageContext(rect.size)
            let context = UIGraphicsGetCurrentContext()
            
            context?.setFillColor(self.cgColor)
            context?.fill(rect)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
        }
    }
}
