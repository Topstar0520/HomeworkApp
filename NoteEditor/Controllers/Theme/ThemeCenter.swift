//
//  ThemeCenter.swift
//  Note Editor
//
//  Created by Thang Pham on 8/18/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import Foundation

enum ThemeType {
    case Default
    case RTFExport
    case Preview
}
class ThemeCenter: NSObject {
    private static let themes: [ThemeType: Theme] = [.Default: DefaultTheme(), .RTFExport: RTFExportTheme(), .Preview: PreviewTheme()]
    static var theme: Theme = ThemeCenter.themes[.Default]!
    
    static func setTheme(type: ThemeType) {
        ThemeCenter.theme = ThemeCenter.themes[type]!
    }
}
