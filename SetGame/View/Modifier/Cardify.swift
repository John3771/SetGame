//
//  Cardify.swift
//  SetGame
//
//  Created by Gleb on 25.09.2025.
//

import SwiftUI

struct Cardify: ViewModifier {
    var isSelected: Bool
    var isMatched: Bool
    
    init(isFaceUp: Bool, isSelected: Bool, isMatched: Bool) {
        rotation = isFaceUp ? 0 : 180
        self.isSelected = isSelected
        self.isMatched = isMatched
    }
    
    var isFaceUp: Bool {
        rotation < 90
    }
    
    var rotation: Double
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                let base = RoundedRectangle(
                    cornerRadius: Constants.roundingRatio * geometry.size.width
                )
                base.strokeBorder(Color.orange, lineWidth: Constants.lineWidth * geometry.size.width)
                    .background(base.fill(.white.opacity(0.4)))
                    .shadow(
                        color: isSelected ? .accentColor : .clear,
                        radius: isSelected ? Constants.shadowRadiusRatio * geometry.size.width : 0
                    )
                    .overlay {
                        content
                    }
                    .opacity(isFaceUp ? 1 : 0)
                base.fill(.secondary)
                    .opacity(isFaceUp ? 0 : 1)
            }
        }
    }
    
    private struct Constants {
        static let lineWidth: CGFloat = 0.035
        static let aspectRatio: CGFloat = 2
        static let roundingRatio = 0.175
        static let spacingRatio = 0.1
        static let shadowRadiusRatio: CGFloat = 0.02
    }
}

extension View {
    func cardify(isFaceUp: Bool, isSelected: Bool, isMatched: Bool) -> some View {
        modifier(Cardify(isFaceUp: isFaceUp, isSelected: isSelected, isMatched: isMatched))
    }
}
