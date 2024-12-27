//
//  Stroke.swift
//  zhinese
//
//  Created by Aadish Verma on 12/24/24.
//


//
//  Stroke.swift
//  strokes
//
//  Created by Aadish Verma on 11/27/24.
//
import Foundation
import CoreGraphics
import SwiftUI

struct Stroke: Identifiable, Hashable {
    var id = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let path: Path
    let medianPath: Path
    init(path: Path, medianPath: Path) {
        self.path = path
        self.medianPath = medianPath
    }
    init(svgString: String, medians: [CGPoint]) {
        //self.medians = medians
        self.path = Path { path in
            var split = svgString.components(separatedBy: " ")
            func getNextPoint() -> CGPoint {
                CGPoint(
                    x: Double(split.removeFirst())!,
                    y: Double(split.removeFirst())!
                )
            }
            while !split.isEmpty {
                let command = split.removeFirst()
                if command == "M" {
                    path.move(to: getNextPoint())
                }
                else if command == "L" {
                    path.addLine(to: getNextPoint())
                }
                else if command == "Q" {
                    let point = getNextPoint()
                    path.addQuadCurve(to: getNextPoint(), control: point)
                }
                else if command == "C" {
                    let control1 = getNextPoint()
                    let control2 = getNextPoint()
                    path.addCurve(to: getNextPoint(), control1: control1, control2: control2)
                }
            }
            path.closeSubpath()
        }
        medianPath = Path { path in
            path.move(to: medians[0])
            for median in [CGPoint](medians.dropFirst()) {
                path.addLine(to: median)
            }
        }
    }
}
