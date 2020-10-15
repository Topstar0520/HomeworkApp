//
//  SimpleIDGenerator.swift
//  Note Editor
//
//  Created by Thang Pham on 9/9/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

class SimpleIDGenerator {
    
    class func uniqueId(hint name: String) -> String {
        return name + "_" + UUID().uuidString
    }
    
    class func uniqueId() -> String {
        return UUID().uuidString
    }
}
