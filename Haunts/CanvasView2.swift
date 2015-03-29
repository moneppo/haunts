//
//  CanvasView2.swift
//
//  Created by Michael Oneppo on 3/28/15.

import UIKit

func +(l:CGPoint, r:CGPoint) -> CGPoint {
    return CGPoint(x: l.x + r.x, y: l.y + r.y)
}

func -(l:CGPoint, r:CGPoint) -> CGPoint {
    return CGPoint(x: l.x - r.x, y: l.y - r.y)
}

func *(l:CGPoint, r:CGFloat) -> CGPoint {
    return CGPoint(x: l.x * r, y: l.y * r)
}

func /(l:CGPoint, r:CGFloat) -> CGPoint {
    return CGPoint(x: l.x / r, y: l.y / r)
}

func mag(v:CGPoint) -> CGFloat {
    return sqrt(v.x * v.x + v.y * v.y)
}


func mag2(v:CGPoint) -> CGFloat {
    return v.x * v.x + v.y * v.y
}

func normalize(v:CGPoint) -> CGPoint {
    let l = mag(v)
    return v / l
}

func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint
{
    return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
}

func clamp(f: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    if f > max {
        return max
    }
    
    if f < min {
        return min
    }
    
    return f
}

class CanvasView2: UIView {
    
    let MIN_DIST = CGFloat(7.0)
    let MIN_THICKNESS = CGFloat(3)
    let MAX_THICKNESS = CGFloat(7)
    let THICK_RATE = CGFloat(10.0)

    override func drawRect(rect: CGRect) {
        UIColor.blackColor().setFill()
        for p in paths {
            p.fill()
        }
        
       let p = generateStroke()
       p.fill()
    }
    
    var paths : [UIBezierPath] = []
    var points: [CGPoint] = []
    var pressures : [CGFloat] = []
    var previousPoint : CGPoint = CGPoint.zeroPoint
    
    func generateStroke() -> UIBezierPath {
        var path = UIBezierPath()
        
        if points.count == 0 {
            return path
        }
        
        path.moveToPoint(points[0])
        
        // Start forward
        for var i = 1; i < points.count; i++ {
            let p0 = points[i-1]
            let p1 = points[i]
            let pressure0 = pressures[i-1] * THICK_RATE
            let pressure1 = pressures[i] * THICK_RATE
            
            let direction = normalize(p0 - p1)
            let normal = CGPoint(x: direction.y, y: -direction.x)
            let a = p1 + normal * pressure1
            let b = p0 + normal * pressure0
            
            let midpoint = midPoint(a, b)
            
            path.addQuadCurveToPoint(midpoint, controlPoint: b)
        }
        
        path.addLineToPoint(points[points.count-1])
        
        // Then go back. Something in here is broken
        for var i = points.count-1; i > 0; i-- {
            let p0 = points[i]
            let p1 = points[i-1]
            let pressure0 = clamp(pressures[i-1] * THICK_RATE, MIN_THICKNESS, MAX_THICKNESS)
            let pressure1 = clamp(pressures[i] * THICK_RATE, MIN_THICKNESS, MAX_THICKNESS)
            
            let direction = normalize(p0 - p1)
            let normal = CGPoint(x: direction.y, y: -direction.x)
            let a = p1 + normal * pressure1
            let b = p0 + normal * pressure0
            
            let midpoint = midPoint(a, b)
            
            path.addQuadCurveToPoint(midpoint, controlPoint: b)
        }
        
        return path
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if let touch = touches.anyObject() as UITouch? {
            let currentPoint = touch.locationInView(self)
            
            paths.append(UIBezierPath())
            paths[paths.count-1].moveToPoint(currentPoint)
            previousPoint = currentPoint
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if let touch = touches.anyObject() as UITouch? {
            let currentPoint = touch.locationInView(self)
            
            if (mag2(currentPoint - previousPoint) < MIN_DIST) {
                return
            }
            
            points.append(currentPoint)
            let velocity = mag(currentPoint - previousPoint) / MIN_DIST
            pressures.append((touch.majorRadius + 0.1) * velocity)

        /*  let direction = normalize(previousPoint - currentPoint)
            let normal = CGPoint(x: direction.y, y: -direction.x)
            touch.majorRadius
            
            let a = currentPoint + normal * 20//touch.majorRadius
            let b = previousPoint + normal * 20//touch.majorRadius
            
            let midpoint = midPoint(a, b)
            
            
            paths[paths.count-1].addQuadCurveToPoint(midpoint, controlPoint: b)*/
            
            previousPoint = currentPoint
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        paths.append(generateStroke())
        points = []
        pressures = []
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.touchesEnded(touches, withEvent: event)
    }
}
