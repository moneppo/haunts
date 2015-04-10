//
//  StaticView.swift
//  Haunts
//
//  Created by Michael Oneppo on 4/8/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import UIKit

class StaticView: UIImageView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        var imgs = [UIImage]()
        let bundle = NSBundle.mainBundle()
        if let path0 = bundle.pathForResource("static0", ofType:"png") {
            if let img0 = UIImage(contentsOfFile: path0) {
                imgs.append(img0)
            }
        }
        
        if let path1 = bundle.pathForResource("static1", ofType:"png") {
            if let img1 = UIImage(contentsOfFile: path1) {
                imgs.append(img1)
            }
        }
        
        if let path2 = bundle.pathForResource("static2", ofType:"png") {
            if let img2 = UIImage(contentsOfFile: path2) {
                imgs.append(img2)
            }
        }
        
        self.animationImages = imgs
        self.animationDuration = 0.2;
        self.animationRepeatCount = 0;
        self.startAnimating()
    }
    
    func fadeIn() {
        self.alpha = 0
        UIView.animateWithDuration(2.0) {
            self.alpha = 1
        }
    }
    
    func fadeOut() {
        self.alpha = 1
        UIView.animateWithDuration(2.0) {
            self.alpha = 0
        }
    }

}
