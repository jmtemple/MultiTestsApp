//
//  MemoryGame.swift
//  MultiTestsApp
//
//  Created by mikel kota
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIImage
import UIKit.UICollectionViewCell

//Delegate protocol: functions that delegate is responsible for.
protocol MemoryGame2Delegate {
    func memoryGame2DidStart(_ game: MemoryGame2)
    func memoryGame2DidEnd(_ game: MemoryGame2, elapsedTime: TimeInterval)
    func memoryGame2(_ game: MemoryGame2, showCards cards: [Card])
    func memoryGame2(_ game: MemoryGame2, hideCards cards: [Card])
}

//Delegating Class, handles the cards. 
class MemoryGame2 {
    
    static var defaultCardImages:[UIImage] = [
        UIImage(named: "Card1")!, UIImage(named: "Card2")!, UIImage(named: "Card3")!,
        UIImage(named: "Card4")!, UIImage(named: "Card5")!, UIImage(named: "Card6")! ]
    
    //Set delegate, cards, and isPlaying to false because game hasnt started. 
    var cards:[Card] = [Card]()
    var delegate: MemoryGameDelegate?
    var isPlaying: Bool = false
    
    fileprivate var cardsShown:[Card] = [Card]()
    fileprivate var startTime:Date?
    
    var numberOfCards:Int { get { return cards.count } }
    
    //Timer
    var elapsedTime:TimeInterval { get {
        guard startTime != nil else { return -1}
        //NSLog("time: \(Date().timeIntervalSince(startTime!))")
        return Date().timeIntervalSince(startTime!)
        }
    }
    
    func newGame(_ cardsData:[UIImage]) {
        cards = randomCards(cardsData)
        startTime = Date.init()
        isPlaying = true
        //Calling delegate method.
        delegate?.memoryGameDidStart(self)
    }
    
    //Reset.
    func stopGame() {
        cards.removeAll()
        cardsShown.removeAll()
        startTime = nil
        isPlaying = false
    }
    
    //This function checks to see if the cards match.
    func didSelectCard(_ card: Card?) {
        guard let card = card else {return}
        //Calling delegate method.
        delegate?.memoryGame(self, showCards: [card])
        if unpairedCardShown() {
            let unpaired = unpairedCard()!
            if card.equals(unpaired) {
                cardsShown.append(card)
            } else {
                let unpairedCard = cardsShown.removeLast()
                let delayTime = DispatchTime.now() + Double(Int64(1*Double(NSEC_PER_SEC)))/Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline:delayTime) {
                    //Calling delegate method.
                    self.delegate?.memoryGame(self, hideCards:[card, unpairedCard])
                }
            }
        } else {
            cardsShown.append(card)
        }
        //Tests if all cards are matched.
        if cardsShown.count == cards.count {
            finishGame()
        }
    }
    
    //Checks to see if there is 2 cards.
    fileprivate func unpairedCardShown() -> Bool {
        return cardsShown.count % 2 != 0
    }
    
    //First card picked, called unpairedCard.
    fileprivate func unpairedCard() -> Card? {
        let unpairedCard = cardsShown.last
        return unpairedCard
    }
    
    //Game over, isPlaying set to false. and delegate method called for memoryGameDidEnd.
    fileprivate func finishGame() {
        isPlaying = false
        //Calling delegate method. 
        delegate?.memoryGameDidEnd(self, elapsedTime: elapsedTime)
    }
    
    //Randomizes cards.
    fileprivate func randomCards(_ cardsData:[UIImage]) -> [Card] {
        var cards = [Card]()
        for i in 0...cardsData.count-1 {
            let card = Card.init(image: cardsData[i])
            cards.append(contentsOf: [card, Card.init(card: card)])
        }
        for _ in 1...cards.count {
            cards.sort { (_,_) in arc4random() < arc4random() }
        }
        return cards
    }
    
    func cardAtIndex(_ index: Int) -> Card? {
        if cards.count > index { return cards[index] }
        else { return nil }
    }
    
    func indexForCard(_ card: Card) -> Int? {
        for index in 0...cards.count-1 {
            if card === cards[index] { return index }
        }
        return nil
    }
    
}
