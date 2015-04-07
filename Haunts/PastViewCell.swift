//
//  PastViewCell.swift
//  Created by Michael Oneppo on 4/2/15
//
//  Based on BIPhotoCollectionViewCell.swift
//  Created by Bogdan Iusco on 8/10/14.
//  Copyright (c) 2014 Grigaci. All rights reserved.
//

import UIKit

class PastViewCell : UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        var tmpView = UIImageView()
        tmpView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return tmpView
        }()
    
    var image: UIImage? {
        didSet {
            if image != nil {
                self.imageView.image = image
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(self.imageView)
        self.setupConstraints()
    }
    
    convenience required init(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
    func setupConstraints() {
        let viewsDictionary = ["imageView":imageView]
        let constraints_H:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        let constraints_V:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|",
            options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        self.contentView.addConstraints(constraints_H)
        self.contentView.addConstraints(constraints_V)
    }
}