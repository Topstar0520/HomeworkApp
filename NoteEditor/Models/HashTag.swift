//
//  HashTag.swift
//  Note Editor
//
//  Created by Thang Pham on 8/15/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

class HashTag {
    var id = ""
    var tag = ""
    var noteId = ""
    func primaryKey() -> String? {
        return "id"
    }
}
