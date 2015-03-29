//
//  CanvasView.swift
//  Haunts
//
//  Created by Michael Oneppo on 3/27/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//
/*
import UIKit

struct LineSegment
{
    var firstPoint : CGPoint
    var secondPoint : CGPoint
}


func len_sq(p1 : CGPoint, p2 : CGPoint) -> Float
{
    let dx = p2.x - p1.x
    let dy = p2.y - p1.y
    return Float(dx * dx) + Float(dy * dy)
}

func clamp(value : Float, lower : Float, higher : Float) -> Float
{
    if (value < lower) {
        return lower
    }
    
    if (value > higher) {
        return higher
    }
    
    return value
}

let CAPACITY  = 100
let FF = 0.2 as Float
let LOWER  = 0.01 as Float
let UPPER = 1.0 as Float

class CanvasView: UIView {

    var incrementalImage : UIImage!
    var pts = [CGPoint?](count: 5, repeatedValue: nil)
    var ctr : Int = 0
    var pointsBuffer = [CGPoint?](count: CAPACITY, repeatedValue: nil)
    var bufIdx : Int = 0
    var isFirstTouchPoint : Bool = false
    
    var lastSegmentOfPrev = LineSegment(firstPoint: CGPoint(x:0, y:0), secondPoint: CGPoint(x:0, y:0))
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        ctr = 0;
        bufIdx = 0;
        if let touch = touches.anyObject() as UITouch? {
            pts[0] = touch.locationInView(self)
        }
        isFirstTouchPoint = true;
    }
    
    override func touchesMoved(touches: NSSet, withEvent event : UIEvent) {
        if let touch = touches.anyObject() as UITouch? {
            let p = touch.locationInView(self)

            ctr++
            pts[ctr] = p
            if (ctr == 4) {
                pts[3] = CGPoint(x: (pts[2]!.x + pts[4]!.x)/2.0, y: (pts[2]!.y + pts[4]!.y)/2.0)
        
                for i in 0...4 {
                    pointsBuffer[bufIdx + i] = pts[i];
                }
        
                bufIdx += 4
        
                let bounds = self.bounds
        
              //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let offsetPath = UIBezierPath()
                    if (self.bufIdx == 0) {
                        return
                    }
        
                    var ls = [LineSegment?](count: 4, repeatedValue: nil)
                    for var i = 0; i < self.bufIdx; i += 4 {
                        if (self.isFirstTouchPoint) {
                            ls[0] = LineSegment(firstPoint: self.pointsBuffer[0]!, secondPoint: self.pointsBuffer[0]!)
                            offsetPath.moveToPoint(ls[0]!.firstPoint)
                            self.isFirstTouchPoint = false
                        } else {
                            ls[0] = self.lastSegmentOfPrev
                            let frac1 = FF/clamp(len_sq(self.pointsBuffer[i]!,   self.pointsBuffer[i+1]!), LOWER, UPPER)
                            let frac2 = FF/clamp(len_sq(self.pointsBuffer[i+1]!, self.pointsBuffer[i+2]!), LOWER, UPPER);
                            let frac3 = FF/clamp(len_sq(self.pointsBuffer[i+2]!, self.pointsBuffer[i+3]!), LOWER, UPPER)
                            
                            ls[1] = self.lineSegmentPerpendicularTo(LineSegment(firstPoint: self.pointsBuffer[i]!, secondPoint: self.pointsBuffer[i+1]!), ofRelativeLength: frac1)
                            
                            ls[2] = self.lineSegmentPerpendicularTo(LineSegment(firstPoint: self.pointsBuffer[i+1]!, secondPoint: self.pointsBuffer[i+2]!), ofRelativeLength: frac2)
                            
                            ls[3] = self.lineSegmentPerpendicularTo(LineSegment(firstPoint: self.pointsBuffer[i+2]!, secondPoint: self.pointsBuffer[i+3]!), ofRelativeLength: frac3)
        
                            offsetPath.moveToPoint(ls[0]!.firstPoint)
                            offsetPath.addCurveToPoint(ls[3]!.firstPoint, controlPoint1: ls[1]!.firstPoint,
                                controlPoint2: ls[2]!.firstPoint)
                            
                            offsetPath.addLineToPoint(ls[3]!.secondPoint)
                            offsetPath.addCurveToPoint(ls[0]!.secondPoint, controlPoint1: ls[2]!.secondPoint,
                                controlPoint2: ls[1]!.secondPoint)
                            offsetPath.closePath()
        
                            self.lastSegmentOfPrev = ls[3]!
                        }
                        
                   //     UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        
                      //  if (self.incrementalImage == nil) {
                       //     let rectpath = UIBezierPath(rect: self.bounds)
                       //     UIColor.whiteColor().setFill()
                       //     rectpath.fill()
                       //     self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
                       // }
                        
                       // self.incrementalImage.drawAtPoint(CGPointZero)
                        UIColor.blackColor().setStroke()
                        UIColor.blackColor().setFill()
                        offsetPath.stroke()
                        offsetPath.fill()
                        
                     //   UIGraphicsEndImageContext()
                        
                        offsetPath.removeAllPoints()
                     //   dispatch_async(dispatch_get_main_queue()) {
                            self.bufIdx = 0
                            self.setNeedsDisplay()
                      //  }
                    }
               // }
                
                self.pts[0] = self.pts[3]
                self.pts[1] = self.pts[4]
                self.ctr = 1
            }
        }
    }
    
    override func drawRect( rect: CGRect)
    {
        if (self.incrementalImage != nil) {
            self.incrementalImage.drawInRect(rect)
        }
    }
    
        
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.touchesEnded(touches, withEvent: event)
    }
    
    func lineSegmentPerpendicularTo(pp : LineSegment, ofRelativeLength fraction : Float) -> LineSegment
    {
        let x0 = pp.firstPoint.x
        let y0 = pp.firstPoint.y
        let x1 = pp.secondPoint.x
        let y1 = pp.secondPoint.y
        let dx = x1 - x0
        let dy = y1 - y0
        let xa = Float(x1) + fraction / Float(2.0 * dy)
        let ya = Float(y1) - fraction / Float(2.0 * dx)
        let xb = Float(x1) - fraction / Float(2.0 * dy)
        let yb = Float(y1) + fraction / Float(2.0 * dx)
    
        return LineSegment(firstPoint: CGPoint(x: CGFloat(xa), y: CGFloat(ya)),
                           secondPoint: CGPoint(x: CGFloat(xb), y: CGFloat(yb)))
    }
    

}*/
