//
//  DrawingToolbarViewController.swift
//  MultiTestsApp
//
//  Created by Katie Kuenster on 2/13/17.
//  Copyright © 2017 NDMobileCompLab. All rights reserved.
//
/*
import UIKit

class DrawingToolbarViewController: UIViewController, UIGestureRecognizerDelegate, ListensToJotSuggestions, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate {
    
    //contains the whole toolbar, move this boy up and down
    @IBOutlet weak var containerView: UIView!
    
    //this is the container for the toolbar, and expands on smaller screens
    @IBOutlet weak var toolbarContainerView: UIView!
    
    //this contains all the content for the toolbar, add views here
    @IBOutlet weak var toolbarContentView: UIView!
    
    
    
    //change this constraint to move the toolbar up and down
    @IBOutlet weak var containerTopOffset: NSLayoutConstraint!
    
    //update this to include the width of all brushes
    
    @IBOutlet weak var jotSettingsView: UIView!
    
    
    let acceptableFingerGestureTypes = [AdonitTouchIdentificationType.unknown, AdonitTouchIdentificationType.notDevice]
    var drawingView: TraceShapeViewController!
    
    fileprivate let cornerRadius:CGFloat = 4;
    
    fileprivate(set) var presentationState:ToolbarPresentationState = .presenting
    
    fileprivate var offscreenPanStartState:ToolbarPresentationState!
    fileprivate var lastOffscreenPanPosition:CGPoint!
    fileprivate var presentedPositionY:CGFloat!
    fileprivate var hiddenPositionY:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentedPositionY = -cornerRadius
        hiddenPositionY = presentedPositionY - containerView.frame.size.width + 12
        
        toolbarContainerView.layer.cornerRadius = cornerRadius
        toolbarContainerView.clipsToBounds = true
        
        animateToolbarTo(presentedPositionY, animate: false)
        
        let statusViewController = UIStoryboard.instantiateInitialJotViewController();
        statusViewController?.view.frame = jotSettingsView.bounds;
        jotSettingsView.backgroundColor = UIColor.clear
        jotSettingsView.addSubview((statusViewController?.view)!);
        addChildViewController(statusViewController!);
        
        
        JotStylusManager.sharedInstance().register(self.view)
        
    }
    
    
    func presentToolbar() {
        //animate to presented
    }
    
    func hideToolbar() {
        //animage to hidden
    }
    
    fileprivate func animateToolbarTo(_ posY:CGFloat, animate:Bool = true) {
        containerTopOffset.constant = posY
        
        if animate {
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                self.containerView.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.containerView.layoutIfNeeded()
        }
    }
    
    func jotSuggestsToDisableGestures() {
    }
    
    func jotSuggestsToEnableGestures() {
    }
    
    
    
    func refreshColorPalette() {
        
    }
    
    func deselectAll(_ colors:Bool = true, brushes:Bool = true) {
        
    }
    
    //
    // TODO: Deselect everything then select the correct things if necessary
    //
    
    func checkEraser() {
        deselectAll()
        
    }
    
    func checkColors() {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return false;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
 */

