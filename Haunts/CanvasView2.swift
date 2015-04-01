//
//  CanvasView2.swift
//
//  Created by Michael Oneppo on 3/28/15.

import UIKit
import PeerKit

struct Point {
    var p: CGPoint
    var w: CGFloat
}

class Path {
    var pts : [Point] = []
    var color : UIColor = UIColor.blackColor()
}

class CanvasView2: UIView {
    
    let hauntSize = CGFloat(3072)
    
    let MIN_DIST = CGFloat(7.0)
    let MIN_THICKNESS = CGFloat(1)
    let MAX_THICKNESS = CGFloat(7)
    let THICK_RATE = CGFloat(0.5)
    
    var paths : [UIBezierPath] = []
    var currentPath: Path = Path()
    var panStart : CGPoint = CGPoint.zeroPoint
    var previousPoint : CGPoint = CGPoint.zeroPoint
    
    var minZoom : CGFloat = CGFloat(0.0)
    var panBounds : CGRect = CGRect.infiniteRect
    
    var viewRect : CGRect = CGRect.zeroRect
    
    override func drawRect(rect: CGRect) {
        UIColor.blackColor().setFill()
        for p in paths {
            p.fill()
        }
        
        let p = generateStroke(currentPath)
        p.fill()
    }
    
    func generateStroke(p : Path) -> UIBezierPath {
        var path = UIBezierPath()
        
        if p.pts.count == 0 {
            return path
        }
        
        path.moveToPoint(p.pts[0].p)
        
        // Start forward
        for var i = 1; i < p.pts.count; i++ {
            let p0 = p.pts[i-1].p
            let p1 = p.pts[i].p
            let pressure0 = clamp(p.pts[i-1].w * THICK_RATE, MIN_THICKNESS, MAX_THICKNESS)
            let pressure1 = clamp(p.pts[i].w * THICK_RATE, MIN_THICKNESS, MAX_THICKNESS)
            
            let direction = normalize(p0 - p1)
            let normal = CGPoint(x: direction.y, y: -direction.x)
            let a = p1 + normal * pressure1
            let b = p0 + normal * pressure0
            
            let midpoint = midPoint(a, b)
            
            path.addQuadCurveToPoint(midpoint, controlPoint: b)
        }
        
        path.addLineToPoint(p.pts[p.pts.count-1].p)
        
        // Then go back
        for var i = p.pts.count-1; i > 0; i-- {
            let p0 = p.pts[i].p
            let p1 = p.pts[i-1].p
            let pressure0 = clamp(p.pts[i-1].w * THICK_RATE, MIN_THICKNESS, MAX_THICKNESS)
            let pressure1 = clamp(p.pts[i].w * THICK_RATE, MIN_THICKNESS, MAX_THICKNESS)
            
            let direction = normalize(p0 - p1)
            let normal = CGPoint(x: direction.y, y: -direction.x)
            let a = p1 + normal * pressure1
            let b = p0 + normal * pressure0
            
            let midpoint = midPoint(a, b)
            
            path.addQuadCurveToPoint(midpoint, controlPoint: b)
        }
        
        return path
    }
    
    func placeImage(img: UIImage, at: CGPoint) {
    }
    
    func resize(modelExtent: CGSize, modelCenter: CGPoint) {
        let origin = CGPoint(x: modelCenter.x /*- modelExtent.width / 2*/, y: modelCenter.y /*- modelExtent.height / 2*/)
        viewRect = CGRect(x: origin.x, y: origin.y, width: modelExtent.width, height: modelExtent.height);
    }
    
    func zoomToExtents() {
        if self.superview!.bounds.width > self.superview!.bounds.height {
            let ratio = self.superview!.bounds.width / self.superview!.bounds.height
            resize(CGSize(width: hauntSize, height: hauntSize  * ratio), modelCenter: CGPoint(x: 0,y: 0))
        } else {
            let ratio = self.superview!.bounds.height / self.superview!.bounds.width
            resize(CGSize(width: hauntSize  * ratio, height: hauntSize ), modelCenter: CGPoint(x: 0,y: 0))
        }
        
    }
    
    func placePath(p: Path) {
        paths.append(generateStroke(p))
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
    
    // TODO FOR TEST:
    // New join of two users creates haunt, otherwise shows nothing = TEST
    // Additional user asks for haunt, gets back pixels = TEST
    // Enable/disable haunt editing
    // Losing all connections shows nothing on the screen
    // Save haunt
    // Look at old haunts
    
    // TODO LATER:
    // Screen rotation
    
    func panBegan(location : CGPoint, numTouches : Int) {
        if numTouches == 1 {
            paths.append(UIBezierPath())
            paths[paths.count-1].moveToPoint(location)
            previousPoint = location
        } else {
            panStart = location
        }
    }
    
    func panMoved(location : CGPoint, numTouches : Int) {
        if numTouches == 1 {
            if (mag2(location - previousPoint) < MIN_DIST) {
                return
            }
        
            let velocity = mag(location - previousPoint) / MIN_DIST
            let p = Point(p: location, w: velocity)
            currentPath.pts.append(p)
            previousPoint = location
            self.setNeedsDisplay()
        } else {
            viewRect.origin = viewRect.origin + location - panStart
            updateViewRect()
        }
    }
    
    func panEnded(numTouches : Int) {
        if numTouches < 2 {
            paths.append(generateStroke(currentPath))
            PeerKit.sendEvent("path", object: currentPath)
            currentPath = Path()
        }
    }
    
    func pinchMoved(scale : CGFloat) {
        self.viewRect = CGRect(x: self.viewRect.origin.x,
                               y: self.viewRect.origin.y,
                                width: self.viewRect.width / scale,
                                height: self.viewRect.height / scale)
        updateViewRect()
    }
 }
