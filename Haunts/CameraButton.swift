//
//  CameraButton.swift
//  Haunts
//
//  Created by Michael Oneppo on 3/30/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import UIKit

@IBDesignable
class CameraButton: UIButton {
    
    override func drawRect(rect: CGRect) {
        var path = UIBezierPath(ovalInRect: rect)
        UIColor.purpleColor().setFill()
        path.fill()
    }
}

