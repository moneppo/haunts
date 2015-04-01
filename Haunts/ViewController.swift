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

class ViewController: UIViewController, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var seanceButton : SeanceButton!
    @IBOutlet var blockButton : BlockSeanceButton!
    @IBOutlet var peerIcons : UICollectionView!
    @IBOutlet var canvasView : CanvasView2!
    
    @IBOutlet var pinchRecognizer : UIPinchGestureRecognizer!
    @IBOutlet var panRecognizer : UIPanGestureRecognizer!
    
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        blockButton.hidden = true

        self.peerIcons.backgroundColor = UIColor.blueColor()
        
        self.peerIcons.dataSource = self
        self.peerIcons.reloadData()
        
        setupPeerConnections()
        PeerKit.transceive("com-moneppo-Wax")

        panRecognizer.delegate = self
        pinchRecognizer.delegate = self
        
        canvasView.zoomToExtents()
        
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
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
    
// MARK: Actions
    
    @IBAction func takePhoto(sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func handlePan(rec : UIPanGestureRecognizer) {
        switch(rec.state) {
        case UIGestureRecognizerState.Began:
            canvasView.panBegan(rec.locationInView(canvasView), numTouches: rec.numberOfTouches())
            rec.setTranslation(CGPoint.zeroPoint, inView: canvasView)
            break
        case UIGestureRecognizerState.Changed:
            canvasView.panMoved(rec.locationInView(canvasView), numTouches: rec.numberOfTouches())
            rec.setTranslation(CGPoint.zeroPoint, inView: canvasView)
            break
        case UIGestureRecognizerState.Ended:
            canvasView.panEnded(rec.numberOfTouches())
            break
        default:
            canvasView.panEnded(rec.numberOfTouches())
            break
        }
    }
    
    @IBAction func handlePinch(rec : UIPinchGestureRecognizer) {
        canvasView.pinchMoved(rec.scale)
        rec.scale = 1.0
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            canvasView.placeImage(img)
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

