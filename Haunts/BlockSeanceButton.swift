//
//  BlockSeanceButton.swift
//  Haunts
//
//  Created by Michael Oneppo on 3/25/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import UIKit

@IBDesignable
class BlockSeanceButton: UIButton {
    override func drawRect(rect: CGRect) {
        var path = UIBezierPath(ovalInRect: rect)
        UIColor.yellowColor().setFill()
        path.fill()
    }
}
