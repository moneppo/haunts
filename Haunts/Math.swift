//
//  Math.swift
//  Haunts
//
//  Created by Michael Oneppo on 3/29/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import Foundation
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

func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
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
