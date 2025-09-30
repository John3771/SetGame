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
                HStack(alignment: .bottom, spacing: Constants.controlsSpacing) {
                    deck
                    VStack {
                        newGameButton
                        shuffleButton
                    }
                    deal3MoreCardsButton
                    discarded
                }
                .padding(.horizontal)
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
        controlTile(label: "Deck") {
            stackOfCards(viewModel.deck, namespace: dealingNamespace, withCount: true)
        }
        .contentShape(Rectangle())
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
        controlTile(label: "Discard") {
            stackOfCards(viewModel.discarded, namespace: discardingNamespace)
        }
    }
    
    private var actionButton: some View {
        controlTile(padding: Constants.controlContentPadding) {
            VStack(spacing: Constants.controlInnerSpacing) {
                newGameButton
                shuffleButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var deal3MoreCardsTile: some View {
        controlTile(padding: Constants.controlContentPadding) {
            deal3MoreCardsButton
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
            width: Constants.controlSize.width,
            height: Constants.controlSize.height
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
        .frame(maxWidth: .infinity)
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
        .frame(maxWidth: .infinity)
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
        .frame(minWidth: .infinity, minHeight: .infinity)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.5)
    }
    
    private func controlTile<Content: View>(label: String? = nil, padding: CGFloat = 0, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: Constants.controlLabelSpacing) {
            ZStack {
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(padding)
            }
            .frame(width: Constants.controlSize.width, height: Constants.controlSize.height)
            
            if let label {
                textBelowStackOfCards(label)
            }
        }
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let aspectRatio: CGFloat = 2/3
        static let paddingAroundCards: CGFloat = 4
        static let deckAndDiscardWidth: CGFloat = 60
        static let controlSize = CGSize(width: deckAndDiscardWidth, height: deckAndDiscardWidth / aspectRatio)
        static let controlLabelSpacing: CGFloat = 8
        static let controlInnerSpacing: CGFloat = 8
        static let controlsSpacing: CGFloat = 16
        static let controlContentPadding: CGFloat = 12
        static let dealInterval: TimeInterval = 0.15
        static let dealAnimation: Animation = .easeInOut(duration: 0.5)
    }
}

#Preview {
    ShapeSetGameView(viewModel: ShapeSetGame())
}
