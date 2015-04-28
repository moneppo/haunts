//
//  Util.swift
//  Haunts
//
//  Created by Michael Oneppo on 3/29/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

func imageToTempURL(img : UIImage) -> String {
    let imageToSave : NSData = UIImagePNGRepresentation(img)
    let path = NSTemporaryDirectory() + NSUUID().UUIDString + ".png"
    saveImage(img, NSURL(string: path)!, nil)
    return path
}

func saveImage(img: UIImage, url: NSURL, thumbURL: NSURL?) {
    let imageToSave : NSData = UIImagePNGRepresentation(img)
    
    if !imageToSave.writeToFile(url.path!, atomically: true) {
        println("Couldn't save to " + url.path!)
    } else {
        println("Saved haunt to " + url.path!)
        
        if let thumbPath = thumbURL?.path {
            if let imageSource = CGImageSourceCreateWithURL(url, nil) {
                let options : [NSObject:AnyObject] = [
                    kCGImageSourceThumbnailMaxPixelSize: Int(300),
                    kCGImageSourceCreateThumbnailFromImageIfAbsent: Bool(true)
                ]
            
                let scaledImage = UIImage(CGImage: CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options))
            
                let scaledImageData : NSData = UIImagePNGRepresentation(scaledImage)
                if !scaledImageData.writeToFile(thumbPath, atomically: true) {
                    println("Couldn't save thumbnail to" + thumbPath)
                } else {
                    println("Saved haunt thumbnail to " + thumbPath)
            
                }
            }
        }
    }
}

func documentsDirectory() -> NSURL
{
    let fileManager = NSFileManager.defaultManager()
    let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls.first as! NSURL
}