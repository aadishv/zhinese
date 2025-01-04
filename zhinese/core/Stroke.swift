import CoreGraphics
//
//  Stroke.swift
//  strokes
//
//  Created by Aadish Verma on 11/27/24.
//
import Foundation
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
        self.path = Self.createPath(from: svgString)
        self.medianPath = Self.createMedianPath(from: medians)
    }

    private static func createPath(from svgString: String) -> Path {
        return Path { path in
            var components = svgString.components(separatedBy: " ")

            func getNextPoint() -> CGPoint {
                CGPoint(
                    x: Double(components.removeFirst())!,
                    y: Double(components.removeFirst())!
                )
            }

            while !components.isEmpty {
                switch components.removeFirst() {
                case "M":
                    path.move(to: getNextPoint())
                case "L":
                    path.addLine(to: getNextPoint())
                case "Q":
                    let controlPoint = getNextPoint()
                    path.addQuadCurve(to: getNextPoint(), control: controlPoint)
                case "C":
                    let control1 = getNextPoint()
                    let control2 = getNextPoint()
                    path.addCurve(to: getNextPoint(), control1: control1, control2: control2)
                default:
                    break
                }
            }
            path.closeSubpath()
        }
    }

    private static func createMedianPath(from medians: [CGPoint]) -> Path {
        return Path { path in
            guard let firstPoint = medians.first else { return }
            path.move(to: firstPoint)
            medians.dropFirst().forEach { point in
                path.addLine(to: point)
            }
        }
    }
}
