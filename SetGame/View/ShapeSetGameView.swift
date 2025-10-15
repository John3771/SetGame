//
//  ShapeSetGameView.swift
//  SetGame
//
//  Created by Gleb on 25.09.2025.
//

import SwiftUI

struct ShapeSetGameView: View {
    typealias Card = SetGame.Card
    @ObservedObject var viewModel: ShapeSetGame
    
    @Namespace private var dealingNamespace
    @Namespace private var discardingNamespace
    
    // MARK: Screen
    
    var body: some View {
        VStack {
            visibleCards
            HStack() {
                deck
                Spacer()
                newGameButton
                shuffleButton
                Spacer()
                discarded
            }
            .padding(.horizontal)
        }
        .padding()
        .background(.orange.opacity(0.3))
        .foregroundStyle(.orange)
        .onAppear {
            animateNewlyDealtCards()
        }
    }
    
    var highlightedCardAccentColor: Color {
        !viewModel.chosenCards.countIsValid ? .yellow : viewModel.chosenCards.isSet ? .green : .red
    }
    
    @State private var dealt = [Card.ID]()
    
    private func isDealt(_ card: Card) -> Bool {
        dealt.contains(card.id)
    }
    
    private var visibleCards: some View {
        AspectVGrid(viewModel.visibleCards,aspectRatio: Constants.aspectRatio) { card in
            if isDealt(card) {
                CardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
                    .padding(Constants.spacing)
                    .accentColor(highlightedCardAccentColor)
                    .matchedGeometryEffect(id: card.id, in: discardingNamespace)
                    .onTapGesture {
                        withAnimation {
                            viewModel.choose(card)
                        }
                        animateNewlyDealtCards()
                    }
            } else {
                Color.clear
            }
        }
        .overlay {
            FlyingNumber(isGoodSet: viewModel.chosenCardsAreASet)
        }
    }
    
    private func animateNewlyDealtCards() {
        var delay: TimeInterval = 0
        for (idx, card) in viewModel.visibleCards.enumerated() {
            if !isDealt(card) {
                withAnimation(Constants.dealAnimation.delay(delay)) {
                    dealt.insert(card.id, at: idx)
                }
                delay += Constants.dealInterval
            }
        }
    }
    
    private func stackOfCards(_ cards: [Card], namespace: Namespace.ID, withCount: Bool = false) -> some View {
        ZStack {
            ForEach(cards) { card in
                CardView(card)
                    .accentColor(highlightedCardAccentColor)
                    .matchedGeometryEffect(id: card.id, in: namespace)
            }
        }
        .frame(
            width: Constants.deckAndDiscardWidth,
            height: Constants.deckAndDiscardWidth / Constants.aspectRatio
        )
        .overlay {
            if withCount {
                Text(cards.count, format: .number)
                    .foregroundColor(.accentColor)
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
    }
    
    // MARK: Buttons
    
    private var deck: some View {
        VStack {
            stackOfCards(viewModel.deck, namespace: dealingNamespace, withCount: true)
            Text("Deck")
        }
        .onTapGesture {
            if viewModel.visibleCards.isEmpty {
                withAnimation {
                    viewModel.deal()
                }
            } else {
                withAnimation {
                    viewModel.deal3()
                }
            }
            animateNewlyDealtCards()
        }
    }
    
    private var newGameButton: some View {
        Button("NG") {
            withAnimation {
                viewModel.newGame()
                dealt = []
            }
            animateNewlyDealtCards()
        }
        .font(.title2)
        .buttonStyle(.glass)
    }
    
    private var shuffleButton: some View {
        Button(action: {
            withAnimation {
                viewModel.shuffle()
            }
        }, label: {
            Image(systemName: "shuffle")
        })
        .font(.title2)
        .buttonStyle(.glass)
    }
    
    private var discarded: some View {
        VStack {
            stackOfCards(viewModel.discarded, namespace: discardingNamespace)
            Text("Discard")
        }
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let aspectRatio: CGFloat = 2/3
        static let spacing: CGFloat = 4
        static let dealAnimation: Animation = .easeInOut(duration: 0.2)
        static let dealInterval: TimeInterval = 0.15
        static let deckAndDiscardWidth: CGFloat = 70
    }
}

#Preview {
    ShapeSetGameView(viewModel: ShapeSetGame())
}
