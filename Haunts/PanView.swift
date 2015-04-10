//
//  CanvasView.swift
//
//  Created by Michael Oneppo on 3/28/15.

import UIKit
import PeerKit

class PanView: UIImageView, UIGestureRecognizerDelegate {
    let hauntSize = CGFloat(3072)
    
    var panStart : CGPoint = CGPoint.zeroPoint
    var minZoom : CGFloat = CGFloat(0.0)
    var panBounds : CGRect = CGRect.infiniteRect
    
    var viewRect : CGRect = CGRect.zeroRect
    
    var pinchRecognizer : UIPinchGestureRecognizer!
    var panRecognizer : UIPanGestureRecognizer!
    
    required init(coder : NSCoder){
        super.init(coder: coder)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        pinchRecognizer = UIPinchGestureRecognizer()
        pinchRecognizer.addTarget( self, action: "handlePinch:")
        panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        
        self.addGestureRecognizer(panRecognizer)
        self.addGestureRecognizer(pinchRecognizer)
        panRecognizer.delegate = self
        pinchRecognizer.delegate = self
        self.userInteractionEnabled = true
        self.multipleTouchEnabled = true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
    
    @objc func handlePan(rec : UIPanGestureRecognizer) {
        switch(rec.state) {
        case UIGestureRecognizerState.Began:
            self.panBegan(rec.locationInView(self), numTouches: rec.numberOfTouches())
            rec.setTranslation(CGPoint.zeroPoint, inView: self)
            break
        case UIGestureRecognizerState.Changed:
            self.panMoved(rec.locationInView(self), numTouches: rec.numberOfTouches())
            rec.setTranslation(CGPoint.zeroPoint, inView: self)
            break
        default:
            break
        }
    }
    
    @objc func handlePinch(rec : UIPinchGestureRecognizer) {
        self.pinchMoved(rec.scale)
        rec.scale = 1.0
    }

    
    func updateViewRect() {
        let minScaleX = self.superview!.bounds.width / hauntSize
        let minScaleY = self.superview!.bounds.height / hauntSize
        
        let scaleX = self.superview!.bounds.width / viewRect.width
        let scaleY = self.superview!.bounds.height / viewRect.height
        
        if viewRect.origin.x > hauntSize - viewRect.width / 2 {
            viewRect.origin.x = hauntSize - viewRect.width / 2
        }
        
        if viewRect.origin.x < viewRect.width / 2 {
            viewRect.origin.x = viewRect.width / 2
        }
        
        if viewRect.origin.y > hauntSize  - viewRect.height / 2 {
            viewRect.origin.y = hauntSize  - viewRect.height / 2
        }
        
        if viewRect.origin.y < viewRect.height / 2 {
            viewRect.origin.y = viewRect.height / 2
        }
        
        
        if (scaleX > 1.0 || scaleY > 1.0) {
            viewRect.size.width = self.superview!.bounds.width
            viewRect.size.height = self.superview!.bounds.height
        }
        
        if scaleX < minScaleX {
            viewRect.size.width = self.superview!.bounds.width / minScaleX
            viewRect.size.height = self.superview!.bounds.height / minScaleX
        }
        
        if scaleY < minScaleY {
            viewRect.size.width = self.superview!.bounds.width / minScaleY
            viewRect.size.height = self.superview!.bounds.height / minScaleY
        }
        
        let scale = self.superview!.bounds.height / viewRect.height
        
        // I actually treat the origin as the center
        self.transform = CGAffineTransformMakeScale(scale, scale)
        self.transform = CGAffineTransformTranslate(self.transform,
            viewRect.origin.x - hauntSize / 2, viewRect.origin.y - hauntSize / 2)
    }
    
    func panBegan(location : CGPoint, numTouches : Int) {
        panStart = location
    }
    
    func panMoved(location : CGPoint, numTouches : Int) {
        viewRect.origin = viewRect.origin + location - panStart
        updateViewRect()
    }
    
    func pinchMoved(scale : CGFloat) {
        self.viewRect = CGRect(x: self.viewRect.origin.x,
            y: self.viewRect.origin.y,
            width: self.viewRect.width / scale,
            height: self.viewRect.height / scale)
        updateViewRect()
    }
}