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
    
    func placeImage(img: UIImage) {
    }
    
    func placePath(p: Path) {
        paths.append(generateStroke(p))
    }
    
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
            self.center = self.center + location - panStart
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
        let newScale = CGAffineTransformScale(self.transform, scale, scale)
        if (newScale.a <= 1.0 && newScale.a >= self.minZoom) {
            self.transform = newScale
        }
    }
 }
