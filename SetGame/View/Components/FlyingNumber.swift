//
//  AnimationForNewSetSelection.swift
//  SetGame
//
//  Created by Gleb on 25.09.2025.
//

import SwiftUI

struct FlyingNumber: View {
    let isGoodSet: Bool?
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        if let isGoodSet {
            Text(isGoodSet == true ? "Good Set" : "Bad Set")
                .font(.largeTitle)
                .foregroundStyle(isGoodSet ? .green : .red)
                .offset(x: 0, y: offset)
                .opacity(offset != 0 ? 0 : 1)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.8)) {
                        offset = !isGoodSet ? 200 : -200
                    }
                }
                .onDisappear {
                    offset = 0
                }
        }
    }
}

#Preview {
        FlyingNumber(isGoodSet: false)
}
