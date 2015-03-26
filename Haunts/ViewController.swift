//
//  ViewController.swift
//  Haunts
//
//  Created by Michael Oneppo on 3/25/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import UIKit

let reuseIdentifier = "PeerCell"

class ViewController: UIViewController, UICollectionViewDataSource { //Collection
    
    @IBOutlet var seanceButton : SeanceButton!
    @IBOutlet var blockButton : BlockSeanceButton!
    @IBOutlet var peerIcons : UICollectionView!
    
    var peers : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        blockButton.hidden = true

        self.peerIcons.backgroundColor = UIColor.blueColor()
        
        self.peers = []
        self.peerIcons.dataSource = self
        self.peerIcons.reloadData()
        
        // Register cell classes
        self.peerIcons.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.peers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        // Configure the cell
        cell.backgroundColor = UIColor.blackColor()
        
        return cell
    }


}

