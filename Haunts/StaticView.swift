//
//  StaticView.swift
//  Haunts
//
//  Created by Michael Oneppo on 4/8/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import UIKit
import PeerKit

class StaticView: UIImageView {
    var reconnectButton : UIButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let bundle = NSBundle.mainBundle()

        reconnectButton = UIButton(frame: CGRect(x: 0,y: 0,width: 128, height: 128))
        reconnectButton.center = self.center
        reconnectButton.autoresizingMask =
            UIViewAutoresizing.FlexibleBottomMargin |
            UIViewAutoresizing.FlexibleTopMargin |
            UIViewAutoresizing.FlexibleLeftMargin |
            UIViewAutoresizing.FlexibleRightMargin
            
        self.addSubview(reconnectButton)
        
        reconnectButton.addTarget(self, action:"reconnect:" , forControlEvents: UIControlEvents.TouchUpInside)
        
        if let connectPath = bundle.pathForResource("connect", ofType:"png") {
            if let connectImg = UIImage(contentsOfFile: connectPath) {
                reconnectButton.setImage(connectImg, forState: UIControlState.Normal)
            }
        }
        
        var imgs = [UIImage]()
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
    
    func spin(view : UIView, duration: CGFloat, rotations: CGFloat, repeat: Float)
    {
        let rotationAnimation =  CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI) * 2.0 * rotations * duration
        rotationAnimation.duration = CFTimeInterval(duration)
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = repeat
    
        view.layer.addAnimation(rotationAnimation, forKey:"rotationAnimation")
    }
    
    @objc func reconnect(target: UIButton) {
        spin(reconnectButton, duration: 5.0, rotations: 1.0, repeat: 0)
        
        PeerKit.stopTransceiving()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            PeerKit.transceive("com-moneppo-Wax")
        }
    }
    
    func fadeOut() {
        self.alpha = 1
        UIView.animateWithDuration(2.0) {
            self.alpha = 0
        }
    }

}
