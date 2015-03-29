//
//  ViewController.swift
//  Haunts
//
//  Created by Michael Oneppo on 3/25/15.
//  Copyright (c) 2015 moneppo. All rights reserved.
//

import UIKit
import PeerKit
import MultipeerConnectivity

let reuseIdentifier = "PeerCell"

class ViewController: UIViewController, UICollectionViewDataSource { //Collection
    
    @IBOutlet var seanceButton : SeanceButton!
    @IBOutlet var blockButton : BlockSeanceButton!
    @IBOutlet var peerIcons : UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        blockButton.hidden = true

        self.peerIcons.backgroundColor = UIColor.blueColor()
        
        self.peerIcons.dataSource = self
        self.peerIcons.reloadData()
        
        setupPeerConnections()
        PeerKit.transceive("com-moneppo-Wax")
        
        // Register cell classes
        self.peerIcons.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func setupPeerConnections() {
        PeerKit.onConnect = { peer in
           self.peerIcons.reloadData()
        }
        
        PeerKit.onDisconnect = { peer in
            self.peerIcons.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let session = PeerKit.session {
            return session.connectedPeers.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //if let session = PeerKit.session {
        //  session.connectedPeers
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        // Configure the cell
        cell.backgroundColor = UIColor.blackColor()
        
        return cell
    }


}

