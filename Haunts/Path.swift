//
//  Path.swift
//  Haunts
//
//  Created by Michael Oneppo on 4/1/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import UIKit
import Foundation

class Point : NSObject, NSCoding{
    
    var p: CGPoint
    var w: CGFloat
    
    init(p: CGPoint = CGPointZero, w: CGFloat = 0.0) {
        self.p = p
        self.w = w
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        let px = decoder.decodeObjectForKey("px") as CGFloat
        let py = decoder.decodeObjectForKey("py") as CGFloat
        self.p = CGPoint(x: px, y: py)
        self.w = decoder.decodeObjectForKey("w") as CGFloat
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.p.x, forKey: "px")
        coder.encodeObject(self.p.y, forKey: "py")
        coder.encodeObject(self.w, forKey: "w")
    }
    
}

class Path : NSObject, NSCoding {
    var pts : [Point] = []
    var color : UIColor = UIColor.blackColor()
    var timestamp : NSDate = NSDate()

    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.pts = decoder.decodeObjectForKey("pts") as [Point]
        self.color = decoder.decodeObjectForKey("color") as UIColor
        self.timestamp = decoder.decodeObjectForKey("timestamp") as NSDate
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.pts, forKey: "pts")
        coder.encodeObject(self.timestamp, forKey: "timestamp")
        coder.encodeObject(self.color, forKey: "color")
    }
}