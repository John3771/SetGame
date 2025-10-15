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
                let base = RoundedRectangle(cornerRadius: Constants.cornerRadius)
                base.strokeBorder(Color.orange, lineWidth: Constants.lineWidth)
                    .background(base.fill(.white))
                    .overlay(content)
                    .opacity(isFaceUp ? 1 : 0)
                base.fill()
                    .opacity(isFaceUp ? 0 : 1)
            }
        }
    }
    
    private struct Constants {
        static let lineWidth: CGFloat = 3
        static let cornerRadius: CGFloat = 18
    }
}

extension View {
    func cardify(isFaceUp: Bool, isSelected: Bool, isMatched: Bool) -> some View {
        modifier(Cardify(isFaceUp: isFaceUp, isSelected: isSelected, isMatched: isMatched))
    }
}
