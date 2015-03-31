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
    imageToSave.writeToFile(path, atomically: true)
    return path
}