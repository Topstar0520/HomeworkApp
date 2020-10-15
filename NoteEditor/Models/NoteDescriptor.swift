//
//  NoteDescriptor.swift
//  Note Editor
//
//  Created by Thang Pham on 9/8/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

public class NoteDescriptor: NSObject {
    public var id = ""
    var overview = ""
    var descImage1 = ""
    var descImage2 = ""
    public var title = ""
    public var date = NSDate()
    
    public override init() {
        super.init()
    }
    
    func primaryKey() -> String? {
        return "id"
    }
}
