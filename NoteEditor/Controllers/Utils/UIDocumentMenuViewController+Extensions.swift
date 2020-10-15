//
//  UIDocumentMenuViewController+Extensions.swift
//  Note Editor
//
//  Created by Thang Pham on 9/10/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

private var xoAssociationKey : UInt8 = 0

extension UIDocumentMenuViewController {
    var completion: ((String?) -> ())? {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as? ((String?) -> ())
        }
        set (newValue){
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
