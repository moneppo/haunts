//
//  Util.swift
//  Haunts
//
//  Created by Michael Oneppo on 3/29/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import Foundation
import UIKit

func imageToTempURL(img : UIImage) -> String {
    let imageToSave : NSData = UIImagePNGRepresentation(img)
    let path = NSTemporaryDirectory() + NSUUID().UUIDString + ".png"
    saveImage(img, path)
    return path
}

func saveImage(img: UIImage, path: String) {
    let imageToSave : NSData = UIImagePNGRepresentation(img)
    if !imageToSave.writeToFile(path, atomically: true) {
        println("Couldn't save to " + path)
    } else {
        println("Saved haunt to " + path)
    }
}

func documentsDirectory() -> NSURL
{
    let fileManager = NSFileManager.defaultManager()
    let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls.first as! NSURL
}