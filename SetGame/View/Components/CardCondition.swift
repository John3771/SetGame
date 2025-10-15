//
//  CardCondition.swift
//  SetGame
//
//  Created by Gleb on 25.09.2025.
//

import Foundation

enum NumberOfShapes: Int, CaseIterable {
    case one = 1
    case two
    case three
}

enum TypeOfShape: CaseIterable {
    case diamond
    case squiggle
    case oval
}

enum Shading: CaseIterable {
    case solid
    case color
    case open
}

enum ShapeColor: CaseIterable {
    case red
    case green
    case purple
}
