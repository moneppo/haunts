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
    
    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSizeMake(100, 100)
        layout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20)
        
        self.collectionView!.collectionViewLayout = layout
        self.collectionView!.registerClass(PastViewCell.self, forCellWithReuseIdentifier: reuseID)
        self.collectionView!.delegate = self
        
        self.collectionView!.dataSource = self
        self.collectionView!.reloadData()
    }
    
    class func refreshData() {
        let docsDir = documentsDirectory()
        let path = docsDir.path! + "/" + LocationService.getLocationString() + "/"
        var error = NSErrorPointer()
        _images = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: error) as [String]
        for (i, img) in enumerate(_images) {
            _images[i] = path + img
        }
    }
    
    class func initPastViewData() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hauntSaved:", name: "Haunts_NewSaved", object: nil)
        refreshData()
    }
    
    @objc class func hauntSaved(notification: NSNotification) {
        refreshData()
    }
    
    // Checklist
    // Fix handshake
    // Fix disconnect problem
    // Finish past haunts
    // Colors for drawing
    // Look into notifications
    // First path issue

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as PastViewCell
        let img = UIImage(contentsOfFile: _images[indexPath.item])
        cell.image = img
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
   /*     var cell:BIPhotoCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as BIPhotoCollectionViewCell
        var photoViewController: BIPhotoViewController = BIPhotoViewController(nibName: nil, bundle: nil)
        
        // Set photo
        photoViewController.photo = cell.photo
        
        // Set title
        var location = BIModelManager.sharedInstance.locationAtIndex(indexPath.section)
        photoViewController.title = location?.name
        
        // Push it on nav stack
        self.navigationController?.pushViewController(photoViewController, animated: true)*/
    }
}