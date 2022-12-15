//
//  Theme.swift
//  meals
//
//  Created by aclowkey on 11/12/2022.
//

import Foundation
import SwiftUI

class Theme {
    static func backgroundColor(scheme: ColorScheme) -> Color {
        return scheme == .dark ? Color(hex:0x242426) : Color.white
    }
    
    static func foregroundColor(scheme: ColorScheme) -> Color {
        return scheme == .dark ? Color.white : Color.black
    }
}
