//
//  ShapeSetGameView.swift
//  SetGame
//
//  Created by Gleb on 25.09.2025.
//

import SwiftUI

struct ShapeSetGameView: View {
    @ObservedObject var viewModel: ShapeSetGame
    
    typealias Card = SetGame.Card
    @Namespace private var dealingNamespace
    @Namespace private var discardingNamespace
    
    var body: some View {
        VStack {
            visibleCards
                .overlay {
                    AnimationForNewSetSelection(isGoodSet: viewModel.chosenCardsAreASet)
                }
            VStack {
                HStack(alignment: .bottom/*, spacing: Constants.controlsSpacing*/) {
                    deck
                    VStack {
                        newGameButton
                        shuffleButton
                    }
                    deal3MoreCardsButton
                    discarded
                }
                .padding(.horizontal)
//                .glassEffect(.clear)
            }
        }
        .padding()
        .onAppear {
            animateNewlyDealtCards()
        }
    }
    
    var highlightedCardAccentColor: Color {
        !viewModel.chosenCards.countIsValid ? .yellow : viewModel.chosenCards.isSet ? .green : .red
    }
    
    private var deck: some View {
        VStack {
            stackOfCards(viewModel.deck, namespace: dealingNamespace, withCount: true)
            textBelowStackOfCards("Deck")
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
    
    @State private var dealt = [Card.ID]()
    
    private func isDealt(_ card: Card) -> Bool {
        dealt.contains(card.id)
    }
    
    private var visibleCards: some View {
        AspectVGrid(
            Array(viewModel.visibleCards),
            aspectRatio: Constants.aspectRatio
        ) { card in
            if isDealt(card) {
                CardView(card)
                    .padding(Constants.paddingAroundCards)
                    .accentColor(highlightedCardAccentColor)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
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
    
    private var discarded: some View {
        VStack {
            stackOfCards(viewModel.discarded, namespace: discardingNamespace)
            textBelowStackOfCards("Discard")
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
    
    func textBelowStackOfCards(_ text: String) -> some View {
        Text(text).font(.headline)
    }
    
    // MARK: Buttons
    
    private var newGameButton: some View {
        Button("NG") {
            withAnimation {
                viewModel.newGame()
                dealt = []
            }
            animateNewlyDealtCards()
        }
        .font(.title2)
        .buttonStyle(.borderedProminent)
        .glassEffect()
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
        .buttonStyle(.bordered)
    }
    
    private var deal3MoreCardsButton: some View {
        Button("Deal 3 more cards") {
            withAnimation {
                viewModel.deal3()
            }
            animateNewlyDealtCards()
        }
        .font(.title2)
        .buttonStyle(.bordered)
        .disabled(viewModel.deck.isEmpty)
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let aspectRatio: CGFloat = 2/3
        static let paddingAroundCards: CGFloat = 4
        static let deckAndDiscardWidth: CGFloat = 60
        static let dealInterval: TimeInterval = 0.15
        static let dealAnimation: Animation = .easeInOut(duration: 0.5)
    }
}

#Preview {
    ShapeSetGameView(viewModel: ShapeSetGame())
}
