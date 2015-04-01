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
    
    enum State {
        case Disconnected
        case RequestedHaunt
        case CreatingNewHaunt
        case Connected
    }
    
    @IBOutlet var seanceButton : SeanceButton!
    @IBOutlet var blockButton : BlockSeanceButton!
    @IBOutlet var peerIcons : UICollectionView!
    @IBOutlet var canvasView : CanvasView2!
    
    @IBOutlet var pinchRecognizer : UIPinchGestureRecognizer!
    @IBOutlet var panRecognizer : UIPanGestureRecognizer!
    
    var state : State = State.Disconnected
    
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
    
    func askForCurrentHaunt(peer: MCPeerID) {
        PeerKit.sendEvent("needHaunt", object: nil, toPeers: [peer])
        self.state = State.RequestedHaunt
    }
    
    func createNewHaunt() {
       self.state = State.Connected
    }
    
    func sendCurrentHaunt(peer: MCPeerID) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        self.canvasView.layer.renderInContext(context)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        let url = imageToTempURL(img)
        PeerKit.sendResourceAtURL(NSURL(fileURLWithPath: url), withName: "Haunt", toPeers: [peer]) { error in
           println(error)
        }
    }
    
    func setupPeerConnections() {
        PeerKit.onConnect = { myPeerID, peerID in
            self.peerIcons.reloadData()
            if let session = PeerKit.session {
                if self.state == State.Disconnected && session.connectedPeers.count > 0 {
                    self.askForCurrentHaunt(peerID)
                }
            }
        }
        
        PeerKit.onDisconnect = { peer in
            self.peerIcons.reloadData()
            if let session = PeerKit.session {
                if session.connectedPeers.count == 0 {
                    self.state = State.Disconnected
                }
            }
        }
        
        PeerKit.onEvent = { peerID, event, object in
            switch event {
            case "needHaunt":
                if self.state == State.Connected {
                    self.sendCurrentHaunt(peerID)
                } else {
                    PeerKit.sendEvent("createNewHaunt", object: nil, toPeers: [peerID])
                    self.state = State.CreatingNewHaunt
                    self.createNewHaunt()
                }
                break
            case "createNewHaunt":
                if self.state == State.RequestedHaunt {
                    self.createNewHaunt()
                } else {
                    println("Got createNewHaunt command but in another state")
                }
                break
            default:
                break
            }
        }
        
        PeerKit.onFinishReceivingResource = { myPeerID, resourceName, peer, localURL in
            if self.state == State.RequestedHaunt {
                self.createNewHaunt()
                let img = UIImage(contentsOfFile: localURL.absoluteString!)
                if let image = img {
                    self.canvasView.placeImage(image, at: CGPointZero)
                }
            } else {
                println("Got an existing haunt without asking for it")
            }
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
            canvasView.placeImage(img, at: canvasView.viewRect.origin)
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

