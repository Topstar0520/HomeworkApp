//
//  UIImage+Extensions.swift
//  Note Editor
//
//  Created by Thang Pham on 8/22/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

extension UIImage {
    
    // offscreen rendering view 
    static func getImageFromView(_ view: UIView) -> UIImage? {
        var image: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func resizeImage(widthSize: CGFloat) -> UIImage {
        let ratio  = widthSize/self.size.width
        let heightSize = ratio*self.size.height
        let newSize = CGSize(width: widthSize, height: heightSize)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
