//
//  Writer+Conversions.swift
//  Slate
//
//  Created by John Coates on 6/8/17.
//  Copyright © 2017 John Coates. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Foundation

extension VectorAssetWriter {

    func dataPaths(fromPaths path: [Path], floats: [DataFloat], colors: [DataColor]) -> [DataPath] {
        return path.map { path -> DataPath in
            let instructions = path.instructions.map { dataInstruction(fromInstruction: $0) }
            return DataPath(instructions: instructions)
        }
    }
    
    func dataInstruction(fromInstruction instruction: Path.Instruction) -> DataInstruction {
        switch instruction {
        case .move(let point):
            return DataInstruction.move(to: dataPoint(fromPoint: point))
        case .addLine(let point):
            return DataInstruction.addLine(to: dataPoint(fromPoint: point))
        case .addCurve(let to, let control1, let control2):
            return DataInstruction.addCurve(to: dataPoint(fromPoint: to),
                                            control1: dataPoint(fromPoint: control1),
                                            control2: dataPoint(fromPoint: control2))
        case .close:
            return DataInstruction.close
        case .fill(let color):
            return DataInstruction.fill(color: dataColor(fromColor: color))
        case .stroke(let color):
            return DataInstruction.stroke(color: dataColor(fromColor: color))
        case .setLineWidth(let to):
            return DataInstruction.setLineWidth(toFloatIndex: index(forFloat: to))
        case .setLineCapStyle(let to):
            return .setLineCapStyle(to: to.rawValue)
        case .usesEvenOddFillRule:
            return DataInstruction.usesEvenOddFillRule
        
        case .initWith(let rect):
            return DataInstruction.initWith(rect: dataRect(fromRect: rect))
        case .initWith2(let rect, let cornerRadius):
            return DataInstruction.initWith2(rect: dataRect(fromRect: rect),
                                            cornerRadiusIndex: index(forFloat: cornerRadius))
        case .initWith3(let rect):
            return DataInstruction.initWith3(ovalIn: dataRect(fromRect: rect))
            
        // Graphics Conext
        case .contextSaveGState:
            return DataInstruction.contextSaveGState
        case .contextRestoreGState:
            return DataInstruction.contextRestoreGState
        case .contextTranslateBy(let x, let y):
            return DataInstruction.contextTranslateBy(xIndex: index(forFloat: x),
                                                                  yIndex: index(forFloat: y))
        case .contextRotate(let by):
            return DataInstruction.contextRotate(byIndex: index(forFloat: by))
        }
    }
    
    func dataColor(fromColor color: Path.Color) -> DataColor {
        for dataColor in self.colors {
            let realColor = self.color(fromDataColor: dataColor)
            if realColor == color {
                return dataColor
            }
        }
        
        fatalError("Couldn't find color: \(color)")
    }
    
    func dataRect(fromRect rect: Path.Rect) -> DataRect {
        return DataRect(xIndex: index(forFloat: rect.origin.x),
                         yIndex: index(forFloat: rect.origin.y),
                         widthIndex: index(forFloat: rect.size.x),
                         heightIndex: index(forFloat: rect.size.y)
        )
    }
    
    func dataPoint(fromPoint point: Path.Point) -> DataPoint {
        return DataPoint(xIndex: index(forFloat: point.x),
                         yIndex: index(forFloat: point.y))
    }
    
    func color(fromDataColor dataColor: DataColor) -> Path.Color {
        let red = self.floats[Int(dataColor.redIndex)].value
        let green = self.floats[Int(dataColor.greenIndex)].value
        let blue = self.floats[Int(dataColor.blueIndex)].value
        let alpha = self.floats[Int(dataColor.alphaIndex)].value
        
        return Path.Color(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
