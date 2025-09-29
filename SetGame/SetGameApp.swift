//
//  SetGameApp.swift
//  SetGame
//
//  Created by Gleb on 25.09.2025.
//

import SwiftUI

@main
struct SetGameApp: App {
    @StateObject var game = ShapeSetGame()
    
    var body: some Scene {
        WindowGroup {
            ShapeSetGameView(viewModel: game)
        }
    }
}
