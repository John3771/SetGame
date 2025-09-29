//
//  ShapeSetGame.swift
//  SetGame
//
//  Created by Gleb on 25.09.2025.
//

import Foundation

class ShapeSetGame: ObservableObject {
    @Published private var model = createSetGame()
    
    private static func createSetGame() -> SetGame {
        var game = SetGame()
        game.deal()
        return game
    }
    
    func newGame() {
        model.newGame()
    }
    
    func shuffle() {
        model.shuffle()
    }
    
    func deal() {
        model.deal()
    }
    
    typealias Card = SetGame.Card
    
    var cards: [Card] {
        return model.cards
    }
    
    var deck: [Card] {
        return model.deck
    }
    
    var visibleCards: [Card] {
        return model.visibleCards
    }
    
    var chosenCards: [Card] {
        return model.chosenCards
    }
    
    var discarded: [Card] {
        return model.discarded
    }
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    var chosenCardsAreASet: Bool? {
        model.chosenCards.countIsValid ? model.chosenCards.isSet : nil
    }

    func deal3() {
        model.deal3()
    }
}
