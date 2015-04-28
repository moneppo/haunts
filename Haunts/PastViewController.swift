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
private var _thumbs = [String]()

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
        let path = docsDir.path! + "/" + LocationService.getLocationString()
        var error = NSErrorPointer()
        let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: error)
        if let c = contents as? [String] {
            _images = c
            for (i, img) in enumerate(_images) {
                _images[i] = path + "/" + img
            }
        }
        
        let thumbsPath = docsDir.path! + "/" + LocationService.getLocationString() + "/thumbs"
        let thumbs = NSFileManager.defaultManager().contentsOfDirectoryAtPath(thumbsPath, error: error)
        if let c = thumbs as? [String] {
            _thumbs = c
            for (i, img) in enumerate(_thumbs) {
                _thumbs[i] = thumbsPath + "/" + img
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
        return _thumbs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! PastViewCell
        let path = _thumbs[indexPath.item]
        let img = UIImage(contentsOfFile:path)
        cell.image = img
        return cell
    }
    
    @objc func dismissModalView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        self.view.backgroundColor = UIColor.blueColor()
        if let img = UIImage(contentsOfFile: _images[indexPath.item]) {
            var modal = PastImageViewController()

            modal.image = img
            modal.view.backgroundColor = UIColor.greenColor()
            
            var modalTap = UITapGestureRecognizer(target:self, action:"dismissModalView")
            modalTap.numberOfTapsRequired = 2
            modal.view.addGestureRecognizer(modalTap)
            self.presentViewController(modal, animated:true, completion:nil)
        }
    }
}