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
let SEANCE_AGREED : Int = 1

class ViewController: UIViewController, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    enum State {
        case Disconnected
        case RequestedHaunt
        case CreatingNewHaunt
        case Connected
    }
    
    @IBOutlet var seanceButton : UIButton!
    @IBOutlet var blockButton : BlockSeanceButton!
    @IBOutlet var peerIcons : UICollectionView!
    @IBOutlet var canvasView : CanvasView!
    @IBOutlet var staticView : StaticView!
    
    @IBOutlet var pinchRecognizer : UIPinchGestureRecognizer!
    @IBOutlet var panRecognizer : UIPanGestureRecognizer!
    
    var state : State = State.Disconnected
    var seanceTotal : Int = 0
    var imagePicker: UIImagePickerController!

    override func viewDidLoad() {
        super.viewDidLoad()
        blockButton.hidden = true
        
        self.peerIcons.dataSource = self
        self.peerIcons.reloadData()
        
        setupPeerConnections()
        PeerKit.transceive("com-moneppo-Wax")

        panRecognizer.delegate = self
        pinchRecognizer.delegate = self
        
        panRecognizer.enabled = false
        pinchRecognizer.enabled = false
        
        //createNewHaunt()
        
        // Register cell classes
        self.peerIcons.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        LocationService.start()
        
        PastViewController.initPastViewData()
    }
    
    func askForCurrentHaunt(peer: MCPeerID) {
        SendMessage("needHaunt", to: [peer])
        self.state = State.RequestedHaunt
    }
    
    func createNewHaunt() {
        self.state = State.Connected
        panRecognizer.enabled = true
        pinchRecognizer.enabled = true
        canvasView.fadeIn()
        staticView.fadeOut()
    }
    
    func removeCurrentHaunt() {
        self.state = State.Disconnected
        panRecognizer.enabled = true
        pinchRecognizer.enabled = true
        canvasView.fadeOut()
        staticView.fadeIn()
    }
    
    func createHauntImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        self.canvasView.layer.renderInContext(context)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return img
    }
    
    func sendCurrentHaunt(peer: MCPeerID) {
        let img = createHauntImage()
        let url = imageToTempURL(img)
        PeerKit.sendResourceAtURL(NSURL(fileURLWithPath: url), withName: "Haunt", toPeers: [peer]) { error in
            print("Sent. Any error? ")
            println(error)
        }
    }
    
    func saveHaunt() {
        let dir = documentsDirectory()
        let locString = LocationService.getLocationString()
        let path = dir.URLByAppendingPathComponent(locString)//stringByAppendingPathComponent(locString)
        var error : NSError?
        if !NSFileManager.defaultManager().fileExistsAtPath(path.path!) {
            NSFileManager.defaultManager().createDirectoryAtPath(path.path!,
                withIntermediateDirectories: true, attributes: nil, error: &error)
        }
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH-mm-ss"
        let imgPath = path.path! + "/" + df.stringFromDate(NSDate()) + ".png";
        saveImage(self.createHauntImage(), imgPath)
        NSNotificationCenter.defaultCenter().postNotificationName("Haunts_NewSaved", object:nil)
    }
    
    func setupPeerConnections() {
        PeerKit.onConnect = { myPeerID, peerID in
            print("Connect: ")
            println(peerID)
            self.peerIcons.reloadData()
            if let session = PeerKit.session {
                if self.state == State.Disconnected && session.connectedPeers.count > 0 {
                    self.askForCurrentHaunt(peerID)
                }
            }
        }
        
        PeerKit.onDisconnect = { myPeerID, peerID in
            print("Disconnect: ")
            println(peerID)
            self.peerIcons.reloadData()
            if let session = PeerKit.session {
                if session.connectedPeers.count == 0 {
                    self.removeCurrentHaunt()
                }
            }
        }
        
        PeerKit.onEvent = { peerID, event, object in
            filter(object as! Message) { message in
                println("Event: " + message.Type)
                switch message.Type {
            case "needHaunt":
                if self.state == State.Connected {
                    self.sendCurrentHaunt(peerID)
                } else {
                    SendMessage("createNewHaunt", to: [peerID])
                    self.state = State.CreatingNewHaunt
                    self.createNewHaunt()
                }
                break
            case "createNewHaunt":
                if self.state == State.RequestedHaunt {
                    self.createNewHaunt()
                } else if self.state == State.CreatingNewHaunt {
                    println("Got createNewHaunt, yup, we know")
                } else {
                    println("Got createNewHaunt command but in another state")
                }
                break
            case "path":
                if self.state == State.Connected {
                    if let p = message.Body as? Path {
                        self.canvasView.placePath(p)
                    }
                    RelayMessage(message)
                } else {
                    println("Got path while not connected")
                }
            case "seance":
                if self.state == State.Connected {
                    self.blockButton.hidden = false
                    self.seanceTotal++
                    if self.seanceTotal >= SEANCE_AGREED {
                        self.seanceTotal = 0
                        self.saveHaunt()
                    }
                    
                    RelayMessage(message)
                }
                break
            case "block":
                self.seanceTotal = 0
                self.blockButton.hidden = true
                RelayMessage(message)
                break
            default:
                break
            }
        }
        }
        
        PeerKit.onFinishReceivingResource = { myPeerID, resourceName, peerID, localURL in
            if resourceName == "Haunt" {
                if self.state == State.RequestedHaunt {
                    self.createNewHaunt()
                    if let image = UIImage(contentsOfFile: localURL.path!) {
                        self.canvasView.placeImage(image, at: CGPointZero)
                    }
                    
                    if let session = PeerKit.session {
                        var sublist = [MCPeerID]()
                        for o in session.connectedPeers {
                            let peer = o as! MCPeerID
                            if peer != peerID {
                                sublist.append(peer)
                            }
                        }
                        PeerKit.sendResourceAtURL(localURL, withName: resourceName, toPeers: sublist) { error in
                            println("got error relaying " + resourceName)
                        }
                    }
                } else {
                    println("Got an existing haunt without asking for it")
                }
            } else {
                let df = NSDateFormatter()
                df.dateFormat = "yyyy-MM-dd HH-mm-ss"
                if let timestamp = df.dateFromString(resourceName) {
                    let message = Message(from: peerID, type: "image", timestamp: timestamp)
                    filter(message) { m in
                        self.canvasView.placeImage(UIImage(contentsOfFile: localURL.path!)!, at: CGPointZero)
                        RelayResource(m, localURL)
                    }
                }
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
    
    @IBAction func setStrokeColor(caller: UIButton) {
        if let c = caller.backgroundColor {
            var w : CGFloat = 0
            var a : CGFloat = 0
            c.getWhite(&w, alpha: &a)
            if (w < 0.25) {
                self.canvasView.setStrokeColor(UIColor.blackColor())
            } else {
                var r : CGFloat = 0
                var g : CGFloat = 0
                var b : CGFloat = 0
                var a : CGFloat = 0
                c.getRed(&r, green:&g, blue:&b, alpha:&a)
                self.canvasView.setStrokeColor(UIColor(red: r, green: g, blue: b, alpha: 1))
            }
        }
    }

    
    @IBAction func seance(sender: UIButton) {
        if self.state == State.Connected {
            self.blockButton.hidden = false
            self.seanceTotal++
            if self.seanceTotal >= SEANCE_AGREED {
                self.seanceTotal = 0
                self.saveHaunt()
            }

            if let session = PeerKit.session {
                SendMessage("seance")
            }
        }
    }
    
    @IBAction func openHistory(sender:UIButton) {
        self.navigationController?.pushViewController(PastViewController(), animated: true)
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
            let url = imageToTempURL(img)
            let df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd HH-mm-ss"
            let dateString = df.stringFromDate(NSDate())
            PeerKit.sendResourceAtURL(NSURL(fileURLWithPath: url), withName: dateString,
                withCompletionHandler: { error in
                    println(error)
                })
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        
        // Configure the cell
        let path = NSBundle.mainBundle().pathForResource("video48", ofType:"png")
        if let img = UIImage(contentsOfFile: path!) {
            cell.backgroundColor = UIColor(patternImage: img)
        }
        
        return cell
    }
}