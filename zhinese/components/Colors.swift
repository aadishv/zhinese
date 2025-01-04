//
//  Colors.swift
//  zhinese
//
//  Created by Aadish Verma on 12/27/24.
//
import SwiftUI

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}
enum Colors {
    case buttonPrimary
    case deletionPrimary
    var zhineseColor: Color {
        switch self {
        case .buttonPrimary:
            return Color(hex: 0x3139FB)
        case .deletionPrimary:
            return Color.red
        default:
            print("couldn't find")
            return Color.black
        }
    }
}
