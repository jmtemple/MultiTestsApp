//
//  CardCVC.swift
//  MultiTestsApp
//
//  Created by mikel kota
//  Copyright © 2016 NDMobileCompLab. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIImage
import UIKit.UICollectionViewCell

class CardCVC : UICollectionViewCell {
    
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    fileprivate(set) var shown: Bool = false
    
    var card : Card? {
        didSet {
            guard let card = card else {return}
            frontImageView.image = card.image
        }
    }
    
    //Used throughout GameController for each of the protocol methods.
    func showCard(_ show: Bool, animated: Bool) {
        frontImageView.isHidden = false
        backImageView.isHidden = false
        shown = show
        
        //There are two cards so you have to look at the cases where one card is already picked and another will be picked or just the first one is picked. 
        if animated { //If animated true.
            if show { //If show true, backImageView is flipped to frontImageView
                UIView.transition(from: backImageView, to: frontImageView, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: {(finished: Bool) -> () in})
            } else { //If show false, frontImageView is flipped to backImageView.
                UIView.transition(from: frontImageView, to: backImageView, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: {(finished: Bool) -> () in})
            }
        } else { //If animated false.
            if show { //If show true, flip first card.
                bringSubview(toFront: frontImageView)
                backImageView.isHidden = true
            } else { //If show false, nothing showing yet.
                bringSubview(toFront: backImageView)
                frontImageView.isHidden = true
            }
        }
    }
    
}


class Card: CustomStringConvertible {
    
    var id: UUID = UUID.init()
    var shown: Bool = false
    var image: UIImage
    
    init(image:UIImage) {
        self.image = image
    }
    
    init(card:Card) {
        self.id = (card.id as NSUUID).copy() as! UUID
        self.shown = card.shown
        self.image = card.image.copy() as! UIImage
    }
    
    var description: String {
        return "\(id.uuidString)"
    }
    
    func equals(_ card: Card) -> Bool {
        return (card.id == id)
    }
}
