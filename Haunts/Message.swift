import Foundation
import MultipeerConnectivity
import PeerKit

public typealias MessageResponse = ((message: Message) -> Void)

@objc(Message) // Force object name for NSCoding
public class Message : NSObject, NSCoding  {
    var Body : AnyObject?
    var Timestamp : NSDate
    var From : MCPeerID
    var Type : String
    
    required convenience public init(coder decoder: NSCoder) {
        self.init(
            from: decoder.decodeObjectForKey("from") as MCPeerID,
            type: decoder.decodeObjectForKey("type") as String,
            timestamp: decoder.decodeObjectForKey("timestamp") as NSDate,
            body: decoder.decodeObjectForKey("body"))
        //super.init(coder: decoder)
//        self.Body = decoder.decodeObjectForKey("body")
//        self.Timestamp = decoder.decodeObjectForKey("timestamp") as NSDate
//        self.From = decoder.decodeObjectForKey("from") as MCPeerID
//        self.Type =
    }
    
    init(from: MCPeerID, type: String, timestamp: NSDate = NSDate(), body: AnyObject? = nil) {
        self.Body = body
        self.Timestamp = timestamp
        self.From = from
        self.Type = type
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.Body, forKey: "body")
        coder.encodeObject(self.Timestamp, forKey: "timestamp")
        coder.encodeObject(self.From, forKey: "from")
        coder.encodeObject(self.Type, forKey: "type")
    }

    public override var hashValue: Int {
        var hash = self.Timestamp.hashValue ^
                   self.From.hashValue ^
                   self.Type.hashValue
        if let o: AnyObject = self.Body {
            hash = hash ^ o.hashValue
        }
        return hash
    }
}

func SendMessage(type: String!, body: AnyObject? = nil, timestamp: NSDate = NSDate(),
                 from: MCPeerID! = PeerKit.session?.myPeerID,
                 to: [MCPeerID]? = PeerKit.session?.connectedPeers as [MCPeerID]?) {
    let m = Message(from: from, type: type, timestamp: timestamp, body: body)
    PeerKit.sendEvent(type, object: m, toPeers: to)
}

func RelayMessage(m : Message) {
    // Relay on to everyone except the peer that sent it.
    if let session = PeerKit.session {
        var sublist = [MCPeerID]()
        for o in session.connectedPeers {
            let peer = o as MCPeerID
            if peer != m.From {
                sublist.append(peer)
            }
        }
        PeerKit.sendEvent(m.Type, object: m, toPeers: sublist)
    }
}

func RelayResource(m : Message, url : NSURL) {
    // Relay on to everyone except the peer that sent it.
    if let session = PeerKit.session {
        var sublist = [MCPeerID]()
        for o in session.connectedPeers {
            let peer = o as MCPeerID
            if peer != m.From {
                sublist.append(peer)
            }
        }
        
        let df = NSDateFormatter()
        let resourceName = df.stringFromDate(m.Timestamp)
        PeerKit.sendResourceAtURL(url, withName: resourceName, toPeers: sublist) { error in
            println("got error relaying " + resourceName)
        }
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    if lhs.Timestamp != rhs.Timestamp ||
           lhs.From != rhs.From ||
        lhs.Type != rhs.Type {
            return false
    }
    
    if let lb: AnyObject = lhs.Body {
        if let rb: AnyObject = rhs.Body {
            if rb.hashValue != lb.hashValue {
                return false
            }
        } else {
            return false
        }
    }
    
    return true
}

private var messages = [Message]()
    
private let MESSAGE_COUNT : Int = 10
    
func filter(message: Message, handler: MessageResponse) {
    for m in messages {
        if m == message {
            println("deja vu " + m.Type)
            return
        }
    }
    if messages.count > MESSAGE_COUNT {
        messages.removeAtIndex(0)
    }
    
    messages.append(message)
    handler(message: message)
}
