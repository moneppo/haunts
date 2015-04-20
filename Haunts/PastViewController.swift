//
//  PastViewController.swift
//  Created by Michael Oneppo on 4/2/15.
//

//
//  Based on BITransylvaniaPhotosViewController.swift
//  Created by Bogdan Iusco on 8/9/14.
//  Copyright (c) 2014 Grigaci. All rights reserved.
//

import UIKit

private var _images = [String]()

class PastViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let reuseID = NSStringFromClass(PastViewCell.self)
    
    @IBOutlet var collectionView : UICollectionView!
    
    @IBAction func backButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.registerClass(PastViewCell.self, forCellWithReuseIdentifier: reuseID)
        self.collectionView!.delegate = self
        
        self.collectionView!.dataSource = self
        self.collectionView!.reloadData()
    }
    
    class func refreshData() {
        let docsDir = documentsDirectory()
        let path = docsDir.path! + "/" + LocationService.getLocationString() + "/"
        var error = NSErrorPointer()
        let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: error)
        if let c = contents as? [String] {
            _images = c
            for (i, img) in enumerate(_images) {
                _images[i] = path + img
            }
        }
    }
    
    class func initPastViewData() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hauntSaved:", name: "Haunts_NewSaved", object: nil)
        refreshData()
    }
    
    @objc class func hauntSaved(notification: NSNotification) {
        refreshData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! PastViewCell
        let img = UIImage(contentsOfFile: _images[indexPath.item])
        cell.image = img
        return cell
    }
    
    @objc func dismissModalView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var modal = UIViewController()
        modal.view.backgroundColor = UIColor.blackColor()
        modal.view.userInteractionEnabled=true;
        
        var panView = PanView(frame:modal.view.frame)
        panView.image = UIImage(contentsOfFile: _images[indexPath.item])
        panView.backgroundColor = UIColor.greenColor()
        modal.view.addSubview(panView)
       // panView.center = modal.view.center
        panView.viewRect.origin = CGPoint(x: 1500, y: 1500)
        panView.viewRect.size = modal.view.bounds.size
        panView.updateViewRect()
    
        var modalTap = UITapGestureRecognizer(target:self, action:"dismissModalView")
        modalTap.numberOfTapsRequired = 2
        modalTap.delegate = panView
        modal.view.addGestureRecognizer(modalTap)
        
        self.presentViewController(modal, animated:true, completion:nil)
    }
}